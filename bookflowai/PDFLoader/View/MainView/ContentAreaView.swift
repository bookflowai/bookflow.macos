import SwiftUI
import Combine
import PDFKit

struct ContentAreaView: View {
    @ObservedObject private var viewModel: PDFLoaderViewModel
    
    init(viewModel: PDFLoaderViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: Consts.paddingLarge) {
            Button("Load PDF") {
                Task {
                    await viewModel.loadPDF()
                }
            }
            if viewModel.selectedChapter != nil {
                ChapterAnalysisView(viewModel: viewModel)
            } else {
                Text("Select a chapter to view analysis")
                    .foregroundColor(Consts.textSecondary)
                    .font(Consts.bodyFont)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Consts.background)
    }
}


struct PDFPageView: View {
    let page: PDFPage
    
    var body: some View {
        Image(nsImage: page.thumbnail(of: CGSize(width: 800, height: 1000), for: .artBox))
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
