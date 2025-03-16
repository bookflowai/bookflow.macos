import Foundation
import PDFKit

@MainActor
class PDFLoaderViewModel: ObservableObject {
    private let apiKey: String = "" // if you wanna test - put your key from gemini here
    private let pagesPerPart: Int = 10
    
    @Published var pdfURL: URL?
    @Published var splitDocuments: [PDFDocument] = []
    @Published var pagesToSplit: [SplitPageInfo] = []
    @Published var pageImages: [NSImage] = []
    @Published var pdfOutline: [PDFOutlineItem] = []
    @Published var selectedDocument: PDFDocument?
    @Published var tocSplitInfo: [SplitInfo] = []
    @Published var selectedChapter: PDFOutlineItem?
    @Published var isLoading = false
    @Published var teacherSummary: ChapterAnalysis?
    @Published var exercises: ExercisesResponse?
    
    func loadPDF() async {
        await openPDF()
    }
    
    func selectChapter(_ chapter: PDFOutlineItem) async {
        selectedChapter = chapter
        guard let url = pdfURL, let document = PDFDocument(url: url),
              let splitInfo = tocSplitInfo.first(where: { $0.sectionName == chapter.title }) else { return }
        
        let pageRange = splitInfo.pageRange.split(separator: "-")
        let startPage = Int(pageRange[0])
        let endPage = Int(pageRange[1])
        
        guard let startPage, let endPage else { return }
        let chapterDoc = PDFDocument()
        for pageIndex in startPage..<endPage {
            if let page = document.page(at: pageIndex) {
                chapterDoc.insert(page, at: chapterDoc.pageCount)
            }
        }
        
        if let exercisesPageRange = splitInfo.relatedExcercisesPageRange {
            let exerciseRanges = exercisesPageRange.split(separator: ",")
            for range in exerciseRanges {
                let parts = range.trimmingCharacters(in: .whitespaces).split(separator: "-")
                let exerciseStartPage = Int(parts[0])
                let exerciseEndPage = Int(parts[1])
                guard let exerciseStartPage, let exerciseEndPage else { return }
                for pageIndex in exerciseStartPage..<exerciseEndPage {
                    if let page = document.page(at: pageIndex) {
                        chapterDoc.insert(page, at: chapterDoc.pageCount)
                    }
                }
            }
        }
        
        var pageImages: [String] = []
        for pageIndex in 0..<chapterDoc.pageCount {
            if let page = chapterDoc.page(at: pageIndex),
               let tiffData = page.thumbnail(of: CGSize(width: 500, height: 700), for: .artBox).tiffRepresentation,
               let bitmap = NSBitmapImageRep(data: tiffData),
               let jpegData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) {
                pageImages.append(jpegData.base64EncodedString())
            }
        }
        
