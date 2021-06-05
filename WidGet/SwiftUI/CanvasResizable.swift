//
//  CanvasResizable.swift
//
//
//  Created by Bernstein, Joel on 7/10/20.
//

import SwiftUI

struct CanvasResizable: ViewModifier {
    let coordinateSpace: String

    @Binding var frame: CGRect
    @Binding var isSelected: Bool

    let snapGuidesX: [SnapGuide]
    let snapGuidesY: [SnapGuide]

    let cornerRadius: CGFloat

    @State var projectedSnapGuidesX: [SnapGuide] = []
    @State var projectedSnapGuidesY: [SnapGuide] = []

    @State var initialDragDelta: CGSize?
    @State var isDragging = false
    @State var handlesAreDragging = false

    @Binding var activeGuideIDX: String?
    @Binding var activeGuideIDY: String?

    let snapGuidesActive: Bool

    @Environment(\.widgetColorScheme) var colorScheme
    @Environment(\.editorSnap) var editorSnap

    func body(content: Content) -> some View {
        ZStack {
            content
                .frame(width: frame.width, height: frame.height, alignment: .top)
                .background(ClearView())
                .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color.accentColor.opacity(snapGuidesActive ? 0.4 : 0)))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .position(CGPoint(x: frame.midX, y: frame.midY))
                .gesture(
                    DragGesture(minimumDistance: 2, coordinateSpace: .named("canvas"))
                        .onChanged {
                            value in

                            if initialDragDelta == nil {
                                initialDragDelta = CGSize(width: value.startLocation.x - frame.midX, height: value.startLocation.y - frame.midY)

                                projectSnapGuides()

                                isDragging = true
                                isSelected = true
                            }

                            withAnimation(.spring(response: 0.25)) {
                                updateDragPosition(newValue: value.location)
                            }
                        }
                        .onEnded {
                            _ in

                            initialDragDelta = nil
                            isDragging = false
                            activeGuideIDX = nil
                            activeGuideIDY = nil
                        }
                        .simultaneously(with: TapGesture().onEnded { isSelected.toggle() })
                )

