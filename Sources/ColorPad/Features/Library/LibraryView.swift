import SwiftUI

struct LibraryView: View {
    @State private var selectedDifficulty: ColoringDifficulty?

    private var pages: [ColoringPage] {
        guard let selectedDifficulty else { return ColoringPage.samples }
        return ColoringPage.samples.filter { $0.difficulty == selectedDifficulty }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Elige un dibujo y dale vida con tus colores.")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    difficultyPicker

                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 155), spacing: 14)],
                        spacing: 14
                    ) {
                        ForEach(pages) { page in
                            pageCard(page)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Color-Pad")
        }
    }

    private var difficultyPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                filterButton(title: "Todos", difficulty: nil)
                ForEach(ColoringDifficulty.allCases) { difficulty in
                    filterButton(title: difficulty.rawValue, difficulty: difficulty)
                }
            }
        }
    }

    private func filterButton(title: String, difficulty: ColoringDifficulty?) -> some View {
        let isSelected = selectedDifficulty == difficulty
        return Button {
            selectedDifficulty = difficulty
        } label: {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.12))
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func pageCard(_ page: ColoringPage) -> some View {
        let card = VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.accentColor.opacity(0.10))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        Image(systemName: page.id == "garden-cat" ? "pawprint.fill" : "paintpalette")
                            .font(.system(size: 38))
                            .foregroundStyle(Color.accentColor)
                    }
                if page.id != "garden-cat" {
                    Text("Próximamente")
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(.regularMaterial, in: Capsule())
                        .padding(8)
                }
            }

            Text(page.title)
                .font(.headline)
                .lineLimit(2)

            HStack {
                Text(page.difficulty.rawValue)
                Spacer()
                if page.isFree {
                    Text("Gratis")
                        .foregroundStyle(.green)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(10)
        .background(.background, in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)

        if page.id == "garden-cat" {
            return AnyView(
                NavigationLink {
                    ColoringCanvasView(page: page)
                } label: {
                    card
                }
                .buttonStyle(.plain)
            )
        } else {
            return AnyView(card)
        }
    }
}

#Preview {
    LibraryView()
}
