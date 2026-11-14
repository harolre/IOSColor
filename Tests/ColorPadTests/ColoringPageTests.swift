import XCTest
@testable import ColorPad

final class ColoringPageTests: XCTestCase {
    func testSampleLibraryHasAllDifficultyLevels() {
        let difficulties = Set(ColoringPage.samples.map(\.difficulty))

        XCTAssertEqual(difficulties, Set(ColoringDifficulty.allCases))
    }

    func testSamplePagesAreFreeForInitialMVP() {
        XCTAssertTrue(ColoringPage.samples.allSatisfy(\.isFree))
    }

    func testProgressRepositoryPersistsPencilAndRegionProgress() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ColorPadTests.\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let repository = FileProgressRepository(directory: directory)
        let expected = ColoringProgress(
            pencilDrawingData: Data([1, 2, 3]),
            regionColors: [
                "head": StoredColor(red: 0.9, green: 0.4, blue: 0.2)
            ]
        )

        repository.saveProgress(expected, for: "garden-cat")

        XCTAssertEqual(repository.loadProgress(for: "garden-cat"), expected)
    }

    func testProgressIsScopedToColoringPage() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ColorPadTests.\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let repository = FileProgressRepository(directory: directory)
        repository.saveProgress(
            ColoringProgress(regionColors: [
                "head": StoredColor(red: 1, green: 0, blue: 0)
            ]),
            for: "garden-cat"
        )

        XCTAssertEqual(repository.loadProgress(for: "quiet-forest"), .empty)
    }
}
