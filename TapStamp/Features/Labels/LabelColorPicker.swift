import SwiftUI

/// プリセット色を横一列から選ぶ。選択中は同色のリングで囲む。
struct LabelColorPicker: View {
    @Binding var selection: LabelColor

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(LabelColor.allCases) { item in
                    let isSelected = selection == item
                    Button {
                        withAnimation(.snappy) {
                            selection = item
                        }
                    } label: {
                        Circle()
                            .fill(Color(item))
                            .frame(width: 40, height: 40)
                            .padding(4)
                            .overlay(
                                Circle()
                                    .stroke(Color(item), lineWidth: 2)
                                    .opacity(isSelected ? 1 : 0)
                            )
                            .scaleEffect(isSelected ? 1.08 : 1)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(item.name)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
    }
}

private struct LabelColorPickerPreview: View {
    @State private var color: LabelColor = .coral

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            LabelColorPicker(selection: $color)
                .padding()
        }
    }
}

#Preview {
    LabelColorPickerPreview()
}
