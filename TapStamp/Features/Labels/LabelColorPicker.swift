import SwiftUI

/// プリセット 8 色から選ぶ。
struct LabelColorPicker: View {
    @Binding var selection: LabelColor

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(LabelColor.allCases) { item in
                Button {
                    selection = item
                } label: {
                    Circle()
                        .fill(Color(item))
                        .frame(width: 44, height: 44)
                        .overlay {
                            if selection == item {
                                Image(systemName: "checkmark")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.name)
                .accessibilityAddTraits(selection == item ? .isSelected : [])
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    @Previewable @State var color: LabelColor = .blue
    Form {
        LabelColorPicker(selection: $color)
    }
}
