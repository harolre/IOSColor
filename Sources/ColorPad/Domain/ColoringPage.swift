import Foundation

enum ColoringDifficulty: String, CaseIterable, Identifiable, Hashable {
    case easy = "Fácil"
    case medium = "Medio"
    case advanced = "Avanzado"

    var id: String { rawValue }
}

struct ColoringPage: Identifiable, Hashable {
    let id: String
    let title: String
    let category: String
    let difficulty: ColoringDifficulty
    let isFree: Bool

    static let samples = [
        ColoringPage(
            id: "garden-cat",
            title: "Gato en el jardín",
            category: "Animales",
            difficulty: .easy,
            isFree: true
        ),
        ColoringPage(
            id: "quiet-forest",
            title: "Bosque tranquilo",
            category: "Naturaleza",
            difficulty: .medium,
            isFree: true
        ),
        ColoringPage(
            id: "city-pattern",
            title: "Ciudad de patrones",
            category: "Adultos",
            difficulty: .advanced,
            isFree: true
        )
    ]
}
