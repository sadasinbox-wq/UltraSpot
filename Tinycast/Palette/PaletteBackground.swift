import SwiftUI

struct PaletteBackground: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale
    @Environment(\.metrics) private var metrics
    let window: NSWindow?

    /// Glass draws its own rim and elevation, so only the scrimmed dress trades the shadow away.
    private var usesSystemShadow: Bool {
        metrics.style.usesGlassSurface || colorScheme != .dark || settings.paletteTransparency <= 0
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: metrics.radius.panel, style: .continuous)
    }

    var body: some View {
        surface
            .onChange(of: window, initial: true) { applyShadow() }
            .onChange(of: usesSystemShadow) { applyShadow() }
    }

    @ViewBuilder private var surface: some View {
        if metrics.style.usesGlassSurface {
            // The dialog's recipe, on the panel: one system material over the scrim's density.
            Color.clear
                .background(Theme.Colors.panelScrim(transparency: settings.paletteTransparency), in: shape)
                .glassEffect(.regular, in: shape)
        } else {
            Theme.Colors.panelScrim(transparency: settings.paletteTransparency)
                .background(VisualEffectView())
                .overlay {
                    if settings.paletteTransparency != 0 {
                        if usesSystemShadow {
                            shape.strokeBorder(
                                Theme.Colors.panelEdgeHighlight(transparency: settings.paletteTransparency),
                                lineWidth: Theme.Size.hairline / displayScale
                            )
                            .allowsHitTesting(false)
                        } else {
                            shape.strokeBorder(
                                Theme.Colors.panelEdgeGradient(transparency: settings.paletteTransparency),
                                lineWidth: Theme.Size.hairline
                            )
                            .allowsHitTesting(false)
                        }
                    }
                }
        }
    }

    private func applyShadow() {
        guard let window, window.hasShadow != usesSystemShadow else { return }
        window.hasShadow = usesSystemShadow
        window.invalidateShadow()
    }
}
