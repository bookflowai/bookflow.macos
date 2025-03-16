import SwiftUI
import Combine
import PDFKit

struct PDFLoaderView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                if let pdfURL = viewModel.pdfURL {
                    Text("Selected File: \(pdfURL.lastPathComponent)")
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Button("Split PDF (AI)") {
                        Task { try? await viewModel.analyzePDFWithGemini() }
                    }
                    
                    Button("Split PDF") {
                        Task { await viewModel.splitPDFIntoParts() }
                    }
                    
                    Divider()
                    
                    Text("Outline:")
                        .font(.headline)
                    List(viewModel.pdfOutline, id: \.id) { item in
                        Text("Page \(item.pageNumber + 1): \(item.title)")
                    }
                    
                    Divider()
                    
                    Text("TOC Split Info:")
                        .font(.headline)
                    List(viewModel.tocSplitInfo, id: \.id) { info in
                        VStack(alignment: .leading) {
                            Text("Part \(info.partNumber): \(info.sectionName) (Pages \(info.pageRange))")
                            if let exercises = info.relatedExercises {
                                Text("Exercises: \(exercises)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Text("AI Split Points:")
                        .font(.headline)
                    List(viewModel.pagesToSplit, id: \.id) { pageInfo in
                        Text("Page \(pageInfo.pageNumber + 1): \(pageInfo.reason)")
                    }
                    
                    Divider()
                    
                    Text("Page Previews:")
                        .font(.headline)
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(viewModel.pageImages, id: \.self) { image in
                                Image(nsImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 150)
                            }
                        }
                    }
                    
                    Divider()
                    
                    Text("Parts:")
                        .font(.headline)
                    List(viewModel.splitDocuments.indices, id: \.self) { index in
                        Button("Part \(index + 1)") {
                            viewModel.selectedDocument = viewModel.splitDocuments[index]
                        }
                    }
                } else {
                    Text("Select a PDF file")
                }
                
                Button("Load PDF") {
                    Task { await viewModel.openPDF() }
                }
            }
            .frame(width: 250)
            .padding()
            
            Divider()
            
            PDFKitView(document: viewModel.selectedDocument)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 800, minHeight: 500)
    }
    
    @ObservedObject private var viewModel: PDFLoaderViewModel
    init(viewModel: PDFLoaderViewModel) {
        self.viewModel = viewModel
    }
}
