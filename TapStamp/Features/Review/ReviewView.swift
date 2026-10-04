import SwiftUI
import SwiftData

/// ふりかえり画面。上部のチップでラベルを切り替える。
struct ReviewView: View {
    @Query(sort: \TapLabel.sortOrder) private var labels: [TapLabel]
    @State private var selectedLabelID: UUID?

    private var selectedLabel: TapLabel? {
        labels.first { $0.id == selectedLabelID }
    }

    var body: some View {
        NavigationStack {
            Group {
                if let label = selectedLabel {
                    LabeledReviewContent(label: label)
                        .id(label.persistentModelID)
                } else {
                    UnlabeledReviewContent()
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                LabelChipRow(labels: labels, selection: $selectedLabelID)
                    .background(.bar)
            }
            .navigationTitle("ふりかえり")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

/// 「とりあえず記録」のふりかえり。
private struct UnlabeledReviewContent: View {
    @Query(filter: #Predicate<TapRecord> { $0.label == nil }, sort: \TapRecord.timestamp, order: .reverse)
    private var records: [TapRecord]

    var body: some View {
        ReviewContent(label: nil, records: records)
    }
}

/// ラベル付きのふりかえり。
private struct LabeledReviewContent: View {
    let label: TapLabel

    @Query private var records: [TapRecord]

    init(label: TapLabel) {
        self.label = label
        let labelID: UUID? = label.id
        _records = Query(
            filter: #Predicate<TapRecord> { $0.label?.id == labelID },
            sort: \TapRecord.timestamp,
            order: .reverse
        )
    }

    var body: some View {
        ReviewContent(label: label, records: records)
    }
}

#Preview {
    ReviewView()
        .modelContainer(try! ModelContainerFactory.makeInMemoryContainer())
}
