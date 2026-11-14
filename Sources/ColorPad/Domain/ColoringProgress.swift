import Foundation

struct StoredColor: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double = 1
}

struct ColoringProgress: Codable, Equatable {
    var pencilDrawingData: Data?
    var regionColors: [String: StoredColor] = [:]

    static let empty = ColoringProgress()
}
