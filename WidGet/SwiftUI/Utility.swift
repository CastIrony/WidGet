//
//  Utility.swift
//  WidGet
//
//  Created by Joel Bernstein on 9/18/20.
//

import SwiftUI
import UIKit

enum AppConstants {
    public static let suiteName = "group.com.castirony.widget"
}

public extension View {
    func applyIf<T: View>(_ condition: @autoclosure () -> Bool, apply: (Self) -> T) -> AnyView {
        return condition() ? AnyView(apply(self)) : AnyView(self)
    }
}

struct InsideWidgetKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var insideWidget: Bool {
        get { self[InsideWidgetKey.self] }
        set { self[InsideWidgetKey.self] = newValue }
    }
}

struct ClearView: View {
    var body: some View {
        Color.black.opacity(0.0001)
    }
}

extension View {
    func measureLabelWidth() -> some View {
        return modifier(LabelWidthModifier())
    }
}

struct DragInProgressPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        let new = nextValue()

        value = value || new
    }
}

struct HandleDragInProgressPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        let new = nextValue()

        value = value || new
    }
}

struct LabelWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct LabelWidthModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader {
            Color.clear.preference(key: LabelWidthPreferenceKey.self, value: $0.size.width)
        }
    }

    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}

extension View {
    func measureToolbarHeight() -> some View {
        return modifier(ToolbarHeightModifier())
    }
}

struct ToolbarHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct UndoStackCountPreferenceKey: PreferenceKey {
    static var defaultValue: Int = 0

    static func reduce(value: inout Int, nextValue: () -> Int) {
        value = max(value, nextValue())
    }
}

struct RedoStackCountPreferenceKey: PreferenceKey {
    static var defaultValue: Int = 0

    static func reduce(value: inout Int, nextValue: () -> Int) {
        value = max(value, nextValue())
    }
}

struct ToolbarHeightModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader {
            Color.clear.preference(key: ToolbarHeightPreferenceKey.self, value: $0.size.height)
        }
    }

    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}

extension Notification.Name {
    static let widgetEditorUndo = Notification.Name("widget-editor-undo")
    static let widgetEditorRedo = Notification.Name("widget-editor-redo")
    static let widgetEditorRevert = Notification.Name("widget-editor-revert")
}

struct EditorSnapKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

struct WidgetColorSchemeKey: EnvironmentKey {
    static let defaultValue: ColorScheme = .light
}

extension EnvironmentValues {
    var editorSnap: Bool {
        get { self[EditorSnapKey.self] }
        set { self[EditorSnapKey.self] = newValue }
    }

    var widgetColorScheme: ColorScheme {
        get { self[WidgetColorSchemeKey.self] }
        set { self[WidgetColorSchemeKey.self] = newValue }
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []

        return filter { seen.insert($0).inserted }
    }
}

let systemColorsLight =
    [
        (color: RGBColor(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1).hsb, name: "Black"),
        (color: RGBColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1).hsb, name: "White"),

        (color: RGBColor(red: 255 / 255, green: 45 / 255, blue: 85 / 255, alpha: 1).hsb, name: "System Pink"),
        (color: RGBColor(red: 255 / 255, green: 59 / 255, blue: 48 / 255, alpha: 1).hsb, name: "System Red"),
        (color: RGBColor(red: 255 / 255, green: 149 / 255, blue: 0 / 255, alpha: 1).hsb, name: "System Orange"),
        (color: RGBColor(red: 255 / 255, green: 204 / 255, blue: 0 / 255, alpha: 1).hsb, name: "System Yellow"),
        (color: RGBColor(red: 52 / 255, green: 199 / 255, blue: 89 / 255, alpha: 1).hsb, name: "System Green"),
        (color: RGBColor(red: 90 / 255, green: 200 / 255, blue: 250 / 255, alpha: 1).hsb, name: "System Teal"),
        (color: RGBColor(red: 0 / 255, green: 122 / 255, blue: 255 / 255, alpha: 1).hsb, name: "System Blue"),
        (color: RGBColor(red: 88 / 255, green: 86 / 255, blue: 214 / 255, alpha: 1).hsb, name: "System Indigo "),
        (color: RGBColor(red: 175 / 255, green: 82 / 255, blue: 222 / 255, alpha: 1).hsb, name: "System Purple"),
    ]

