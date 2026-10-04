import Foundation

/// 初回起動時などに選べるラベルのひな形。
struct LabelTemplate: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let color: LabelColor
    let displayMode: DisplayMode
}

enum TemplateCatalog {
    static let all: [LabelTemplate] = [
        LabelTemplate(id: "medicine", name: "薬", color: .green, displayMode: .frequency),
        LabelTemplate(id: "pain", name: "痛み", color: .coral, displayMode: .frequency),
        LabelTemplate(id: "toilet", name: "トイレ", color: .teal, displayMode: .frequency),
        LabelTemplate(id: "cigarette", name: "タバコ", color: .slate, displayMode: .frequency),
        LabelTemplate(id: "sneeze", name: "くしゃみ", color: .sand, displayMode: .frequency),
        LabelTemplate(id: "water", name: "水分補給", color: .blue, displayMode: .frequency),
        LabelTemplate(id: "coffee", name: "コーヒー", color: .sand, displayMode: .frequency),
        LabelTemplate(id: "sheets", name: "シーツ交換", color: .lavender, displayMode: .interval),
        LabelTemplate(id: "toothbrush", name: "歯ブラシ交換", color: .teal, displayMode: .interval),
        LabelTemplate(id: "haircut", name: "散髪", color: .rose, displayMode: .interval),
    ]
}