            if isSelected {
                Group {
                    HandleBorder(frame: $frame, color: colorScheme == .light ? .black : .white, lineWidth: 4)

                    if isDragging {
                        Rectangle()
                            .fill(Color.gray)
                            .opacity(0.2)
                            .frame(width: frame.width, height: frame.height, alignment: .center)
                            .position(CGPoint(x: frame.midX, y: frame.midY))
                            .allowsHitTesting(false)
                    }

                    Group {
                        ResizeHandle(frame: $frame, handleAlignment: Alignment(horizontal: .leading, vertical: .top), activeGuideIDX: $activeGuideIDX, activeGuideIDY: $activeGuideIDY, snapGuidesX: snapGuidesX, snapGuidesY: snapGuidesY)
                        ResizeHandle(frame: $frame, handleAlignment: Alignment(horizontal: .center, vertical: .top), activeGuideIDX: $activeGuideIDX, activeGuideIDY: $activeGuideIDY, snapGuidesX: snapGuidesX, snapGuidesY: snapGuidesY)
                        ResizeHandle(frame: $frame, handleAlignment: Alignment(horizontal: .trailing, vertical: .top), activeGuideIDX: $activeGuideIDX, activeGuideIDY: $activeGuideIDY, snapGuidesX: snapGuidesX, snapGuidesY: snapGuidesY)

                        ResizeHandle(frame: $frame, handleAlignment: Alignment(horizontal: .leading, vertical: .center), activeGuideIDX: $activeGuideIDX, activeGuideIDY: $activeGuideIDY, snapGuidesX: snapGuidesX, snapGuidesY: snapGuidesY)
                        ResizeHandle(frame: $frame, handleAlignment: Alignment(horizontal: .trailing, vertical: .center), activeGuideIDX: $activeGuideIDX, activeGuideIDY: $activeGuideIDY, snapGuidesX: snapGuidesX, snapGuidesY: snapGuidesY)

                        ResizeHandle(frame: $frame, handleAlignment: Alignment(horizontal: .leading, vertical: .bottom), activeGuideIDX: $activeGuideIDX, activeGuideIDY: $activeGuideIDY, snapGuidesX: snapGuidesX, snapGuidesY: snapGuidesY)
                        ResizeHandle(frame: $frame, handleAlignment: Alignment(horizontal: .center, vertical: .bottom), activeGuideIDX: $activeGuideIDX, activeGuideIDY: $activeGuideIDY, snapGuidesX: snapGuidesX, snapGuidesY: snapGuidesY)
                        ResizeHandle(frame: $frame, handleAlignment: Alignment(horizontal: .trailing, vertical: .bottom), activeGuideIDX: $activeGuideIDX, activeGuideIDY: $activeGuideIDY, snapGuidesX: snapGuidesX, snapGuidesY: snapGuidesY)
                    }

                    HandleBorder(frame: $frame, color: colorScheme == .light ? .white : .black, lineWidth: 2)
                }
                .accessibilityElement(children: .contain)
                .accessibility(label: Text("Widget Frame"))
                .transition(.identity)
            }
        }
        .onPreferenceChange(HandleDragInProgressPreferenceKey.self) {
            handlesAreDragging = $0
        }
        .preference(key: DragInProgressPreferenceKey.self, value: isDragging || handlesAreDragging)
    }

    func projectSnapGuides() {
        guard editorSnap == true else {
            projectedSnapGuidesX = []
            projectedSnapGuidesY = []

            return
        }

        projectedSnapGuidesX = snapGuidesX
        projectedSnapGuidesY = snapGuidesY

        for snapGuide in snapGuidesX {
            let projectedPosition1 = snapGuide.position + 0.5 * frame.width
            let projectedPosition2 = snapGuide.position - 0.5 * frame.width

            projectedSnapGuidesX.append(SnapGuide(position: projectedPosition1, id: snapGuide.id, strength: snapGuide.strength, alwaysVisible: false, projected: true))
            projectedSnapGuidesX.append(SnapGuide(position: projectedPosition2, id: snapGuide.id, strength: snapGuide.strength, alwaysVisible: false, projected: true))
        }

        for snapGuide in snapGuidesY {
            let projectedPosition1 = snapGuide.position + 0.5 * frame.height
            let projectedPosition2 = snapGuide.position - 0.5 * frame.height

            projectedSnapGuidesY.append(SnapGuide(position: projectedPosition1, id: snapGuide.id, strength: snapGuide.strength, alwaysVisible: false, projected: true))
            projectedSnapGuidesY.append(SnapGuide(position: projectedPosition2, id: snapGuide.id, strength: snapGuide.strength, alwaysVisible: false, projected: true))
        }
    }

    func updateDragPosition(newValue: CGPoint) {
        var midX: CGFloat
        var midY: CGFloat

        (midX, activeGuideIDX) = snap(newValue.x - (initialDragDelta?.width ?? 0), to: projectedSnapGuidesX)
        (midY, activeGuideIDY) = snap(newValue.y - (initialDragDelta?.height ?? 0), to: projectedSnapGuidesY)

        let minX = midX - frame.width / 2
        let minY = midY - frame.height / 2

        frame = CGRect(x: minX, y: minY, width: frame.width, height: frame.height)
    }
}

struct HandleBorder: View {
    @Binding var frame: CGRect

    let color: Color
    let lineWidth: CGFloat

    var body: some View {
        ZStack {
            Rectangle()
                .stroke(color, lineWidth: lineWidth)
                .frame(width: frame.width, height: frame.height, alignment: .center)
                .position(CGPoint(x: frame.midX, y: frame.midY))
        }
    }
}

struct ResizeHandle: View {
    @Binding var frame: CGRect
    let handleAlignment: Alignment

    @State var isDragging = false
    @State var initialDragDelta: CGSize?

    @Binding var activeGuideIDX: String?
    @Binding var activeGuideIDY: String?

    let snapGuidesX: [SnapGuide]
    let snapGuidesY: [SnapGuide]

    @State var projectedSnapGuidesX: [SnapGuide] = []
    @State var projectedSnapGuidesY: [SnapGuide] = []

    var borderThickness: CGFloat { 1 }

