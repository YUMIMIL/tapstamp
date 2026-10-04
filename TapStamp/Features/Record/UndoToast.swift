import SwiftUI

/// 「✓ 記録しました 14:32 ｜ 取り消す」
struct UndoToast: View {
    let toast: RecordToast
    let onUndo: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.success)
                    .frame(width: 28, height: 28)
                Image(systemName: "checkmark")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.white)
            }

            Text(toast.text)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)

            if toast.canUndo {
                Rectangle()
                    .fill(AppTheme.border)
                    .frame(width: 1, height: 22)
                Button("取り消す", action: onUndo)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.accent)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            AppTheme.card,
            in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
        )
        .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 4)
        .padding(.horizontal, 20)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        VStack {
            UndoToast(toast: RecordToast(record: nil, text: "記録しました 14:32", canUndo: true, duration: 4)) {}
            UndoToast(toast: RecordToast(record: nil, text: "取り消しました", canUndo: false, duration: 1.5)) {}
        }
    }
}
