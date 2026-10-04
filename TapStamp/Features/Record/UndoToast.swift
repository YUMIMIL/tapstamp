import SwiftUI

/// 「◯◯を記録しました 14:32｜取り消す」
struct UndoToast: View {
    let toast: RecordToast
    let onUndo: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(toast.text)
                .font(.subheadline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)

            if toast.canUndo {
                Button("取り消す", action: onUndo)
                    .font(.subheadline.weight(.semibold))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal, 16)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack {
        UndoToast(toast: RecordToast(record: nil, text: "薬を記録しました 14:32", canUndo: true, duration: 4)) {}
        UndoToast(toast: RecordToast(record: nil, text: "取り消しました", canUndo: false, duration: 1.5)) {}
    }
}
