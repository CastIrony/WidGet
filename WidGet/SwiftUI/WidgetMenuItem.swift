//
//  WidgetMenuItem.swift
//  WidGet
//
//  Created by Joel Bernstein on 6/11/21.
//

import SwiftUI

struct WidgetMenuItem: View {
    @Binding var widget: WidgetModel

    var selectWidget: () -> Void
    var deleteWidget: () -> Void

    @Environment(\.colorScheme) var colorScheme

    @State var isFlipped: Bool = false
    @State var flipDirection: Edge = .leading

    @GestureState var dragAngle: CGFloat = .zero
    @GestureState var isDragging: Bool = false

    @State var baseAngle: CGFloat = 0

    var body: some View {
        VStack {
            Text(widget.widgetName)
                .font(.title3).fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.black.opacity(colorScheme == .light ? 0.3 : 1)))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).inset(by: -1).strokeBorder(colorScheme == .dark ? Color.white.opacity(0.35) : Color.clear))
                .frame(maxWidth: .infinity, alignment: .center)
                .animation(.spring())

            ZStack {
                Color(widget.backgroundColor.uiColor(for: colorScheme))
                    .overlay(
                        ZStack {
                            ForEach(widget.contentPanelIDs.reversed(), id: \.self) {
                                contentPanelID in

                                let frame = widget.contentPanelsByID[contentPanelID]!.frame.deviceRect

                                ContentPanelView(contentPanel: Binding.constant(widget.contentPanelsByID[contentPanelID]!), isSelected: Binding.constant(false), isLoading: false)
                                    .frame(width: frame.width, height: frame.height, alignment: widget.contentPanelsByID[contentPanelID]?.contentAlignment.alignment ?? .center)
                                    .clipShape(RoundedRectangle(cornerRadius: widget.cornerRadius(for: contentPanelID), style: .continuous))
                                    .position(CGPoint(x: frame.midX, y: frame.midY))
                                    .allowsHitTesting(false)
                            }
                        }
                    )

                WidgetDeleteView(isFlipped: isFlipped, widgetSize: widget.widgetSize, deleteWidget: deleteWidget)
            }
            .transition(.opacity)
            .frame(width: widget.widgetSize.deviceFrame.width, height: widget.widgetSize.deviceFrame.height, alignment: .center)
            .fixedSize()
            .clipShape(RoundedRectangle(cornerRadius: widget.cornerRadius, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: widget.cornerRadius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: widget.cornerRadius, style: .continuous).inset(by: -1).strokeBorder(colorScheme == .dark ? Color.white.opacity(0.35) : Color.black.opacity(0.1)))
            .widgetFlipEffect(angle: dragAngle + baseAngle, flipped: $isFlipped)
            .animation(isDragging ? .interactiveSpring() : .spring())
            .frame(maxWidth: .infinity)
            .animation(.spring())
            .gesture(widgetDragGesture())
            .gesture(widgetLongPressGesture())
            .gesture(widgetTapGesture())
        }
        .shadow(color: colorScheme == .light ? Color.black.opacity(0.2) : Color.purple.opacity(0.7), radius: 40, y: colorScheme == .light ? 20 : 0)
        .environment(\.widgetColorScheme, colorScheme)
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(widgetDescription()))
        .accessibilityAction(named: Text("Edit Widget"), selectWidget)
        .accessibilityAction(named: Text("Delete Widget"), deleteWidget)
    }

    func widgetDescription() -> String {
        switch widget.widgetSize {
        case .small: return "Small Widget: \(widget.widgetName)"
        case .medium: return "Medium Widget: \(widget.widgetName)"
        case .large: return "Large Widget: \(widget.widgetName)"
        }
    }

    func widgetLongPressGesture() -> some Gesture {
        return LongPressGesture(minimumDuration: 2, maximumDistance: 9).onChanged {
            foo in

            dump(foo)

            withAnimation(.spring()) {
                baseAngle += CGFloat.pi
            }
        }
    }

    func widgetTapGesture() -> some Gesture {
        return TapGesture().onEnded {
            if isFlipped {
                withAnimation(.spring()) {
                    baseAngle = flipDirection == .leading ? baseAngle + CGFloat.pi : baseAngle - CGFloat.pi
                }
            } else {
                selectWidget()
            }
        }
    }

    func widgetDragGesture() -> some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .updating($dragAngle) {
                value, state, _ in

                let proportion = CGFloat(value.translation.width / UIScreen.main.bounds.size.width)

                state = min(max(proportion, -0.5), 0.5) * CGFloat.pi * 2
            }
            .updating($isDragging) { _, state, _ in state = true }
            .onEnded {
                value in

                let proportion = CGFloat(value.translation.width / UIScreen.main.bounds.size.width)
                let radians = min(max(proportion, -0.5), 0.5) * CGFloat.pi * 2

                let newBaseAngle = round((baseAngle + radians) / CGFloat.pi) * CGFloat.pi
                flipDirection = newBaseAngle < baseAngle ? .leading : .trailing
                baseAngle = newBaseAngle
            }
    }
}