    var handleSizeRegular: CGFloat { 10 }
    var handleSizeDragging: CGFloat { 50 }
    var handleSize: CGFloat { isDragging ? handleSizeDragging : handleSizeRegular }

    var cornerRadiusRegular: CGFloat { 2 }
    var cornerRadiusDragging: CGFloat { 25 }
    var cornerRadius: CGFloat { isDragging ? cornerRadiusDragging : cornerRadiusRegular }

    @Environment(\.widgetColorScheme) var colorScheme
    @Environment(\.editorSnap) var editorSnap

    var handlePosition: CGPoint {
        var x: CGFloat
        var y: CGFloat

        switch handleAlignment.horizontal {
        case .leading: x = frame.minX
        case .trailing: x = frame.maxX
        default: x = frame.midX
        }

        switch handleAlignment.vertical {
        case .top: y = frame.minY
        case .bottom: y = frame.maxY
        default: y = frame.midY
        }

        return CGPoint(x: x, y: y)
    }

    func updateHandlePosition(newValue: CGPoint) {
        var minX = frame.minX
        var maxX = frame.maxX
        var minY = frame.minY
        var maxY = frame.maxY

        switch handleAlignment.horizontal {
        case .leading: (minX, activeGuideIDX) = snap(newValue.x - (initialDragDelta?.width ?? 0), to: projectedSnapGuidesX)
        case .trailing: (maxX, activeGuideIDX) = snap(newValue.x - (initialDragDelta?.width ?? 0), to: projectedSnapGuidesX)
        default: break
        }

        switch handleAlignment.vertical {
        case .top: (minY, activeGuideIDY) = snap(newValue.y - (initialDragDelta?.height ?? 0), to: projectedSnapGuidesY)
        case .bottom: (maxY, activeGuideIDY) = snap(newValue.y - (initialDragDelta?.height ?? 0), to: projectedSnapGuidesY)
        default: break
        }

        frame = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    func incrementHandlePosition() {
        let step: CGFloat = 8 // / WidgetModel.Size.large.deviceFrame.width
        var snapGuides: [SnapGuide] = []
        var handlePosition1D: CGFloat = 0

        projectSnapGuides()

        switch (handleAlignment.horizontal, handleAlignment.vertical) {
        case (.leading, .center), (.trailing, .center): snapGuides = projectedSnapGuidesX.sorted { $0.position < $1.position }; handlePosition1D = handlePosition.x
        case (.center, .top), (.center, .bottom): snapGuides = projectedSnapGuidesY.sorted { $0.position < $1.position }; handlePosition1D = handlePosition.y
        default: break
        }

        var snapToGuide: SnapGuide?

        for snapGuide in snapGuides {
            if snapGuide.position > handlePosition1D,
               snapGuide.position - snapGuide.strength < handlePosition1D + step,
               snapGuide.id != activeGuideIDX,
               snapGuide.id != activeGuideIDY
            {
                snapToGuide = snapGuide
                break
            }
        }

        if let snapToGuide = snapToGuide {
            switch (handleAlignment.horizontal, handleAlignment.vertical) {
            case (.leading, .center), (.trailing, .center): activeGuideIDX = snapToGuide.id; updateHandlePosition(newValue: CGPoint(x: snapToGuide.position, y: handlePosition.y))
            case (.center, .top), (.center, .bottom): activeGuideIDY = snapToGuide.id; updateHandlePosition(newValue: CGPoint(x: handlePosition.x, y: snapToGuide.position))
            default: break
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.activeGuideIDX = nil; self.activeGuideIDY = nil }
        } else {
            switch (handleAlignment.horizontal, handleAlignment.vertical) {
            case (.leading, .center), (.trailing, .center): activeGuideIDX = nil; updateHandlePosition(newValue: CGPoint(x: handlePosition1D + step, y: handlePosition.y))
            case (.center, .top), (.center, .bottom): activeGuideIDY = nil; updateHandlePosition(newValue: CGPoint(x: handlePosition.x, y: handlePosition1D + step))
            default: break
            }
        }
    }

    func decrementHandlePosition() {
        let step: CGFloat = 8 // / WidgetModel.Size.large.deviceFrame.width
        var snapGuides: [SnapGuide] = []
        var handlePosition1D: CGFloat = 0

        projectSnapGuides()

        switch (handleAlignment.horizontal, handleAlignment.vertical) {
        case (.leading, .center), (.trailing, .center): snapGuides = projectedSnapGuidesX.sorted { $0.position > $1.position }; handlePosition1D = handlePosition.x
        case (.center, .top), (.center, .bottom): snapGuides = projectedSnapGuidesY.sorted { $0.position > $1.position }; handlePosition1D = handlePosition.y
        default: break
        }

        dump(snapGuides)

        var snapToGuide: SnapGuide?

        for snapGuide in snapGuides {
            if snapGuide.position < handlePosition1D,
               snapGuide.position + snapGuide.strength > handlePosition1D + step,
               snapGuide.id != activeGuideIDX,
               snapGuide.id != activeGuideIDY
            {
                snapToGuide = snapGuide
                break
            }
        }

        dump(snapToGuide)

        if let snapToGuide = snapToGuide {
            switch (handleAlignment.horizontal, handleAlignment.vertical) {
            case (.leading, .center), (.trailing, .center): activeGuideIDX = snapToGuide.id; updateHandlePosition(newValue: CGPoint(x: snapToGuide.position, y: handlePosition.y))
            case (.center, .top), (.center, .bottom): activeGuideIDY = snapToGuide.id; updateHandlePosition(newValue: CGPoint(x: handlePosition.x, y: snapToGuide.position))
            default: break
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.activeGuideIDX = nil; self.activeGuideIDY = nil }
        } else {
            switch (handleAlignment.horizontal, handleAlignment.vertical) {
            case (.leading, .center), (.trailing, .center): activeGuideIDX = nil; updateHandlePosition(newValue: CGPoint(x: handlePosition1D - step, y: handlePosition.y))
            case (.center, .top), (.center, .bottom): activeGuideIDY = nil; updateHandlePosition(newValue: CGPoint(x: handlePosition.x, y: handlePosition1D - step))
            default: break
            }
        }
    }

    func projectSnapGuides() {
        guard editorSnap == true else {
            projectedSnapGuidesX = []
            projectedSnapGuidesY = []

            return
        }

        projectedSnapGuidesX = snapGuidesX
        projectedSnapGuidesY = snapGuidesY

        var pivotX: CGFloat
        var pivotY: CGFloat

        switch handleAlignment.horizontal {
        case .leading: pivotX = frame.maxX
        case .trailing: pivotX = frame.minX
        default: pivotX = frame.midX
        }

        switch handleAlignment.vertical {
        case .top: pivotY = frame.maxY
        case .bottom: pivotY = frame.minY
        default: pivotY = frame.midY
        }

        for snapGuide in snapGuidesX {
            let projectedPosition = pivotX + 2 * (snapGuide.position - pivotX)

            projectedSnapGuidesX.append(SnapGuide(position: projectedPosition, id: snapGuide.id, strength: snapGuide.strength - 4, alwaysVisible: false, projected: true))
        }

        for snapGuide in snapGuidesY {
            let projectedPosition = pivotY + 2 * (snapGuide.position - pivotY)

            projectedSnapGuidesY.append(SnapGuide(position: projectedPosition, id: snapGuide.id, strength: snapGuide.strength - 4, alwaysVisible: false, projected: true))
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius + borderThickness, style: .continuous)
                .fill(colorScheme == .light ? Color.black : Color.white)
                .frame(width: handleSize + (borderThickness * 2), height: handleSize + (borderThickness * 2), alignment: .center)

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(colorScheme == .light ? Color.white : Color.black)
                .frame(width: handleSize, height: handleSize, alignment: .center)
        }
        .frame(width: 50, height: 50, alignment: .center)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named("canvas"))
                .onChanged {
                    value in

                    if initialDragDelta == nil {
                        initialDragDelta = CGSize(width: value.startLocation.x - handlePosition.x, height: value.startLocation.y - handlePosition.y)
                        projectSnapGuides()

                        withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) { isDragging = true }
                    }

