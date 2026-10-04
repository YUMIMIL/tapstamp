import SwiftUI

/// 横スクロールできるセグメント風のラベル切替。nil は「とりあえず記録」。
struct LabelChipRow: View {
    let labels: [TapLabel]
    @Binding var selection: UUID?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "とりあえず記録", color: .unlabeled, isSelected: selection == nil) {
                    selection = nil
                }
                ForEach(labels) { label in
                    chip(title: label.name, color: label.color, isSelected: selection == label.id) {
                        selection = label.id
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private func chip(title: String, color: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color(uiColor: .secondarySystemFill), in: Capsule())
                .foregroundStyle(isSelected ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
