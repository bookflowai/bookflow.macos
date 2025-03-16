import Foundation

struct ExercisesResponse: Codable {
    let exercises: [ExerciseResponse]
}

enum SkillType: String, Codable {
    case reading = "reading"
    case writing = "writing"
    case speaking = "speaking"
}

enum Level: String, Codable {
    case recognition = "recognition"
    case guided = "guided"
    case independent = "independent"
    case creative = "creative"
}

enum TaskType: String, Codable {
    case multipleChoice = "multiple_choice"
    case shortAnswer = "short_answer"
    case openEnded = "open_ended"
}

struct ExerciseResponse: Codable {
    let exerciseId: Int
    let skillType: SkillType
    let level: Level
    let title: String
    let titleTranslation: String
    let instructions: String
    let instructionsTranslation: String
    let textContent: String?
    let textContentTranslation: String?
    let taskType: TaskType
    let taskContent: String
    let taskContentTranslation: String
    let options: [String]?
    let optionsTranslation: [String]?
    let correctResponse: String
    let hint: String?
    
    enum CodingKeys: String, CodingKey {
        case exerciseId = "exercise_id"
        case skillType = "skill_type"
        case level, title
        case titleTranslation = "title_translation"
        case instructions
        case instructionsTranslation = "instructions_translation"
        case textContent = "text_content"
        case textContentTranslation = "text_content_translation"
        case taskType = "task_type"
        case taskContent = "task_content"
        case taskContentTranslation = "task_content_translation"
        case options
        case optionsTranslation = "options_translation"
        case correctResponse = "correct_response"
        case hint
    }
}
