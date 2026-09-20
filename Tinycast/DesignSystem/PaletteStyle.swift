import CoreGraphics

/// Which dress the palette wears; `InterfaceMetrics` resolves the geometry each one states.
enum PaletteStyle: String, CaseIterable, Identifiable, Sendable {
    /// Tinycast's own: a scrim over behind-window vibrancy, at `Theme`'s own proportions.
    case tinycast
    /// The system launcher's: one Liquid Glass surface, narrower, with a larger search row.
    case spotlight

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tinycast: "Tinycast"
        case .spotlight: "Spotlight"
        }
    }

    /// The main surface takes system glass instead of `panelScrim` over `VisualEffectView`.
    var usesGlassSurface: Bool { self == .spotlight }
}
