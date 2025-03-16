import SwiftUI

struct ExerciseCard: View {
    let exercise: ExerciseResponse
    @Binding var userAnswer: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Consts.paddingSmall) {
            Text("\(exercise.exerciseId). \(exercise.title)")
                .foregroundColor(Consts.textPrimary)
                .font(Consts.subtitleFont)
            Text(exercise.titleTranslation)
                .foregroundColor(Consts.accent)
                .font(Consts.bodyFont)
                .italic()
            
            Text(exercise.instructions)
                .foregroundColor(Consts.textSecondary)
                .font(Consts.bodyFont)
            Text(exercise.instructionsTranslation)
                .foregroundColor(Consts.textSecondary.opacity(0.8))
                .font(Consts.bodyFont)
                .italic()
            
            if let textContent = exercise.textContent {
                Text(textContent)
                    .foregroundColor(Consts.selectedText)
                    .font(Consts.bodyFont)
                    .padding(.vertical, Consts.paddingSmall)
                if let translation = exercise.textContentTranslation {
                    Text(translation)
                        .foregroundColor(Consts.textSecondary.opacity(0.8))
                        .font(Consts.bodyFont)
                        .italic()
                }
            }
            
            Text(exercise.taskContent)
                .foregroundColor(Consts.textPrimary)
                .font(Consts.bodyFont)
                .bold()
            Text(exercise.taskContentTranslation)
                .foregroundColor(Consts.accent)
                .font(Consts.bodyFont)
            
            switch exercise.taskType {
            case .multipleChoice:
                if let options = exercise.options, let optionsTranslation = exercise.optionsTranslation {
                    Picker("", selection: Binding(
                        get: { userAnswer ?? "" },
                        set: { userAnswer = $0 }
                    )) {
                        ForEach(0..<options.count, id: \.self) { index in
                            Text("\(options[index]) (\(optionsTranslation[index]))")
                                .tag(options[index])
                                .foregroundColor(Consts.textPrimary)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(Consts.textPrimary)
                    .accentColor(Consts.accent)
                    .padding(Consts.paddingSmall)
                    .background(Consts.cardBackground.opacity(0.7))
                    .cornerRadius(Consts.cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: Consts.cornerRadius)
                            .stroke(Consts.border, lineWidth: 1)
                    )
                }
            case .shortAnswer, .openEnded:
                TextField("Your answer...", text: Binding(
                    get: { userAnswer ?? "" },
                    set: { userAnswer = $0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(Consts.textPrimary)
                .background(Consts.cardBackground.opacity(0.7))
                .cornerRadius(Consts.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Consts.cornerRadius)
                        .stroke(Consts.border, lineWidth: 1)
                )
                .padding(.vertical, Consts.paddingSmall)
            }
            
            HStack(spacing: Consts.paddingMedium) {
                Button(action: {
                    if let answer = userAnswer {
                        let isCorrect = answer == exercise.correctResponse
                        print("Exercise \(exercise.exerciseId): \(isCorrect ? "Correct" : "Incorrect")")
                    }
                }) {
                    Text("Verify")
                        .font(Consts.buttonFont)
                        .foregroundColor(Consts.textPrimary)
                        .padding(.horizontal, Consts.paddingMedium)
                        .padding(.vertical, Consts.paddingSmall)
                        .background(Consts.primary.opacity(0.9))
                        .cornerRadius(Consts.cornerRadius)
                }
                
                if let hint = exercise.hint {
                    Button(action: {
                        print("Hint for Exercise \(exercise.exerciseId): \(hint)")
                    }) {
                        Text("Hint")
                            .font(Consts.buttonFont)
                            .foregroundColor(Consts.textPrimary)
                            .padding(.horizontal, Consts.paddingMedium)
                            .padding(.vertical, Consts.paddingSmall)
                            .background(Consts.secondary.opacity(0.9))
                            .cornerRadius(Consts.cornerRadius)
                    }
                }
            }
        }
        .padding(Consts.paddingMedium)
        .background(Consts.cardBackground.opacity(0.9))
        .cornerRadius(Consts.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Consts.cornerRadius)
                .stroke(Consts.border, lineWidth: 1)
        )
    }
}
