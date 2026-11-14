import PencilKit
import SwiftUI
import UIKit

private enum PaintingMode: String, CaseIterable, Identifiable, Hashable {
    case freeDrawing = "Dibujo libre"
    case fill = "Rellenar"

    var id: String { rawValue }
}

private enum CatRegion: String, CaseIterable, Identifiable {
    case body
    case tail
    case head
    case leftEar
    case rightEar

    var id: String { rawValue }

    func path(in rect: CGRect) -> Path {
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
        }

        switch self {
        case .body:
            return Path(ellipseIn: CGRect(
                x: rect.minX + rect.width * 0.25,
                y: rect.minY + rect.height * 0.48,
                width: rect.width * 0.50,
                height: rect.height * 0.36
            ))
        case .tail:
            var path = Path()
            path.move(to: point(0.68, 0.70))
            path.addCurve(to: point(0.82, 0.59), control1: point(0.85, 0.75), control2: point(0.90, 0.67))
            path.addCurve(to: point(0.74, 0.53), control1: point(0.78, 0.51), control2: point(0.73, 0.55))
            path.addCurve(to: point(0.75, 0.63), control1: point(0.69, 0.58), control2: point(0.75, 0.59))
            path.addCurve(to: point(0.68, 0.70), control1: point(0.82, 0.67), control2: point(0.73, 0.75))
            path.closeSubpath()
            return path
        case .head:
            return Path(ellipseIn: CGRect(
                x: rect.minX + rect.width * 0.32,
                y: rect.minY + rect.height * 0.20,
                width: rect.width * 0.36,
                height: rect.height * 0.34
            ))
        case .leftEar:
            var path = Path()
            path.move(to: point(0.34, 0.29))
            path.addLine(to: point(0.34, 0.10))
            path.addLine(to: point(0.47, 0.23))
            path.closeSubpath()
            return path
        case .rightEar:
            var path = Path()
            path.move(to: point(0.53, 0.23))
            path.addLine(to: point(0.66, 0.10))
            path.addLine(to: point(0.66, 0.29))
            path.closeSubpath()
            return path
        }
    }
}

struct ColoringCanvasView: View {
    let page: ColoringPage

    @State private var progress: ColoringProgress
    @State private var selectedColor = ColorPalettes.standard[0]
    @State private var selectedMode: PaintingMode = .freeDrawing
    @State private var showingSuggestedColors = false
    @State private var pendingSave: DispatchWorkItem?

    private let repository: ProgressRepository

    init(
        page: ColoringPage,
        repository: ProgressRepository = FileProgressRepository()
    ) {
        self.page = page
        self.repository = repository
        _progress = State(initialValue: repository.loadProgress(for: page.id))
    }

    private var palette: [PaletteColor] {
        showingSuggestedColors ? ColorPalettes.suggested : ColorPalettes.standard
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                modePicker
                palettePanel

                GeometryReader { geometry in
                    let drawingRect = CGRect(origin: .zero, size: geometry.size)

                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.08), radius: 14, y: 5)

                        catArtwork(in: drawingRect)

                        if selectedMode == .freeDrawing {
                            PencilDrawingSurface(progress: progress, selectedColor: selectedColor) { drawing in
                                progress.pencilDrawingData = drawing.dataRepresentation()
                                saveProgress()
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                        } else {
                            Color.clear
                                .contentShape(Rectangle())
                                .gesture(
                                    SpatialTapGesture()
                                        .onEnded { event in
                                            fillRegion(at: event.location, in: drawingRect)
                                        }
                                )
                                .accessibilityLabel("Toca una región para rellenarla")
                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    }
                }
                .aspectRatio(0.88, contentMode: .fit)
                .padding(.horizontal, 12)

                HStack(spacing: 8) {
                    Image(systemName: selectedMode == .fill ? "hand.tap" : "applepencil")
                        .foregroundStyle(Color.accentColor)
                    Text(selectedMode == .fill
                         ? "Toca una zona del dibujo para colorearla."
                         : "Dibuja con el dedo o el Apple Pencil.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 12)
            }
            .frame(maxWidth: 760)
            .padding(.top, 12)
            .frame(maxWidth: .infinity)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(page.title)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear(perform: flushProgress)
    }

