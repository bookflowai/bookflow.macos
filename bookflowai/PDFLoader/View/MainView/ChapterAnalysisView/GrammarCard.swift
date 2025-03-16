import SwiftUI

struct GrammarCard: View {
    let grammarItem: GrammarItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: Consts.paddingSmall) {
            Text("Grammar")
                .foregroundColor(Consts.textPrimary)
                .font(Consts.subtitleFont)
            
            Text(grammarItem.name)
                .foregroundColor(Consts.selectedText)
                .font(Consts.bodyFont)
                .bold()
            
            Text(grammarItem.explanation)
                .foregroundColor(Consts.textPrimary)
                .font(Consts.bodyFont)
            
            ForEach(grammarItem.examples, id: \.text) { example in
                VStack(alignment: .leading, spacing: 2) {
                    Text("\"\(example.text)\"")
                        .foregroundColor(Consts.selectedText)
                        .font(Consts.bodyFont)
                    Text(example.translation)
                        .foregroundColor(Consts.textPrimary)
                        .font(Consts.bodyFont)
                        .italic()
                    Text("Notes: \(example.notes)")
                        .foregroundColor(Consts.accent)
                        .font(Consts.bodyFont)
                }
                .padding(.top, 4)
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
