import SwiftUI

extension Binding where Value == Bool {
    /// Optional な状態から「nil でなければ true」の Bool Binding を作る。
    /// `.alert(isPresented:)` などに Optional の状態を渡したいときに使う。
    init<T>(isPresent source: Binding<T?>) {
        self.init(
            get: { source.wrappedValue != nil },
            set: { newValue in
                if !newValue { source.wrappedValue = nil }
            }
        )
    }
}