struct WidgetDeleteView: View {
    let isFlipped: Bool
    let widgetSize: WidgetModel.Size
    let deleteWidget: () -> Void

    var body: some View {
        ZStack {
            if isFlipped {
                Color(white: 0.5).opacity(0.8)
                Color(white: 0.5).blendMode(.saturation)

                Button(role: .destructive, action: deleteWidget) {
                    Label(widgetSize == .small ? "Delete" : "Delete Widget", systemImage: "minus.circle.fill")
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                }
                .buttonStyle(DeleteButtonStyle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            } else {
                EmptyView()
            }
        }
        .animation(nil)//, value: false)
    }

    struct DeleteButtonStyle: ButtonStyle {
        public func makeBody(configuration: DeleteButtonStyle.Configuration) -> some View {
            let buttonColor: Color = configuration.isPressed ? Color("deletePressedColor") : Color("deleteColor")
            let textColor = Color(white: 1, opacity: configuration.isPressed ? 0.8 : 1)

            return configuration.label
                .font(.title3.bold())
                .foregroundColor(textColor)
                .padding(15)
                .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(buttonColor))
                .background(RoundedRectangle(cornerRadius: 15, style: .continuous).inset(by: -5).fill(Color.white))
        }
    }

    struct DeleteLabelStyle: LabelStyle {
        let small: Bool

        public func makeBody(configuration: Configuration) -> some View {
            return HStack {
                configuration.icon

                if !small {
                    configuration.title
                }
            }
        }
    }
}

struct WidgetFlipEffect: GeometryEffect {
    var animatableData: CGFloat {
        get { angle }
        set { angle = newValue }
    }

    var angle: CGFloat
    @Binding var flipped: Bool

    func effectValue(size: CGSize) -> ProjectionTransform {
        DispatchQueue.main.async {
            let wrappedAngle = fmod(fmod(angle, 2.0 * CGFloat.pi) + 2.0 * CGFloat.pi, 2.0 * CGFloat.pi)

            flipped = wrappedAngle > (CGFloat.pi * 0.5) && wrappedAngle < (CGFloat.pi * 1.5)
        }

        var transform3d = CATransform3DIdentity

        transform3d.m34 = -0.5 / max(size.width, size.height)
        transform3d = CATransform3DRotate(transform3d, angle, 0, 1, 0)
        transform3d = CATransform3DTranslate(transform3d, -size.width * 0.5, -size.height * 0.5, 0)

        let affineTransform = ProjectionTransform(CGAffineTransform(translationX: size.width * 0.5, y: size.height * 0.5))

        return ProjectionTransform(transform3d).concatenating(affineTransform)
    }
}

public extension View {
    func widgetFlipEffect(angle: CGFloat, flipped: Binding<Bool>) -> some View {
        return modifier(WidgetFlipEffect(angle: angle, flipped: flipped))
    }
}
