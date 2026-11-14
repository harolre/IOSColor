import Foundation

protocol ProgressRepository {
    func loadProgress(for pageID: String) -> ColoringProgress
    func saveProgress(_ progress: ColoringProgress, for pageID: String)
}

struct FileProgressRepository: ProgressRepository {
    private let directory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(directory: URL? = nil) {
        self.directory = directory
            ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("ColorPad/Progress", isDirectory: true)
    }

    func loadProgress(for pageID: String) -> ColoringProgress {
        guard
            let data = try? Data(contentsOf: fileURL(for: pageID)),
            let progress = try? decoder.decode(ColoringProgress.self, from: data)
        else {
            return .empty
        }
        return progress
    }

    func saveProgress(_ progress: ColoringProgress, for pageID: String) {
        do {
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
            let data = try encoder.encode(progress)
            try data.write(to: fileURL(for: pageID), options: .atomic)
        } catch {
            // A later edit can retry the save; never crash the coloring session on disk errors.
        }
    }

    private func fileURL(for pageID: String) -> URL {
        let safeID = pageID.unicodeScalars
            .map { CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_")).contains($0) ? String($0) : "_" }
            .joined()
        return directory.appendingPathComponent("\(safeID).json", isDirectory: false)
    }
}