                    withAnimation(.spring(response: 0.25)) {
                        updateHandlePosition(newValue: value.location)
                    }
                }
                .onEnded {
                    _ in

                    initialDragDelta = nil
                    activeGuideIDX = nil
                    activeGuideIDY = nil

                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { isDragging = false }
                }
        )
        .position(handlePosition)
        .resizeHandleAccessibilityFlags(for: handleAlignment, handlePosition: handlePosition, incrementHandlePosition: incrementHandlePosition, decrementHandlePosition: decrementHandlePosition)
        .preference(key: HandleDragInProgressPreferenceKey.self, value: isDragging)
    }
}

extension View {
    func canvasResizable(coordinateSpace: String, frame: Binding<CGRect>, isSelected: Binding<Bool>, snapGuidesX: [SnapGuide], snapGuidesY: [SnapGuide], activeGuideIDX: Binding<String?>, activeGuideIDY: Binding<String?>, snapGuidesActive: Bool, cornerRadius: CGFloat, colorScheme _: ColorScheme) -> some View
    {
        modifier(CanvasResizable(coordinateSpace: coordinateSpace, frame: frame, isSelected: isSelected, snapGuidesX: snapGuidesX, snapGuidesY: snapGuidesY, cornerRadius: cornerRadius, activeGuideIDX: activeGuideIDX, activeGuideIDY: activeGuideIDY, snapGuidesActive: snapGuidesActive))
    }
}

