import AppKit
import SwiftUI

/// Against the real `Theme`, so neither dress can drift from the literals it is meant to state.
@main
@MainActor
struct PaletteStyleTests {
    static var failures = 0
    static var passes = 0

    static func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
        if condition() {
            passes += 1
        } else {
            failures += 1
            print("FAIL: \(message)")
        }
    }

    static func expect(_ actual: CGFloat, _ expected: CGFloat, _ message: String) {
        expect(abs(actual - expected) < 0.001, "\(message) — got \(actual), want \(expected)")
    }

    static func main() {
        theDefaultDressIsTheme()
        theSpotlightDressIsItsOwnTokens()
        theDressLeavesEverythingElseAlone()
        theDressScalesAndRounds()
        derivationsHold()
        theEnumIsWellFormed()

        print("\(passes) passed, \(failures) failed")
        if failures > 0 { exit(1) }
    }

    /// `.tinycast` is what the app shipped before the dress existed, member by member.
    static func theDefaultDressIsTheme() {
        let m = InterfaceMetrics.standard
        expect(m.style == .tinycast, "the default dress is Tinycast's own")
        expect(m.size.panelWidth, Theme.Size.panelWidth, "size.panelWidth")
        expect(m.size.panelHeight, Theme.Size.panelHeight, "size.panelHeight")
        expect(m.size.headerIconSlot, Theme.Size.headerIconSlot, "size.headerIconSlot")
        expect(m.spacing.rowVertical, Theme.Spacing.rowVertical, "spacing.rowVertical")
        expect(m.radius.panel, Theme.Radius.panel, "radius.panel")
        expect(
            m.typography.searchFieldSize, Theme.Typography.searchFieldSize,
            "typography.searchFieldSize")
    }

    /// Every `Theme.Spotlight` token, so one added there cannot sit unread.
    static func theSpotlightDressIsItsOwnTokens() {
        let m = InterfaceMetrics(scale: 1, style: .spotlight)
        expect(m.size.panelWidth, Theme.Spotlight.panelWidth, "spotlight size.panelWidth")
        expect(m.size.panelHeight, Theme.Spotlight.panelHeight, "spotlight size.panelHeight")
        expect(
            m.size.headerIconSlot, Theme.Spotlight.headerIconSlot, "spotlight size.headerIconSlot")
        expect(
            m.spacing.rowVertical, Theme.Spotlight.rowVertical, "spotlight spacing.rowVertical")
        expect(m.radius.panel, Theme.Spotlight.panelRadius, "spotlight radius.panel")
        expect(
            m.typography.searchFieldSize, Theme.Spotlight.searchFieldSize,
            "spotlight typography.searchFieldSize")

        for (name, value) in dressed(m) {
            expect(
                value != dressed(.standard).first(where: { $0.0 == name })?.1,
                "\(name) actually changes under the Spotlight dress")
        }
    }

    /// A dress is geometry the palette owns; nothing shared with Settings or a menu may move.
    static func theDressLeavesEverythingElseAlone() {
        let tinycast = InterfaceMetrics.standard
        let spotlight = InterfaceMetrics(scale: 1, style: .spotlight)
        let shared: [(String, KeyPath<InterfaceMetrics, CGFloat>)] = [
            ("spacing.md", \.spacing.md),
            ("spacing.sm", \.spacing.sm),
            ("spacing.xxl", \.spacing.xxl),
            // The tile is shared with menus and cards; only the slack around it is the dress's.
            ("size.rowIcon", \.size.rowIcon),
            ("radius.row", \.radius.row),
            ("radius.menuPanel", \.radius.menuPanel),
            // The search row's own band: a dress may retune the query, never the bar holding it.
            ("size.headerHeight", \.size.headerHeight),
            ("size.headerPadding", \.size.headerPadding),
            ("size.compactHeight", \.size.compactHeight),
            ("size.bottomBarHeight", \.size.bottomBarHeight),
            ("size.barButtonHeight", \.size.barButtonHeight),
            ("size.menuIcon", \.size.menuIcon),
            ("size.menuWidth", \.size.menuWidth),
            ("size.keyCap", \.size.keyCap),
            ("size.dialogWidth", \.size.dialogWidth),
            ("size.hudWidth", \.size.hudWidth)
        ]
        for (name, path) in shared {
            expect(spotlight[keyPath: path], tinycast[keyPath: path], "\(name) is dress-neutral")
        }
    }

    /// The dress picks the literal and the size scales it, so a styled token still lands whole.
    static func theDressScalesAndRounds() {
        for size in InterfaceSize.allCases {
            let m = InterfaceMetrics(scale: size.scale, style: .spotlight)
            for (name, value) in dressed(m) {
                expect(
                    value == value.rounded(),
                    "\(name) lands on a whole point at \(size.rawValue) — got \(value)")
            }
            expect(
                m.size.panelWidth, (Theme.Spotlight.panelWidth * size.scale).rounded(),
                "the Spotlight panel scales at \(size.rawValue)")
            expect(
                m.typography.searchFieldSize,
                (Theme.Spotlight.searchFieldSize * size.scale).rounded(),
                "the Spotlight query scales at \(size.rawValue)")
        }
    }

    /// The compact bar is derived from the dressed header, not from `Theme`'s own.
    static func derivationsHold() {
        for style in PaletteStyle.allCases {
            for size in InterfaceSize.allCases {
                let m = InterfaceMetrics(scale: size.scale, style: style)
                expect(
                    m.size.compactHeight, m.size.headerHeight + m.size.headerPadding * 2,
                    "the compact bar is the header in symmetric slack — \(style.rawValue)"
                        + " at \(size.rawValue)")
            }
        }
    }

    static func theEnumIsWellFormed() {
        expect(PaletteStyle(rawValue: "raycast") == nil, "an unknown raw value is rejected")
        expect(
            PaletteStyle.allCases.count == Set(PaletteStyle.allCases.map(\.title)).count,
            "every style has its own title")
        expect(
            PaletteStyle.allCases.filter(\.usesGlassSurface) == [.spotlight],
            "only the Spotlight dress takes the main surface to glass")
    }

    /// Every length a dress is allowed to move, paired with its name.
    static func dressed(_ m: InterfaceMetrics) -> [(String, CGFloat)] {
        [
            ("size.panelWidth", m.size.panelWidth),
            ("size.panelHeight", m.size.panelHeight),
            ("size.headerIconSlot", m.size.headerIconSlot),
            ("spacing.rowVertical", m.spacing.rowVertical),
            ("radius.panel", m.radius.panel),
            ("typography.searchFieldSize", m.typography.searchFieldSize)
        ]
    }
}
