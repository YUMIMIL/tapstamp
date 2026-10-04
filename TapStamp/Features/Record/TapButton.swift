import SwiftUI

/// 画面中央の大きな丸ボタン。押すと少し縮み、触覚フィードバックを返す。
struct TapButton: View {
    static let diameter: CGFloat = 240

    let color: Color
    let action: () -> Void

    @State private var tapCount = 0

    var body: some View {
        Button {
            tapCount += 1
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(color.gradient)
                    .shadow(color: color.opacity(0.35), radius: 18, x: 0, y: 10)

                Text("記録")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(width: Self.diameter, height: Self.diameter)
            .contentShape(Circle())
        }
        .buttonStyle(ShrinkButtonStyle())
        .sensoryFeedback(.impact(weight: .medium), trigger: tapCount)
        .accessibilityLabel("記録する")
        .accessibilityHint("今の日時を記録します")
    }
}

/// 押している間だけ少し縮むボタンスタイル。
struct ShrinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    TapButton(color: Color(LabelColor.teal)) {}
}
