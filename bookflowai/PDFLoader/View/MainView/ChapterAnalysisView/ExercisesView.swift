import SwiftUI

struct ExercisesView: View {
    let exercises: ExercisesResponse
    @State private var userAnswers: [Int: String] = [:]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Consts.paddingMedium) {
            Text("Exercises")
                .foregroundColor(Consts.textPrimary)
                .font(Consts.headerFont)
                .padding(.bottom, Consts.paddingSmall)
            
            ForEach(exercises.exercises, id: \.exerciseId) { exercise in
                ExerciseCard(exercise: exercise, userAnswer: $userAnswers[exercise.exerciseId])
            }
        }
    }
}
