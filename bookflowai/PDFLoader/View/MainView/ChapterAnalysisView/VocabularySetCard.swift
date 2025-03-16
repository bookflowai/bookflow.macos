import SwiftUI

struct VocabularySetCard: View {
    let set: VocabularyGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: Consts.paddingSmall) {
            Text(set.theme)
                .foregroundColor(Consts.textPrimary)
                .font(Consts.subtitleFont)
            ForEach(set.words, id: \.word) { word in
                VStack(alignment: .leading, spacing: 2) {
                    Text(word.word)
                        .foregroundColor(Consts.selectedText)
                        .font(Consts.bodyFont)
                        .bold()
                    Text("Translation: \(word.translation)")
                        .foregroundColor(Consts.textSecondary)
                    ForEach(word.examples, id: \.self) { example in
                        Text("\"\(example)\"")
                            .foregroundColor(Consts.textSecondary)
                            .font(Consts.bodyFont)
                    }
                }
                .padding(.leading, Consts.paddingMedium)
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