let systemColorsDark =
    [
        (color: RGBColor(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1).hsb, name: "System Black"),
        (color: RGBColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1).hsb, name: "System White"),

        (color: RGBColor(red: 255 / 255, green: 55 / 255, blue: 95 / 255, alpha: 1).hsb, name: "System Pink "),
        (color: RGBColor(red: 255 / 255, green: 69 / 255, blue: 58 / 255, alpha: 1).hsb, name: "System Red"),
        (color: RGBColor(red: 255 / 255, green: 159 / 255, blue: 10 / 255, alpha: 1).hsb, name: "System Orange"),
        (color: RGBColor(red: 255 / 255, green: 214 / 255, blue: 10 / 255, alpha: 1).hsb, name: "System Yellow"),
        (color: RGBColor(red: 48 / 255, green: 209 / 255, blue: 88 / 255, alpha: 1).hsb, name: "System Green"),
        (color: RGBColor(red: 100 / 255, green: 210 / 255, blue: 255 / 255, alpha: 1).hsb, name: "System Teal "),
        (color: RGBColor(red: 10 / 255, green: 132 / 255, blue: 255 / 255, alpha: 1).hsb, name: "System Blue"),
        (color: RGBColor(red: 94 / 255, green: 92 / 255, blue: 230 / 255, alpha: 1).hsb, name: "System Indigo"),
        (color: RGBColor(red: 191 / 255, green: 90 / 255, blue: 242 / 255, alpha: 1).hsb, name: "System Purple "),
    ]

let systemGrays =
    [
        (color: RGBColor(red: 28 / 255, green: 28 / 255, blue: 30 / 255, alpha: 1).hsb, name: "System Gray 1"),
        (color: RGBColor(red: 44 / 255, green: 44 / 255, blue: 46 / 255, alpha: 1).hsb, name: "System Gray 2"),
        (color: RGBColor(red: 58 / 255, green: 58 / 255, blue: 60 / 255, alpha: 1).hsb, name: "System Gray 3"),
        (color: RGBColor(red: 72 / 255, green: 72 / 255, blue: 74 / 255, alpha: 1).hsb, name: "System Gray 4"),
        (color: RGBColor(red: 99 / 255, green: 99 / 255, blue: 102 / 255, alpha: 1).hsb, name: "System Gray 5"),
        (color: RGBColor(red: 142 / 255, green: 142 / 255, blue: 147 / 255, alpha: 1).hsb, name: "System Gray 6"),
        (color: RGBColor(red: 174 / 255, green: 174 / 255, blue: 178 / 255, alpha: 1).hsb, name: "System Gray 7"),
        (color: RGBColor(red: 199 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1).hsb, name: "System Gray 8"),
        (color: RGBColor(red: 209 / 255, green: 209 / 255, blue: 214 / 255, alpha: 1).hsb, name: "System Gray 9"),
        (color: RGBColor(red: 229 / 255, green: 229 / 255, blue: 234 / 255, alpha: 1).hsb, name: "System Gray 10"),
        (color: RGBColor(red: 242 / 255, green: 242 / 255, blue: 247 / 255, alpha: 1).hsb, name: "System Gray 11"),
    ]

