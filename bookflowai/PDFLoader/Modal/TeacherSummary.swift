import Foundation

struct ChapterAnalysis: Codable {
    let chapterAnalysis: ChapterContent
    
    enum CodingKeys: String, CodingKey {
        case chapterAnalysis = "chapter_analysis"
    }
}

struct ChapterContent: Codable, Hashable {
    let title: String
    let theme: String
    let goals: [String]
    let grammar: [GrammarItem]
    let phonetics: [PhoneticItem]
    let vocabulary: [VocabularyGroup]
    let communication: [CommunicationFunction]
    let commonMistakes: [Mistake]
    
    enum CodingKeys: String, CodingKey {
        case title, theme, goals, grammar, phonetics, vocabulary, communication
        case commonMistakes = "common_mistakes"
    }
}

struct GrammarItem: Codable, Hashable {
    let name: String
    let explanation: String
    let examples: [LanguageExample]
}


struct PhoneticItem: Codable, Hashable {
    let name: String
    let explanation: String
    let examples: [PhoneticExample]
}

struct LanguageExample: Codable, Hashable {
    let text: String
    let translation: String
    let notes: String
}

struct PhoneticExample: Codable, Hashable {
    let text: String
    let transcription: String
    let notes: String
}

struct VocabularyGroup: Codable, Hashable {
    let theme: String
    let words: [VocabularyWord]
}

struct VocabularyWord: Codable, Hashable {
    let word: String
    let translation: String
    let examples: [String]
}

struct CommunicationFunction: Codable, Hashable {
    let function: String
    let expressions: [FunctionalExpression]
}

struct FunctionalExpression: Codable, Hashable {
    let text: String
    let translation: String
    let usage: String
}

struct Mistake: Codable, Hashable {
    let description: String
    let incorrect: String
    let correct: String
}