struct ResizeHandleAccessibilityFlags: ViewModifier {
    let handleAlignment: Alignment
    let handlePosition: CGPoint
    let incrementHandlePosition: () -> Void
    let decrementHandlePosition: () -> Void

    var handlePosition1D: CGFloat {
        switch (handleAlignment.horizontal, handleAlignment.vertical) {
        case (.leading, .center), (.trailing, .center): return handlePosition.x
        case (.center, .top), (.center, .bottom): return handlePosition.y

        default: return 0
        }
    }

    var handlePercentage: Text {
        Text("\(handlePosition1D / WidgetModel.Size.large.deviceFrame.width * 100, specifier: "%0.0f") percent")
    }

    func body(content: Content) -> some View {
        switch (handleAlignment.horizontal, handleAlignment.vertical) {
        case (.center, .top): return content.accessibilityAdjustableAction { if $0 == .increment { incrementHandlePosition() } else { decrementHandlePosition() } }.accessibility(label: Text("Top resize handle"))
        case (.leading, .center): return content.accessibilityAdjustableAction { if $0 == .increment { incrementHandlePosition() } else { decrementHandlePosition() } }.accessibility(label: Text("Leading resize handle"))
        case (.trailing, .center): return content.accessibilityAdjustableAction { if $0 == .increment { incrementHandlePosition() } else { decrementHandlePosition() } }.accessibility(label: Text("Trailing resize handle"))
        case (.center, .bottom): return content.accessibilityAdjustableAction { if $0 == .increment { incrementHandlePosition() } else { decrementHandlePosition() } }.accessibility(label: Text("Bottom resize handle"))

        default: return content.accessibility(hidden: true)
        }
    }
}

extension View {
    func resizeHandleAccessibilityFlags(for handleAlignment: Alignment, handlePosition: CGPoint, incrementHandlePosition: @escaping () -> Void, decrementHandlePosition: @escaping () -> Void) -> some View
    {
        return modifier(ResizeHandleAccessibilityFlags(handleAlignment: handleAlignment, handlePosition: handlePosition, incrementHandlePosition: incrementHandlePosition, decrementHandlePosition: decrementHandlePosition))
    }
}

struct SnapGuide: Identifiable {
    let position: CGFloat
    let id: String
    let strength: CGFloat
    let alwaysVisible: Bool
    let projected: Bool
}

func snap(_ position: CGFloat, to snapGuides: [SnapGuide]) -> (CGFloat, String?) {
    var snappedPosition = position
    var guideID: String?
    var highestGuideStrength: CGFloat = 0

    for snapGuide in snapGuides {
        let guideStrength: CGFloat = max(snapGuide.strength - abs(snapGuide.position - position), 0)

        if guideStrength > highestGuideStrength {
            highestGuideStrength = guideStrength
            snappedPosition = snapGuide.position
            guideID = snapGuide.id
        }
    }

    return (snappedPosition, guideID)
}