let x11Colors =
    [
        (color: RGBColor(red: 240 / 255, green: 128 / 255, blue: 128 / 255, alpha: 1).hsb, name: "Light Coral"),
        (color: RGBColor(red: 250 / 255, green: 128 / 255, blue: 114 / 255, alpha: 1).hsb, name: "Salmon"),
        (color: RGBColor(red: 233 / 255, green: 150 / 255, blue: 122 / 255, alpha: 1).hsb, name: "Dark Salmon"),
        (color: RGBColor(red: 255 / 255, green: 160 / 255, blue: 122 / 255, alpha: 1).hsb, name: "Light Salmon"),
        (color: RGBColor(red: 205 / 255, green: 92 / 255, blue: 92 / 255, alpha: 1).hsb, name: "Indian Red"),
        (color: RGBColor(red: 220 / 255, green: 20 / 255, blue: 60 / 255, alpha: 1).hsb, name: "Crimson"),
        (color: RGBColor(red: 255 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1).hsb, name: "Red"),
        (color: RGBColor(red: 178 / 255, green: 34 / 255, blue: 34 / 255, alpha: 1).hsb, name: "Fire Brick"),
        (color: RGBColor(red: 139 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1).hsb, name: "Dark Red"),
        (color: RGBColor(red: 255 / 255, green: 192 / 255, blue: 203 / 255, alpha: 1).hsb, name: "Pink"),
        (color: RGBColor(red: 255 / 255, green: 182 / 255, blue: 193 / 255, alpha: 1).hsb, name: "Light Pink"),
        (color: RGBColor(red: 255 / 255, green: 105 / 255, blue: 180 / 255, alpha: 1).hsb, name: "Hot Pink"),
        (color: RGBColor(red: 255 / 255, green: 20 / 255, blue: 147 / 255, alpha: 1).hsb, name: "Deep Pink"),
        (color: RGBColor(red: 199 / 255, green: 21 / 255, blue: 133 / 255, alpha: 1).hsb, name: "Medium Violet Red"),
        (color: RGBColor(red: 219 / 255, green: 112 / 255, blue: 147 / 255, alpha: 1).hsb, name: "Pale Violet Red"),
        (color: RGBColor(red: 255 / 255, green: 127 / 255, blue: 80 / 255, alpha: 1).hsb, name: "Coral"),
        (color: RGBColor(red: 255 / 255, green: 99 / 255, blue: 71 / 255, alpha: 1).hsb, name: "Tomato"),
        (color: RGBColor(red: 255 / 255, green: 69 / 255, blue: 0 / 255, alpha: 1).hsb, name: "Orange Red"),
        (color: RGBColor(red: 255 / 255, green: 140 / 255, blue: 0 / 255, alpha: 1).hsb, name: "Dark Orange"),
        (color: RGBColor(red: 255 / 255, green: 165 / 255, blue: 0 / 255, alpha: 1).hsb, name: "Orange"),
        (color: RGBColor(red: 255 / 255, green: 215 / 255, blue: 0 / 255, alpha: 1).hsb, name: "Gold"),
        (color: RGBColor(red: 255 / 255, green: 255 / 255, blue: 0 / 255, alpha: 1).hsb, name: "Yellow"),
        (color: RGBColor(red: 255 / 255, green: 255 / 255, blue: 224 / 255, alpha: 1).hsb, name: "Light Yellow"),
        (color: RGBColor(red: 255 / 255, green: 250 / 255, blue: 205 / 255, alpha: 1).hsb, name: "Lemon Chiffon"),
        (color: RGBColor(red: 250 / 255, green: 250 / 255, blue: 210 / 255, alpha: 1).hsb, name: "Light Goldenrod Yellow"),
        (color: RGBColor(red: 255 / 255, green: 239 / 255, blue: 213 / 255, alpha: 1).hsb, name: "Papaya Whip"),
        (color: RGBColor(red: 255 / 255, green: 228 / 255, blue: 181 / 255, alpha: 1).hsb, name: "Moccasin"),
        (color: RGBColor(red: 255 / 255, green: 218 / 255, blue: 185 / 255, alpha: 1).hsb, name: "Peach Puff"),
        (color: RGBColor(red: 238 / 255, green: 232 / 255, blue: 170 / 255, alpha: 1).hsb, name: "Pale Goldenrod"),
        (color: RGBColor(red: 240 / 255, green: 230 / 255, blue: 140 / 255, alpha: 1).hsb, name: "Khaki"),
        (color: RGBColor(red: 189 / 255, green: 183 / 255, blue: 107 / 255, alpha: 1).hsb, name: "Dark Khaki"),
        (color: RGBColor(red: 230 / 255, green: 230 / 255, blue: 250 / 255, alpha: 1).hsb, name: "Lavender"),
        (color: RGBColor(red: 216 / 255, green: 191 / 255, blue: 216 / 255, alpha: 1).hsb, name: "Thistle"),
        (color: RGBColor(red: 221 / 255, green: 160 / 255, blue: 221 / 255, alpha: 1).hsb, name: "Plum"),
        (color: RGBColor(red: 238 / 255, green: 130 / 255, blue: 238 / 255, alpha: 1).hsb, name: "Violet"),
        (color: RGBColor(red: 218 / 255, green: 112 / 255, blue: 214 / 255, alpha: 1).hsb, name: "Orchid"),
        (color: RGBColor(red: 255 / 255, green: 0 / 255, blue: 255 / 255, alpha: 1).hsb, name: "Fuchsia"),
        (color: RGBColor(red: 255 / 255, green: 0 / 255, blue: 255 / 255, alpha: 1).hsb, name: "Magenta"),
        (color: RGBColor(red: 186 / 255, green: 85 / 255, blue: 211 / 255, alpha: 1).hsb, name: "Medium Orchid"),
        (color: RGBColor(red: 147 / 255, green: 112 / 255, blue: 219 / 255, alpha: 1).hsb, name: "Medium Purple"),
        (color: RGBColor(red: 138 / 255, green: 43 / 255, blue: 226 / 255, alpha: 1).hsb, name: "Blue Violet"),
        (color: RGBColor(red: 148 / 255, green: 0 / 255, blue: 211 / 255, alpha: 1).hsb, name: "Dark Violet"),
        (color: RGBColor(red: 153 / 255, green: 50 / 255, blue: 204 / 255, alpha: 1).hsb, name: "Dark Orchid"),
        (color: RGBColor(red: 139 / 255, green: 0 / 255, blue: 139 / 255, alpha: 1).hsb, name: "Dark Magenta"),
        (color: RGBColor(red: 128 / 255, green: 0 / 255, blue: 128 / 255, alpha: 1).hsb, name: "Purple"),
        (color: RGBColor(red: 102 / 255, green: 51 / 255, blue: 153 / 255, alpha: 1).hsb, name: "Rebecca Purple"),
        (color: RGBColor(red: 75 / 255, green: 0 / 255, blue: 130 / 255, alpha: 1).hsb, name: "Indigo"),
        (color: RGBColor(red: 123 / 255, green: 104 / 255, blue: 238 / 255, alpha: 1).hsb, name: "Medium Slate Blue"),
        (color: RGBColor(red: 106 / 255, green: 90 / 255, blue: 205 / 255, alpha: 1).hsb, name: "Slate Blue"),
        (color: RGBColor(red: 72 / 255, green: 61 / 255, blue: 139 / 255, alpha: 1).hsb, name: "Dark Slate Blue"),
        (color: RGBColor(red: 173 / 255, green: 255 / 255, blue: 47 / 255, alpha: 1).hsb, name: "Green Yellow"),
        (color: RGBColor(red: 127 / 255, green: 255 / 255, blue: 0 / 255, alpha: 1).hsb, name: "Chartreuse"),
        (color: RGBColor(red: 124 / 255, green: 252 / 255, blue: 0 / 255, alpha: 1).hsb, name: "Lawn Green"),
        (color: RGBColor(red: 0 / 255, green: 255 / 255, blue: 0 / 255, alpha: 1).hsb, name: "Lime"),
        (color: RGBColor(red: 50 / 255, green: 205 / 255, blue: 50 / 255, alpha: 1).hsb, name: "Lime Green"),
        (color: RGBColor(red: 152 / 255, green: 251 / 255, blue: 152 / 255, alpha: 1).hsb, name: "Pale Green"),
        (color: RGBColor(red: 144 / 255, green: 238 / 255, blue: 144 / 255, alpha: 1).hsb, name: "Light Green"),
        (color: RGBColor(red: 0 / 255, green: 250 / 255, blue: 154 / 255, alpha: 1).hsb, name: "Medium Spring Green"),
        (color: RGBColor(red: 0 / 255, green: 255 / 255, blue: 127 / 255, alpha: 1).hsb, name: "Spring Green"),
        (color: RGBColor(red: 60 / 255, green: 179 / 255, blue: 113 / 255, alpha: 1).hsb, name: "Medium Sea Green"),
        (color: RGBColor(red: 46 / 255, green: 139 / 255, blue: 87 / 255, alpha: 1).hsb, name: "Sea Green"),
        (color: RGBColor(red: 34 / 255, green: 139 / 255, blue: 34 / 255, alpha: 1).hsb, name: "Forest Green"),
        (color: RGBColor(red: 0 / 255, green: 128 / 255, blue: 0 / 255, alpha: 1).hsb, name: "Green"),
        (color: RGBColor(red: 0 / 255, green: 100 / 255, blue: 0 / 255, alpha: 1).hsb, name: "Dark Green"),
        (color: RGBColor(red: 154 / 255, green: 205 / 255, blue: 50 / 255, alpha: 1).hsb, name: "Yellow Green"),
        (color: RGBColor(red: 107 / 255, green: 142 / 255, blue: 35 / 255, alpha: 1).hsb, name: "Olive Drab"),
        (color: RGBColor(red: 128 / 255, green: 128 / 255, blue: 0 / 255, alpha: 1).hsb, name: "Olive"),
        (color: RGBColor(red: 85 / 255, green: 107 / 255, blue: 47 / 255, alpha: 1).hsb, name: "Dark Olive Green"),
        (color: RGBColor(red: 102 / 255, green: 205 / 255, blue: 170 / 255, alpha: 1).hsb, name: "Medium Aquamarine"),
        (color: RGBColor(red: 143 / 255, green: 188 / 255, blue: 143 / 255, alpha: 1).hsb, name: "Dark Sea Green"),
        (color: RGBColor(red: 32 / 255, green: 178 / 255, blue: 170 / 255, alpha: 1).hsb, name: "Light Sea Green"),
        (color: RGBColor(red: 0 / 255, green: 139 / 255, blue: 139 / 255, alpha: 1).hsb, name: "Dark Cyan"),
        (color: RGBColor(red: 0 / 255, green: 128 / 255, blue: 128 / 255, alpha: 1).hsb, name: "Teal"),
        (color: RGBColor(red: 0 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1).hsb, name: "Aqua"),
        (color: RGBColor(red: 0 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1).hsb, name: "Cyan"),
        (color: RGBColor(red: 224 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1).hsb, name: "Light Cyan"),
        (color: RGBColor(red: 175 / 255, green: 238 / 255, blue: 238 / 255, alpha: 1).hsb, name: "Pale Turquoise"),
        (color: RGBColor(red: 127 / 255, green: 255 / 255, blue: 212 / 255, alpha: 1).hsb, name: "Aquamarine"),
        (color: RGBColor(red: 64 / 255, green: 224 / 255, blue: 208 / 255, alpha: 1).hsb, name: "Turquoise"),
        (color: RGBColor(red: 72 / 255, green: 209 / 255, blue: 204 / 255, alpha: 1).hsb, name: "Medium Turquoise"),
        (color: RGBColor(red: 0 / 255, green: 206 / 255, blue: 209 / 255, alpha: 1).hsb, name: "Dark Turquoise"),
        (color: RGBColor(red: 95 / 255, green: 158 / 255, blue: 160 / 255, alpha: 1).hsb, name: "Cadet Blue"),
        (color: RGBColor(red: 70 / 255, green: 130 / 255, blue: 180 / 255, alpha: 1).hsb, name: "Steel Blue"),
        (color: RGBColor(red: 176 / 255, green: 196 / 255, blue: 222 / 255, alpha: 1).hsb, name: "Light Steel Blue"),
        (color: RGBColor(red: 176 / 255, green: 224 / 255, blue: 230 / 255, alpha: 1).hsb, name: "Powder Blue"),
        (color: RGBColor(red: 173 / 255, green: 216 / 255, blue: 230 / 255, alpha: 1).hsb, name: "Light Blue"),
        (color: RGBColor(red: 135 / 255, green: 206 / 255, blue: 235 / 255, alpha: 1).hsb, name: "Sky Blue"),
        (color: RGBColor(red: 135 / 255, green: 206 / 255, blue: 250 / 255, alpha: 1).hsb, name: "Light Sky Blue"),
        (color: RGBColor(red: 0 / 255, green: 191 / 255, blue: 255 / 255, alpha: 1).hsb, name: "Deep Sky Blue"),
        (color: RGBColor(red: 30 / 255, green: 144 / 255, blue: 255 / 255, alpha: 1).hsb, name: "Dodger Blue"),
        (color: RGBColor(red: 100 / 255, green: 149 / 255, blue: 237 / 255, alpha: 1).hsb, name: "Cornflower Blue"),
        (color: RGBColor(red: 65 / 255, green: 105 / 255, blue: 225 / 255, alpha: 1).hsb, name: "Royal Blue"),
        (color: RGBColor(red: 0 / 255, green: 0 / 255, blue: 255 / 255, alpha: 1).hsb, name: "Blue"),
        (color: RGBColor(red: 0 / 255, green: 0 / 255, blue: 205 / 255, alpha: 1).hsb, name: "Medium Blue"),
        (color: RGBColor(red: 0 / 255, green: 0 / 255, blue: 139 / 255, alpha: 1).hsb, name: "Dark Blue"),
        (color: RGBColor(red: 0 / 255, green: 0 / 255, blue: 128 / 255, alpha: 1).hsb, name: "Navy"),
        (color: RGBColor(red: 25 / 255, green: 25 / 255, blue: 112 / 255, alpha: 1).hsb, name: "Midnight Blue"),
        (color: RGBColor(red: 255 / 255, green: 248 / 255, blue: 220 / 255, alpha: 1).hsb, name: "Cornsilk"),
        (color: RGBColor(red: 255 / 255, green: 235 / 255, blue: 205 / 255, alpha: 1).hsb, name: "Blanched Almond"),
        (color: RGBColor(red: 255 / 255, green: 228 / 255, blue: 196 / 255, alpha: 1).hsb, name: "Bisque"),
        (color: RGBColor(red: 255 / 255, green: 222 / 255, blue: 173 / 255, alpha: 1).hsb, name: "Navajo White"),
        (color: RGBColor(red: 245 / 255, green: 222 / 255, blue: 179 / 255, alpha: 1).hsb, name: "Wheat"),
        (color: RGBColor(red: 222 / 255, green: 184 / 255, blue: 135 / 255, alpha: 1).hsb, name: "Burly Wood"),
        (color: RGBColor(red: 210 / 255, green: 180 / 255, blue: 140 / 255, alpha: 1).hsb, name: "Tan"),
        (color: RGBColor(red: 188 / 255, green: 143 / 255, blue: 143 / 255, alpha: 1).hsb, name: "Rosy Brown"),
        (color: RGBColor(red: 244 / 255, green: 164 / 255, blue: 96 / 255, alpha: 1).hsb, name: "Sandy Brown"),
        (color: RGBColor(red: 218 / 255, green: 165 / 255, blue: 32 / 255, alpha: 1).hsb, name: "Goldenrod"),
        (color: RGBColor(red: 184 / 255, green: 134 / 255, blue: 11 / 255, alpha: 1).hsb, name: "Dark Goldenrod"),
        (color: RGBColor(red: 205 / 255, green: 133 / 255, blue: 63 / 255, alpha: 1).hsb, name: "Peru"),
        (color: RGBColor(red: 210 / 255, green: 105 / 255, blue: 30 / 255, alpha: 1).hsb, name: "Chocolate"),
        (color: RGBColor(red: 139 / 255, green: 69 / 255, blue: 19 / 255, alpha: 1).hsb, name: "Saddle Brown"),
        (color: RGBColor(red: 160 / 255, green: 82 / 255, blue: 45 / 255, alpha: 1).hsb, name: "Sienna"),
        (color: RGBColor(red: 165 / 255, green: 42 / 255, blue: 42 / 255, alpha: 1).hsb, name: "Brown"),
        (color: RGBColor(red: 128 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1).hsb, name: "Maroon"),
        (color: RGBColor(red: 255 / 255, green: 250 / 255, blue: 250 / 255, alpha: 1).hsb, name: "Snow"),
        (color: RGBColor(red: 240 / 255, green: 255 / 255, blue: 240 / 255, alpha: 1).hsb, name: "Honeydew"),
        (color: RGBColor(red: 245 / 255, green: 255 / 255, blue: 250 / 255, alpha: 1).hsb, name: "Mint Cream"),
        (color: RGBColor(red: 240 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1).hsb, name: "Azure"),
        (color: RGBColor(red: 240 / 255, green: 248 / 255, blue: 255 / 255, alpha: 1).hsb, name: "Alice Blue"),
        (color: RGBColor(red: 248 / 255, green: 248 / 255, blue: 255 / 255, alpha: 1).hsb, name: "Ghost White"),
        (color: RGBColor(red: 245 / 255, green: 245 / 255, blue: 245 / 255, alpha: 1).hsb, name: "White Smoke"),
        (color: RGBColor(red: 255 / 255, green: 245 / 255, blue: 238 / 255, alpha: 1).hsb, name: "Seashell"),
        (color: RGBColor(red: 245 / 255, green: 245 / 255, blue: 220 / 255, alpha: 1).hsb, name: "Beige"),
        (color: RGBColor(red: 253 / 255, green: 245 / 255, blue: 230 / 255, alpha: 1).hsb, name: "Old Lace"),
        (color: RGBColor(red: 255 / 255, green: 250 / 255, blue: 240 / 255, alpha: 1).hsb, name: "Floral White"),
        (color: RGBColor(red: 255 / 255, green: 255 / 255, blue: 240 / 255, alpha: 1).hsb, name: "Ivory"),
        (color: RGBColor(red: 250 / 255, green: 235 / 255, blue: 215 / 255, alpha: 1).hsb, name: "Antique White"),
        (color: RGBColor(red: 250 / 255, green: 240 / 255, blue: 230 / 255, alpha: 1).hsb, name: "Linen"),
        (color: RGBColor(red: 255 / 255, green: 240 / 255, blue: 245 / 255, alpha: 1).hsb, name: "Lavender Blush"),
        (color: RGBColor(red: 255 / 255, green: 228 / 255, blue: 225 / 255, alpha: 1).hsb, name: "Misty Rose"),
        (color: RGBColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1).hsb, name: "Gainsboro"),
        (color: RGBColor(red: 211 / 255, green: 211 / 255, blue: 211 / 255, alpha: 1).hsb, name: "Light Gray"),
        (color: RGBColor(red: 211 / 255, green: 211 / 255, blue: 211 / 255, alpha: 1).hsb, name: "Light Grey"),
        (color: RGBColor(red: 192 / 255, green: 192 / 255, blue: 192 / 255, alpha: 1).hsb, name: "Silver"),
        (color: RGBColor(red: 169 / 255, green: 169 / 255, blue: 169 / 255, alpha: 1).hsb, name: "Dark Gray"),
        (color: RGBColor(red: 169 / 255, green: 169 / 255, blue: 169 / 255, alpha: 1).hsb, name: "Dark Grey"),
        (color: RGBColor(red: 128 / 255, green: 128 / 255, blue: 128 / 255, alpha: 1).hsb, name: "Gray"),
        (color: RGBColor(red: 128 / 255, green: 128 / 255, blue: 128 / 255, alpha: 1).hsb, name: "Grey"),
        (color: RGBColor(red: 105 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1).hsb, name: "Dim Gray"),
        (color: RGBColor(red: 105 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1).hsb, name: "Dim Grey"),
        (color: RGBColor(red: 119 / 255, green: 136 / 255, blue: 153 / 255, alpha: 1).hsb, name: "Light Slate Gray"),
        (color: RGBColor(red: 119 / 255, green: 136 / 255, blue: 153 / 255, alpha: 1).hsb, name: "Light Slate Grey"),
        (color: RGBColor(red: 112 / 255, green: 128 / 255, blue: 144 / 255, alpha: 1).hsb, name: "Slate Gray"),
        (color: RGBColor(red: 112 / 255, green: 128 / 255, blue: 144 / 255, alpha: 1).hsb, name: "Slate Grey"),
        (color: RGBColor(red: 47 / 255, green: 79 / 255, blue: 79 / 255, alpha: 1).hsb, name: "Dark Slate Gray"),
        (color: RGBColor(red: 47 / 255, green: 79 / 255, blue: 79 / 255, alpha: 1).hsb, name: "Dark Slate Grey"),
    ]

