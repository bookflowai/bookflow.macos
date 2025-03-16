import SwiftUI

struct TeacherSummaryView: View {
    let teacherSummary: ChapterAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: Consts.paddingMedium) {
            Text("Teacher Summary")
                .foregroundColor(Consts.textPrimary)
                .font(Consts.headerFont)
                .padding(.bottom, Consts.paddingSmall)
            
            Text(teacherSummary.chapterAnalysis.title)
                .foregroundColor(Consts.textPrimary)
                .font(Consts.subtitleFont)
            
            SectionHeader(title: "Theme")
            Text(teacherSummary.chapterAnalysis.theme)
                .foregroundColor(Consts.textPrimary)
                .font(Consts.bodyFont)
            
            SectionHeader(title: "Goals")
            ForEach(teacherSummary.chapterAnalysis.goals, id: \.self) { goal in
                Text("• \(goal)")
                    .foregroundColor(Consts.textPrimary)
                    .font(Consts.bodyFont)
            }
            
            SectionHeader(title: "Overview")
            Text("No overview available")
                .foregroundColor(Consts.textPrimary)
                .font(Consts.bodyFont)
            
            SectionHeader(title: "Linguistic Categories")
            ForEach(teacherSummary.chapterAnalysis.grammar, id: \.name) { category in
                GrammarCard(grammarItem: category)
            }
            
            SectionHeader(title: "Phonetics")
            ForEach(teacherSummary.chapterAnalysis.phonetics, id: \.self) { phonetic in
                PhoneticCard(phoneticItem: phonetic)
            }
            
            SectionHeader(title: "Vocabulary Sets")
            ForEach(teacherSummary.chapterAnalysis.vocabulary, id: \.theme) { set in
                VocabularySetCard(set: set)
            }
            
            SectionHeader(title: "Common Mistakes")
            ForEach(teacherSummary.chapterAnalysis.commonMistakes, id: \.description) { mistake in
                MistakeCard(mistake: mistake)
            }
        }
    }
}
