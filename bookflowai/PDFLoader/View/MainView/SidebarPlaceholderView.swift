import SwiftUI
import Combine

struct SidebarPlaceholderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Consts.paddingSmall) {
            Rectangle()
                .fill(Consts.placeholderGray)
                .frame(width: Consts.sidebarWidth - 150, height: Consts.lineHeight)
            Rectangle()
                .fill(Consts.placeholderGray)
                .frame(width: Consts.sidebarWidth - 100, height: Consts.lineHeight)
        }
        .frame(maxWidth: .infinity, maxHeight: Consts.placeholderHeight)
        .padding(.vertical, Consts.paddingLarge)
        .padding(.horizontal, Consts.paddingLarge)
        .background(Consts.headerBackground)
        .cornerRadius(Consts.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Consts.cornerRadius)
                .stroke(Consts.border, lineWidth: 0)
        )
        .padding(.horizontal, Consts.paddingMedium)
    }
}
