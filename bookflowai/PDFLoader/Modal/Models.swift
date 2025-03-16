import Foundation

struct TableOfContents: Codable {
    let containsToc: Bool
    let sections: [Section]
    
    enum CodingKeys: String, CodingKey {
        case containsToc = "contains_toc"
        case sections
    }
}

enum SectionType: String, Codable {
    case unit
    case special
}

struct Section: Codable {
    let type: SectionType
    let unitNumber: String
    let beginPage: Int
    let endPage: Int?
    let name: String
    let relatedExercises: [Exercise]
    
    enum CodingKeys: String, CodingKey {
        case type
        case unitNumber = "unit_number"
        case beginPage = "begin_page"
        case endPage = "end_page"
        case name
        case relatedExercises = "related_exercises"
    }
}

struct Exercise: Codable {
    let exerciseName: String
    let beginPage: Int
    let endPage: Int?
    
    enum CodingKeys: String, CodingKey {
        case exerciseName = "exercise_name"
        case beginPage = "begin_page"
        case endPage = "end_page"
    }
}

struct PDFOutlineItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let pageNumber: Int
}

struct SplitPageInfo: Identifiable {
    let id = UUID()
    let pageNumber: Int
    let reason: String
}

enum GeminiError: Error {
    case invalidURL
    case apiError(message: String)
    case invalidResponse
    case invalidImage
}

struct SplitInfo: Identifiable {
    let id = UUID()
    let partNumber: Int
    let sectionName: String
    let pageRange: String
    let relatedExercises: String?
    let relatedExcercisesPageRange: String?
}
