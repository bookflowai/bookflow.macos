import SwiftUI
import AppKit

struct MainView: View {
    @State private var selectedChapter: String?
    @ObservedObject private var viewModel: PDFLoaderViewModel
    
    init(viewModel: PDFLoaderViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack(spacing: 0) {
            SidebarView(viewModel: viewModel)
            ContentAreaView(viewModel: viewModel)
        }
        .frame(minWidth: 800, minHeight: 600)
        .preferredColorScheme(.dark)
    }
}
