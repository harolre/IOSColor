import SwiftUI

struct PaletteColor: Identifiable {
    let id: String
    let name: String
    let color: Color
    let storedColor: StoredColor
}

enum ColorPalettes {
    static let suggested: [PaletteColor] = [
        PaletteColor(
            id: "ginger",
            name: "Pelaje",
            color: Color(red: 0.91, green: 0.43, blue: 0.19),
            storedColor: StoredColor(red: 0.91, green: 0.43, blue: 0.19)
        ),
        PaletteColor(
            id: "cream",
            name: "Luz",
            color: Color(red: 0.98, green: 0.82, blue: 0.57),
            storedColor: StoredColor(red: 0.98, green: 0.82, blue: 0.57)
        ),
        PaletteColor(
            id: "brown",
            name: "Sombra",
            color: Color(red: 0.42, green: 0.25, blue: 0.18),
            storedColor: StoredColor(red: 0.42, green: 0.25, blue: 0.18)
        ),
        PaletteColor(
            id: "pink",
            name: "Interior de oreja",
            color: Color(red: 0.91, green: 0.49, blue: 0.58),
            storedColor: StoredColor(red: 0.91, green: 0.49, blue: 0.58)
        ),
        PaletteColor(
            id: "green",
            name: "Plantas",
            color: Color(red: 0.32, green: 0.57, blue: 0.38),
            storedColor: StoredColor(red: 0.32, green: 0.57, blue: 0.38)
        ),
        PaletteColor(
            id: "details",
            name: "Detalles",
            color: .black,
            storedColor: StoredColor(red: 0, green: 0, blue: 0)
        )
    ]

    static let standard: [PaletteColor] = [
        PaletteColor(
            id: "red",
            name: "Rojo",
            color: .red,
            storedColor: StoredColor(red: 1, green: 0, blue: 0)
        ),
        PaletteColor(
            id: "orange",
            name: "Naranja",
            color: .orange,
            storedColor: StoredColor(red: 1, green: 0.5, blue: 0)
        ),
        PaletteColor(
            id: "yellow",
            name: "Amarillo",
            color: .yellow,
            storedColor: StoredColor(red: 1, green: 1, blue: 0)
        ),
        PaletteColor(
            id: "green",
            name: "Verde",
            color: .green,
            storedColor: StoredColor(red: 0, green: 0.7, blue: 0)
        ),
        PaletteColor(
            id: "blue",
            name: "Azul",
            color: .blue,
            storedColor: StoredColor(red: 0, green: 0.35, blue: 1)
        ),
        PaletteColor(
            id: "purple",
            name: "Morado",
            color: .purple,
            storedColor: StoredColor(red: 0.58, green: 0.2, blue: 0.8)
        ),
        PaletteColor(
            id: "pink",
            name: "Rosa",
            color: .pink,
            storedColor: StoredColor(red: 1, green: 0.42, blue: 0.65)
        ),
        PaletteColor(
            id: "brown",
            name: "Marrón",
            color: .brown,
            storedColor: StoredColor(red: 0.48, green: 0.3, blue: 0.18)
        ),
        PaletteColor(
            id: "black",
            name: "Negro",
            color: .black,
            storedColor: StoredColor(red: 0, green: 0, blue: 0)
        ),
        PaletteColor(
            id: "white",
            name: "Blanco",
            color: .white,
            storedColor: StoredColor(red: 1, green: 1, blue: 1)
        )
    ]
}
