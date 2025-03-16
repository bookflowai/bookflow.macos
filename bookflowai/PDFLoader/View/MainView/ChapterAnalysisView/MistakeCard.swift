import SwiftUI

struct MistakeCard: View {
    let mistake: Mistake
    
    var body: some View {
        VStack(alignment: .leading, spacing: Consts.paddingSmall) {
            Text(mistake.description)
                .foregroundColor(Consts.textPrimary)
                .font(Consts.subtitleFont)
            Text("Incorrect: \"\(mistake.incorrect)\"")
                .foregroundColor(Consts.destructive)
                .font(Consts.bodyFont)
            Text("Correct: \"\(mistake.correct)\"")
                .foregroundColor(Consts.selectedText)
                .font(Consts.bodyFont)
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