    private var modePicker: some View {
        Picker("Modo de pintura", selection: $selectedMode) {
            ForEach(PaintingMode.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    private var palettePanel: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text(showingSuggestedColors ? "Colores sugeridos" : "Todos los colores")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button {
                    showingSuggestedColors.toggle()
                    if !palette.contains(where: { $0.id == selectedColor.id }) {
                        selectedColor = palette[0]
                    }
                } label: {
                    Label(
                        showingSuggestedColors ? "Ver todos" : "Ver sugeridos",
                        systemImage: "slider.horizontal.3"
                    )
                    .font(.caption.weight(.medium))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(palette) { swatch in
                        Button {
                            selectedColor = swatch
                        } label: {
                            VStack(spacing: 5) {
                                Circle()
                                    .fill(swatch.color)
                                    .frame(width: 36, height: 36)
                                    .overlay {
                                        Circle().stroke(.primary.opacity(0.15), lineWidth: 1)
                                    }
                                    .overlay {
                                        if selectedColor.id == swatch.id {
                                            Image(systemName: "checkmark")
                                                .font(.caption.bold())
                                                .foregroundStyle(swatch.id == "white" ? .black : .white)
                                        }
                                    }
                                Text(swatch.name)
                                    .font(.caption2)
                                    .foregroundStyle(.primary)
                            }
                            .frame(minWidth: 48)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(swatch.name)
                        .accessibilityAddTraits(selectedColor.id == swatch.id ? .isSelected : [])
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    @ViewBuilder
    private func catArtwork(in rect: CGRect) -> some View {
        ZStack {
            ForEach(CatRegion.allCases) { region in
                region.path(in: rect)
                    .fill(color(for: region))
            }

            CatLineArt()
                .stroke(Color.black, style: StrokeStyle(lineWidth: 2.7, lineCap: .round, lineJoin: .round))
                .allowsHitTesting(false)
        }
    }

    private func fillRegion(at point: CGPoint, in rect: CGRect) {
        guard let region = CatRegion.allCases.reversed().first(where: { $0.path(in: rect).contains(point) }) else {
            return
        }
        progress.regionColors[region.rawValue] = selectedColor.storedColor
        saveProgress()
    }

    private func color(for region: CatRegion) -> Color {
        guard let stored = progress.regionColors[region.rawValue] else { return .white }
        return Color(
            .sRGB,
            red: stored.red,
            green: stored.green,
            blue: stored.blue,
            opacity: stored.opacity
        )
    }

    private func saveProgress() {
        pendingSave?.cancel()
        let progressSnapshot = progress
        let repository = repository
        let pageID = page.id
        let work = DispatchWorkItem {
            repository.saveProgress(progressSnapshot, for: pageID)
        }
        pendingSave = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: work)
    }

    private func flushProgress() {
        pendingSave?.cancel()
        pendingSave = nil
        repository.saveProgress(progress, for: page.id)
    }
}

private struct CatLineArt: Shape {
    func path(in rect: CGRect) -> Path {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
        }

        var path = Path()
        // Main body and the curled tail.
        path.move(to: p(0.30, 0.61))
        path.addCurve(to: p(0.70, 0.61), control1: p(0.30, 0.43), control2: p(0.70, 0.43))
        path.addCurve(to: p(0.59, 0.82), control1: p(0.70, 0.77), control2: p(0.67, 0.82))
        path.addLine(to: p(0.40, 0.82))
        path.addCurve(to: p(0.30, 0.61), control1: p(0.33, 0.82), control2: p(0.30, 0.76))

        path.move(to: p(0.68, 0.70))
        path.addCurve(to: p(0.82, 0.59), control1: p(0.85, 0.75), control2: p(0.90, 0.67))
        path.addCurve(to: p(0.74, 0.53), control1: p(0.78, 0.51), control2: p(0.73, 0.55))
        path.addCurve(to: p(0.75, 0.63), control1: p(0.69, 0.58), control2: p(0.75, 0.59))
        path.addCurve(to: p(0.68, 0.70), control1: p(0.82, 0.67), control2: p(0.73, 0.75))
        path.closeSubpath()

        // Head, ears, face and whiskers.
        path.addEllipse(in: CGRect(
            x: rect.minX + rect.width * 0.32,
            y: rect.minY + rect.height * 0.20,
            width: rect.width * 0.36,
            height: rect.height * 0.34
        ))
        path.move(to: p(0.34, 0.29))
        path.addLine(to: p(0.34, 0.10))
        path.addLine(to: p(0.47, 0.23))
        path.move(to: p(0.53, 0.23))
        path.addLine(to: p(0.66, 0.10))
        path.addLine(to: p(0.66, 0.29))

        path.addEllipse(in: CGRect(x: p(0.42, 0.34).x, y: p(0.42, 0.34).y, width: rect.width * 0.025, height: rect.height * 0.035))
        path.addEllipse(in: CGRect(x: p(0.56, 0.34).x, y: p(0.56, 0.34).y, width: rect.width * 0.025, height: rect.height * 0.035))
        path.move(to: p(0.48, 0.43))
        path.addLine(to: p(0.52, 0.43))
        path.addLine(to: p(0.50, 0.46))
        path.addLine(to: p(0.48, 0.43))

        path.move(to: p(0.42, 0.45))
        path.addLine(to: p(0.29, 0.42))
        path.move(to: p(0.42, 0.48))
        path.addLine(to: p(0.29, 0.49))
        path.move(to: p(0.58, 0.45))
        path.addLine(to: p(0.71, 0.42))
        path.move(to: p(0.58, 0.48))
        path.addLine(to: p(0.71, 0.49))
        return path
    }
}

private struct PencilDrawingSurface: UIViewRepresentable {
    let progress: ColoringProgress
    let selectedColor: PaletteColor
    let onDrawingChanged: (PKDrawing) -> Void

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.drawingPolicy = .anyInput
        canvas.delegate = context.coordinator
        canvas.tool = inkingTool
        if let data = progress.pencilDrawingData,
           let drawing = try? PKDrawing(data: data) {
            canvas.drawing = drawing
        }
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        canvas.tool = inkingTool
        guard let data = progress.pencilDrawingData,
              let storedDrawing = try? PKDrawing(data: data),
              storedDrawing.dataRepresentation() != canvas.drawing.dataRepresentation()
        else {
            return
        }
        canvas.drawing = storedDrawing
    }

    private var inkingTool: PKInkingTool {
        let color = selectedColor.storedColor
        return PKInkingTool(
            .pen,
            color: UIColor(
                red: CGFloat(color.red),
                green: CGFloat(color.green),
                blue: CGFloat(color.blue),
                alpha: CGFloat(color.opacity)
            ),
            width: 6
        )
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onDrawingChanged: onDrawingChanged)
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        private let onDrawingChanged: (PKDrawing) -> Void

        init(onDrawingChanged: @escaping (PKDrawing) -> Void) {
            self.onDrawingChanged = onDrawingChanged
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            onDrawingChanged(canvasView.drawing)
        }
    }
}

#Preview {
    NavigationStack {
        ColoringCanvasView(page: ColoringPage.samples[0])
    }
}
