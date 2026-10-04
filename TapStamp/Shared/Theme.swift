import SwiftUI
import UIKit

/// アプリ全体の配色と角丸。生成りの背景に白いカードを置く、落ち着いたトーン。
enum AppTheme {
    /// 画面の背景（生成り）
    static let background = Color(light: "#F7F5F0", dark: "#1C1B19")
    /// カードの背景
    static let card = Color(light: "#FFFFFF", dark: "#2A2927")
    /// 入力欄などの枠線
    static let border = Color(light: "#E6E2DA", dark: "#3C3936")
    /// 操作色（スチールブルー）
    static let accent = Color(hex: "#5B7FA6") ?? .blue
    /// 完了・成功（セージグリーン）
    static let success = Color(hex: "#6FA287") ?? .green
    /// 控えめな塗り（未選択のチップなど）
    static let subtleFill = Color(light: "#ECE9E3", dark: "#36332F")

    static let cornerRadius: CGFloat = 16
    static let fieldCornerRadius: CGFloat = 14
}

extension Color {
    /// ライト／ダークで別の hex を使う色。
    init(light: String, dark: String) {
        self.init(uiColor: UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(hex: hex) ?? .systemBackground
        })
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var text = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("#") { text.removeFirst() }
        guard text.count == 6, let value = UInt32(text, radix: 16) else { return nil }
        self.init(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}

/// 白いカード（角丸＋薄い影）。
struct CardBackground: ViewModifier {
    var padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                AppTheme.card,
                in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
            )
            .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 2)
    }
}

extension View {
    func cardStyle(padding: CGFloat = 16) -> some View {
        modifier(CardBackground(padding: padding))
    }

    /// 生成りの背景を敷き、List / Form の標準背景を消す。
    func themedScreenBackground() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(AppTheme.background.ignoresSafeArea())
    }
}
