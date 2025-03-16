import SwiftUI

struct PhoneticCard: View {
    let phoneticItem: PhoneticItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: Consts.paddingSmall) {
            Text(phoneticItem.name)
                .font(Consts.subtitleFont)
                .foregroundColor(Consts.textPrimary)
            Text(phoneticItem.explanation)
                .font(Consts.bodyFont)
                .foregroundColor(Consts.textPrimary)
            ForEach(phoneticItem.examples, id: \.self) { example in
                VStack(alignment: .leading, spacing: 4) {
                    Text("Example: \(example.text)")
                        .font(Consts.bodyFont)
                    Text("Transcription: \(example.transcription)")
                        .font(Consts.bodyFont.italic())
                    Text("Notes: \(example.notes)")
                        .font(Consts.bodyFont)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Consts.cardBackground)
        .cornerRadius(8)
    }
}