        do {
            let (summary, exercises) = try await fetchChapterAnalysis(pageImages: pageImages)
            await MainActor.run {
                self.teacherSummary = summary
                self.exercises = exercises
                print("Teacher Summary: \(String(describing: summary))")
                selectedDocument = chapterDoc
            }
        } catch {
            print("Failed to analyze chapter with Gemini: \(error)")
            await MainActor.run {
                selectedDocument = chapterDoc
            }
        }
    }
    
    private func fetchChapterAnalysis(pageImages: [String]) async throws -> (ChapterAnalysis, ExercisesResponse) {
        let summaryRequest = try createGeminiImageRequest(images: pageImages, prompt: Constants.geminiExersicePrompt)
        let (summaryData, summaryResponse) = try await URLSession.shared.data(for: summaryRequest)
        guard let summaryHttpResponse = summaryResponse as? HTTPURLResponse, summaryHttpResponse.statusCode == 200 else {
            let message = String(data: summaryData, encoding: .utf8) ?? "Unknown error"
            throw GeminiError.apiError(message: message)
        }
        
        let summaryText = try parseGeminiResponse(data: summaryData)
        let summary = try JSONDecoder().decode(ChapterAnalysis.self, from: summaryText.data(using: .utf8)!)
        
        let exercisesRequest = try createGeminiImageRequest(images: pageImages, prompt: Constants.geminiExerciseDescription)
        let (exercisesData, exercisesResponse) = try await URLSession.shared.data(for: exercisesRequest)
        guard let exercisesHttpResponse = exercisesResponse as? HTTPURLResponse, exercisesHttpResponse.statusCode == 200 else {
            let message = String(data: exercisesData, encoding: .utf8) ?? "Unknown error"
            throw GeminiError.apiError(message: message)
        }
        
        let exercisesText = try parseGeminiResponse(data: exercisesData)
        let exercises = try JSONDecoder().decode(ExercisesResponse.self, from: exercisesText.data(using: .utf8)!)
        
        return (summary, exercises)
    }
    
    private func parseGeminiResponse(data: Data) throws -> String {
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let content = candidates.first?["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let text = parts.first?["text"] as? String else {
            throw GeminiError.invalidResponse
        }
        
        return text.replacingOccurrences(of: "```json", with: "")
                   .replacingOccurrences(of: "```", with: "")
                   .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func openPDF() async {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.pdf]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if await panel.begin() == .OK, let url = panel.urls.first {
            await MainActor.run {
                pdfURL = url
                splitDocuments = []
                pagesToSplit = []
                pageImages = []
                pdfOutline = []
                teacherSummary = nil
                exercises = nil
            }
            await extractOutlineAndSplit()
        }
    }
    
    func extractOutlineAndSplit() async {
        guard let url = pdfURL, let document = PDFDocument(url: url) else { return }
        if let outlineRoot = document.outlineRoot {
            await parseOutline(outlineRoot, parentPageNumber: 0)
            isLoading = true
            do {
                let toc = try await analyzeOutlineWithGemini()
                await splitPDFBasedOnTOC(toc)
                isLoading = false
            } catch {
                print("Failed to analyze outline: \(error)")
            }
        } else {
            do {
                isLoading = true
                try await analyzePDFWithGemini()
                if !pagesToSplit.isEmpty {
                    await splitPDFBasedOnSplitPoints()
                } else {
                    await splitPDFIntoParts()
                }
                isLoading = false
            } catch {
                print("Failed to analyze PDF with images: \(error)")
            }
        }
    }
    
    private func parseOutline(_ outline: PDFOutline, parentPageNumber: Int) async {
        var items: [PDFOutlineItem] = []
        for i in 0..<outline.numberOfChildren {
            guard let item = outline.child(at: i), let page = item.destination?.page else { continue }
            let pageNumber = page.document?.index(for: page) ?? parentPageNumber
            let title = item.label ?? "Untitled"
            items.append(PDFOutlineItem(title: title, pageNumber: pageNumber))
            
            if item.numberOfChildren > 0 {
                await parseOutline(item, parentPageNumber: pageNumber)
            }
        }
        await MainActor.run { pdfOutline.append(contentsOf: items) }
    }
    
    func splitPDFIntoParts() async {
        guard let url = pdfURL, let document = PDFDocument(url: url) else { return }
        let parts = dividePDF(document: document, pagesPerPart: pagesPerPart)
        await MainActor.run {
            splitDocuments = parts
            if !parts.isEmpty { selectedDocument = parts.first }
        }
    }
    
    private func dividePDF(document: PDFDocument, pagesPerPart: Int) -> [PDFDocument] {
        let totalPages = document.pageCount
        var parts: [PDFDocument] = []
        
        for start in stride(from: 0, to: totalPages, by: pagesPerPart) {
            let part = PDFDocument()
            let end = min(start + pagesPerPart, totalPages)
            for i in start..<end {
                if let page = document.page(at: i) {
                    part.insert(page, at: part.pageCount)
                }
            }
            if part.pageCount > 0 { parts.append(part) }
        }
        return parts
    }
    
    private func splitPDFBasedOnTOC(_ toc: TableOfContents) async {
        guard let url = pdfURL, let document = PDFDocument(url: url), !toc.sections.isEmpty else { return }
        var parts: [PDFDocument] = []
        var splitInfos: [SplitInfo] = []
        
        let sortedSections = toc.sections.sorted { $0.beginPage < $1.beginPage }
        for (index, section) in sortedSections.enumerated() {
            let beginPage = section.beginPage
            let endPage = section.endPage ?? document.pageCount
            
            let part = PDFDocument()
            for pageIndex in beginPage..<endPage {
                if let page = document.page(at: pageIndex) {
                    part.insert(page, at: part.pageCount)
                }
            }
            
            if part.pageCount > 0 {
                parts.append(part)
                let partNumber = parts.count
                let pageRange = "\(section.beginPage)-\(section.endPage ?? (document.pageCount - 1))"
                let exercises = section.relatedExercises.map { "\($0.exerciseName)" }.joined(separator: ", ")
                let exercisesPageRange = section.relatedExercises.map { "\($0.beginPage)-\($0.endPage ?? document.pageCount)" }.joined(separator: ", ")
                splitInfos.append(SplitInfo(partNumber: partNumber, sectionName: section.name, pageRange: pageRange, relatedExercises: exercises.isEmpty ? nil : exercises, relatedExcercisesPageRange: exercisesPageRange))
            }
        }
        
        await MainActor.run {
            splitDocuments = parts
            tocSplitInfo = splitInfos
            if !parts.isEmpty { selectedDocument = parts.first }
        }
    }
    
    private func splitPDFBasedOnSplitPoints() async {
        guard let url = pdfURL, let document = PDFDocument(url: url), !pagesToSplit.isEmpty else { return }
        var parts: [PDFDocument] = []
        var currentPart = PDFDocument()
        var currentPageIndex = 0
        
        let sortedSplitPoints = pagesToSplit.sorted { $0.pageNumber < $1.pageNumber }
        for splitPoint in sortedSplitPoints {
            let splitPage = splitPoint.pageNumber
            while currentPageIndex < splitPage && currentPageIndex < document.pageCount {
                if let page = document.page(at: currentPageIndex) {
                    currentPart.insert(page, at: currentPart.pageCount)
                }
                currentPageIndex += 1
            }
            if currentPart.pageCount > 0 {
                parts.append(currentPart)
                currentPart = PDFDocument()
            }
            if currentPageIndex == splitPage, let page = document.page(at: currentPageIndex) {
                currentPart.insert(page, at: currentPart.pageCount)
                currentPageIndex += 1
            }
        }
        
        while currentPageIndex < document.pageCount {
            if let page = document.page(at: currentPageIndex) {
                currentPart.insert(page, at: currentPart.pageCount)
            }
            currentPageIndex += 1
        }
        if currentPart.pageCount > 0 { parts.append(currentPart) }
        
        await MainActor.run {
            splitDocuments = parts
            if !parts.isEmpty { selectedDocument = parts.first }
        }
    }
    
    func analyzePDFWithGemini() async throws {
        guard let url = pdfURL, let document = PDFDocument(url: url) else { return }
        await MainActor.run {
            pagesToSplit = []
            pageImages = []
        }
        
        let images = try await generatePageImages(from: document)
        let splitInfo = try await sendImagesToGemini(images: images)
        if let info = splitInfo {
            await MainActor.run { pagesToSplit.append(info) }
        }
    }
    
    private func generatePageImages(from document: PDFDocument) async throws -> [String] {
        var base64Images: [String] = []
        let pageCount = document.pageCount
        
        for i in 0..<min(10, pageCount) {
            if let image = try generateThumbnail(from: document, pageIndex: i) {
                await MainActor.run { pageImages.append(image) }
                base64Images.append(try image.toBase64())
            }
        }
        
        for offset in 0..<min(10, pageCount) {
            let i = pageCount - 1 - offset
            if let image = try generateThumbnail(from: document, pageIndex: i) {
                await MainActor.run { pageImages.append(image) }
                base64Images.append(try image.toBase64())
            }
        }
        
        return base64Images
    }
    
    private func generateThumbnail(from document: PDFDocument, pageIndex: Int) throws -> NSImage? {
        guard let page = document.page(at: pageIndex),
              let tiffData = page.thumbnail(of: CGSize(width: 500, height: 700), for: .artBox).tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) else {
            throw GeminiError.invalidImage
        }
        return NSImage(data: jpegData)
    }
    
    func analyzeOutlineWithGemini() async throws -> TableOfContents {
        let outlineText = pdfOutline.map { "\($0.pageNumber). \($0.title)" }
        return try await fetchTableOfContents(outlineText: outlineText)
    }
    
    private func fetchTableOfContents(outlineText: [String]) async throws -> TableOfContents {
        let request = try createGeminiRequest(outlineText: outlineText)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw GeminiError.apiError(message: message)
        }
        
        let text = try parseGeminiResponse(data: data)
        guard let jsonData = text.data(using: .utf8) else {
            throw GeminiError.invalidResponse
        }
        
        return try JSONDecoder().decode(TableOfContents.self, from: jsonData)
    }
    
    private func createGeminiRequest(outlineText: [String]) throws -> URLRequest {
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(apiKey)") else {
            throw GeminiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prompt = Constants.geminiPrompt
        let content: [String: Any] = [
            "role": "user",
            "parts": [["text": prompt + "\n" + outlineText.joined(separator: "\n")]]
        ]
        let requestData: [String: Any] = ["contents": [content], "tools": []]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestData, options: .prettyPrinted)
        return request
    }
    
    private func sendImagesToGemini(images: [String]) async throws -> SplitPageInfo? {
        let request = try createGeminiImageRequest(images: images, prompt: Constants.geminiImagePrompt)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw GeminiError.apiError(message: message)
        }
        
        let text = try parseGeminiResponse(data: data)
        guard let jsonData = text.data(using: .utf8),
              let toc = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            throw GeminiError.invalidResponse
        }
        
        guard let containsToc = toc["contains_toc"] as? Bool, containsToc,
              let chapters = toc["chapters"] as? [[String: Any]], !chapters.isEmpty else {
            print("No TOC or empty chapters")
            return nil
        }
        
        let sortedChapters = chapters.sorted { ($0["begin_of_chapter"] as? Int ?? 0) < ($1["begin_of_chapter"] as? Int ?? 0) }
        let reason = sortedChapters.compactMap { chapter in
            guard let begin = chapter["begin_of_chapter"] as? Int,
                  let end = chapter["end_of_chapter"] as? Int,
                  let name = chapter["name_of_chapter"] as? String else { return nil }
            return "\(name) (\(begin)-\(end))"
        }.joined(separator: ", ")
        
        return SplitPageInfo(pageNumber: 0, reason: "TOC found: \(reason)")
    }
    
    private func createGeminiImageRequest(images: [String], prompt: String) throws -> URLRequest {
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(apiKey)") else {
            throw GeminiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var contents: [[String: Any]] = []
        for image in images {
            let content: [String: Any] = [
                "role": "user",
                "parts": [
                    ["text": prompt + "\n[IMAGE]"],
                    ["inline_data": ["mime_type": "image/jpeg", "data": image]]
                ]
            ]
            contents.append(content)
        }
        
        let requestData: [String: Any] = ["contents": contents, "tools": []]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestData, options: .prettyPrinted)
        return request
    }
}
