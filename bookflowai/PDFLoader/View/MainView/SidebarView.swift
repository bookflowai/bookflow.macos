import SwiftUI
import Combine

struct SidebarView: View {
    @ObservedObject private var viewModel: PDFLoaderViewModel
    @State private var isLoading: Bool = true
    
    init(viewModel: PDFLoaderViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        let contentView = VStack(alignment: .leading, spacing: 0) {
            let title = Text("Contenido")
                .font(Consts.titleFont)
                .foregroundColor(Consts.textPrimary)
                .padding(.vertical, Consts.paddingLarge)
                .padding(.horizontal, Consts.paddingMedium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Consts.headerBackground)
            
            let scrollContent = ScrollView {
                VStack(alignment: .leading, spacing: Consts.paddingSmall) {
                    if viewModel.isLoading {
                        ForEach(0..<10) { _ in
                            SidebarPlaceholderView()
                        }
                    } else {
                        ForEach(viewModel.tocSplitInfo, id: \.partNumber) { splitInfo in
                            SidebarItemView(
                                splitInfo: splitInfo,
                                isSelected: viewModel.selectedChapter?.title == splitInfo.sectionName,
                                action: {
                                    Task {
                                        await viewModel.selectChapter(PDFOutlineItem(
                                            title: splitInfo.sectionName,
                                            pageNumber: splitInfo.partNumber
                                        ))
                                    }
                                    
                                }
                            )
                        }
                    }
                }
                .padding(.vertical, Consts.paddingSmall)
            }
                .frame(width: Consts.sidebarWidth)
                .background(Consts.headerBackground)
            
            let loadButton = Button(action: { Task { await viewModel.loadPDF() } }) {
                Text("Load PDF")
                    .font(Consts.buttonFont)
                    .foregroundColor(Consts.textPrimary)
                    .padding(.horizontal, Consts.paddingMedium)
                    .padding(.vertical, Consts.paddingSmall)
                    .background(Consts.primary)
                    .cornerRadius(Consts.cornerRadius)
                    .frame(height: Consts.buttonHeight)
            }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Rectangle())
                .padding(.horizontal, Consts.paddingSmall)
                .padding(.bottom, Consts.paddingLarge)
            title
            scrollContent
            Spacer()
            loadButton
        }
        
        return contentView
            .frame(width: Consts.sidebarWidth)
            .background(Consts.background)
            .onAppear {
                Task {
                    await viewModel.loadPDF()
                }
            }
    }
}
