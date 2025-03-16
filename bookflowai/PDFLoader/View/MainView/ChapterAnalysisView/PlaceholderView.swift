import SwiftUI

struct PlaceholderView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .foregroundColor(Consts.placeholderGray)
            .font(Consts.bodyFont)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Consts.cardBackground.opacity(0.8))
            .cornerRadius(Consts.cornerRadius)
    }
}
