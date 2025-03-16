import SwiftUI
import Combine

struct SidebarItemView: View {
    let splitInfo: SplitInfo
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(splitInfo.sectionName)")
                .foregroundColor(isSelected ? Consts.selectedText : Consts.textPrimary)
                .font(Consts.bodyFont)
                .lineLimit(nil)
            if let exercises = splitInfo.relatedExercises, let relatedExcercisesPageRange = splitInfo.relatedExcercisesPageRange {
                Text("Exercises: \(exercises) \(relatedExcercisesPageRange)")
                    .foregroundColor(isSelected ? Consts.selectedText : Consts.textPrimary)
                    .font(Consts.bodyFont)
                    .lineLimit(nil)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, Consts.paddingLarge)
        .padding(.horizontal, Consts.paddingLarge)
        .background(isSelected ? Consts.selectionHighlight : Consts.headerBackground)
        .cornerRadius(Consts.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Consts.cornerRadius)
                .stroke(Consts.border, lineWidth: isSelected ? 1 : 0)
        )
        .contentShape(Rectangle())
        .padding(.horizontal, Consts.paddingMedium)
        .onTapGesture {
            action()
        }
    }
}