extension UIImage {
    /// Fix image orientaton to protrait up
    func fixedOrientation() -> UIImage? {
        guard imageOrientation != UIImage.Orientation.up else {
            // This is default orientation, don't need to do anything
            return copy() as? UIImage
        }

        guard let cgImage = self.cgImage else {
            // CGImage is not available
            return nil
        }

        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil // Not able to create CGContext
        }

        var transform = CGAffineTransform.identity

        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }

        // Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }

        ctx.concatenate(transform)

        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }

        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}

func pastelPaletteColors(in cgImage: CGImage) -> [HSBColor]? {
    let colorCount = (cgImage.height - 300) / 240

    guard colorCount > 0, cgImage.width == 960, cgImage.height == colorCount * 240 + 300 else { return nil }

    let pixelData = cgImage.dataProvider!.data
    let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

    var foundColors: [HSBColor] = []

    for colorIndex in 0 ..< colorCount {
        let pixelOffsetA = (960 * (290 + colorIndex * 240) + 180) * 4
        let pixelOffsetB = (960 * (310 + colorIndex * 240) + 180) * 4
        let pixelOffsetC = (960 * (290 + ((colorIndex + 1) % colorCount) * 240) + 180) * 4

        let colorA = RGBColor(red: CGFloat(data[pixelOffsetA + 0]) / CGFloat(255.0), green: CGFloat(data[pixelOffsetA + 1]) / CGFloat(255.0), blue: CGFloat(data[pixelOffsetA + 2]) / CGFloat(255.0), alpha: 1)
        let colorB = RGBColor(red: CGFloat(data[pixelOffsetB + 0]) / CGFloat(255.0), green: CGFloat(data[pixelOffsetB + 1]) / CGFloat(255.0), blue: CGFloat(data[pixelOffsetB + 2]) / CGFloat(255.0), alpha: 1)
        let colorC = RGBColor(red: CGFloat(data[pixelOffsetC + 0]) / CGFloat(255.0), green: CGFloat(data[pixelOffsetC + 1]) / CGFloat(255.0), blue: CGFloat(data[pixelOffsetC + 2]) / CGFloat(255.0), alpha: 1)

        if colorA == colorB, colorB != colorC || colorCount == 1 {
            foundColors.append(colorA.hsb)
        }
    }

    return foundColors.count > 0 ? foundColors : nil
}
