import SwiftUI

struct ChapterAnalysisView: View {
    @ObservedObject var viewModel: PDFLoaderViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: Consts.paddingLarge) {
                if let teacherSummary = viewModel.teacherSummary {
                    TeacherSummaryView(teacherSummary: teacherSummary)
                } else {
                    PlaceholderView(text: "No Teacher Summary Available")
                }
                
                Divider()
                    .background(Consts.border)
                    .padding(.vertical, Consts.paddingSmall)
                
                if let exercises = viewModel.exercises {
                    ExercisesView(exercises: exercises)
                } else {
                    PlaceholderView(text: "No Exercises Available")
                }
            }
            .padding()
            .background(Consts.background)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Consts.background.edgesIgnoringSafeArea(.all))
    }
}

// MARK: - Preview
struct ChapterAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        ChapterAnalysisView(viewModel: PDFLoaderViewModel())
            .frame(width: 600, height: 800)
    }
}
