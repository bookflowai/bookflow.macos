import SwiftUI

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title + ":")
            .foregroundColor(Consts.accent)
            .font(Consts.subtitleFont)
            .padding(.top, Consts.paddingSmall)
    }
}
