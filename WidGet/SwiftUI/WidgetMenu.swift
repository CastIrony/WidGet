//
//  MenuView.swift
//
//
//  Created by Bernstein, Joel on 7/4/20.
//

import SwiftUI
import WidgetKit

struct RootView: View {
    @Namespace var namespace
    @Environment(\.colorScheme) var colorScheme

    @StateObject var appOptions: AppOptions

    @State var document: DocumentModel
    @State var selectedWidgetID: UUID?
    @State var invertEditorColorScheme = false
    @State var editorSnap: Bool = true
    @State var toolbarHeight: CGFloat = 0
    @State var toolbarBlur: Bool = false
    @State var undoEnabled: Bool = false
    @State var redoEnabled: Bool = false

    var editorColorScheme: ColorScheme {
        if invertEditorColorScheme && colorScheme == .light || !invertEditorColorScheme && colorScheme == .dark
        {
            return .dark
        }

        return .light
    }

    var selectionExists: Bool {
        selectedWidgetID != nil
    }

    var body: some View {
        GeometryReader {
            geometry in

            ZStack {
                background()
                    .zIndex(0)

                widgetMenu(geometry: geometry)
                    .zIndex(1)

                widgetEditor()
                    .zIndex(2)

                toolbar(geometry: geometry)
                    .zIndex(3)

                LoadingOverlayView(handlingLink: appOptions.handlingLink, linkDescription: appOptions.linkDescription)
                    .zIndex(4)
            }
            .ignoresSafeArea()
        }
        .environment(\.editorSnap, editorSnap)
        .onPreferenceChange(ToolbarHeightPreferenceKey.self) { toolbarHeight = $0 }
        .onPreferenceChange(UndoStackCountPreferenceKey.self) { undoEnabled = $0 > 1 }
        .onPreferenceChange(RedoStackCountPreferenceKey.self) { redoEnabled = $0 > 0 }
    }

    @ViewBuilder func background() -> some View {
        Color(white: colorScheme == .light ? 0.65 : 0.2)
        FourPointGradient(startHue: 0.0, brightnessLight: 1.0, saturationLight: 0.5, brightnessDark: 0.2, saturationDark: 1.0)
        FourPointGradient(startHue: 0.9, brightnessLight: 1.0, saturationLight: 0.5, brightnessDark: 0.4, saturationDark: 1.0).opacity(selectionExists ? 1 : 0)
    }

    @ViewBuilder func toolbar(geometry: GeometryProxy) -> some View {
        VStack {
            VStack {
                if selectedWidgetID == nil {
                    
                } else {
                    HStack {
                        Button(action: undoEnabled ? saveAndCloseEditor : cancelAndCloseEditor) {
                            Text("Close")
                                .fontWeight(.semibold)
                                .opacity(undoEnabled ? 0 : 1)
                                .overlay(
                                    Text("Save")
                                        .fontWeight(.semibold)
                                        .opacity(undoEnabled ? 1 : 0)
                                )
                        }
                        .buttonStyle(FormButtonStyle())
//                                .contextMenu
//                                {
//                                    Button(action: saveAndCloseEditor) { Label("Save", systemImage: "arrow.down.square") }
//                                    Button(action: cancelAndCloseEditor) { Label("Cancel", systemImage: "xmark.square") }
//                                }

                        Button(action: { NotificationCenter.default.post(name: .widgetEditorUndo, object: nil) })
                            {
                                Label("Undo", systemImage: "arrow.uturn.backward").labelStyle(IconOnlyLabelStyle())
                            }
                            .buttonStyle(FormButtonStyle())
                            .opacity(undoEnabled ? 1 : 0)

//                                if redoEnabled
//                                {
//                                    Button(action: { NotificationCenter.default.post(name: .widgetEditorRedo, object: nil) })
//                                    {
//                                        Label("Redo", systemImage: "arrow.uturn.forward").labelStyle(IconOnlyLabelStyle())
//                                    }
//                                    .buttonStyle(FormButtonStyle())
//                                }

                        Spacer()

                        Button(action: { invertEditorColorScheme.toggle() }) {
                            Label {
                                Text("Light").foregroundColor(.clear).overlay(Text(editorColorScheme == .light ? "Light" : "Dark"))
                            }
                            icon: {
                                Image(systemName: editorColorScheme == colorScheme ? "squareshape" : "squareshape.fill").imageScale(.large)
                            }
                        }
                        .buttonStyle(FormButtonStyle())

                        Button(action: { editorSnap.toggle() }) { Label("Snap", systemImage: editorSnap ? "dot.squareshape.split.2x2" : "squareshape").imageScale(.large) }.buttonStyle(FormButtonStyle())
                    }
                    .transition(AnyTransition.move(edge: .top).combined(with: AnyTransition.opacity))
                    .padding(8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, geometry.safeAreaInsets.top)
            .background(VisualEffectBlur(blurStyle: .regular))
            .measureToolbarHeight()
            .overlay(Rectangle().inset(by: -1).strokeBorder(colorScheme == .dark ? Color.white.opacity(0.35) : Color.black.opacity(0.1)))
            .blur(radius: toolbarBlur ? 50 : 0)
            .opacity(toolbarBlur ? 0 : 1)
            .animation(.spring())

            Spacer()
        }
    }

    @ViewBuilder func widgetMenu(geometry: GeometryProxy) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: WidgetModel.Size.large.deviceFrame.height * 0.15) {
                Menu {
                    Button(action: { addWidget(.small) }) { Label("Create Small Widget", systemImage: "square.grid.2x2") }
                    Button(action: { addWidget(.medium) }) { Label("Create Medium Widget", systemImage: "rectangle.grid.1x2") }
                    Button(action: { addWidget(.large) }) { Label("Create Large Widget", systemImage: "square") }
                }
                label: {
                    Label { Text("Create Widget") } icon: { Image(systemName: "plus.square.on.square") }
                        .font(Font.title3.weight(.medium))
                        .foregroundColor(colorScheme == .light ? .black : .white)
                        .padding(20)
                        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).inset(by: -1).strokeBorder(colorScheme == .dark ? Color.white.opacity(0.35) : Color.black.opacity(0.1)))
                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(colorScheme == .light ? Color.white : Color.black))
                }
                .padding(.top, toolbarHeight + 20)

                ForEach(document.widgetIDs, id: \.self) {
                    widgetID in

                    let selectionExists = (selectedWidgetID != nil)

                    let selectWidget = { withAnimation(.spring(response: 0.6, dampingFraction: 0.825)) { selectedWidgetID = selectionExists ? nil : widgetID } }
                    let deleteWidget = { withAnimation { document.deleteWidget(id: widgetID); document.save() } }

                    MenuWidgetView(widget: widgetBinding(widgetID), selectWidget: selectWidget, deleteWidget: deleteWidget)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: geometry.size.height)

//                    VStack(alignment: .leading, spacing: 15)
//                    {
//                        if document.deletedWidgetIDs.count > 0
//                        {
//                            Text("Deleted Widgets:").font(Font.title.weight(.semibold))
//
//                            ForEach(document.deletedWidgetIDs, id: \.self)
//                            {
//                                widgetID in
//
//                                HStack
//                                {
//                                    Label(document.widgetsByID[widgetID]?.widgetName ?? "", systemImage: "plus.square")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(15)
//                                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Color.white.opacity(0.2)))
//
            ////                                    Button(action: {})
            ////                                    {
            ////                                        Image(systemName: "trash.fill").padding(15)
            ////                                    }
            ////                                    .buttonStyle(DeleteButtonStyle())
//                                }
//                                .imageScale(.large)
//                                .font(Font.title3.weight(.semibold))
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                            }
//                        }
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding(30)

            Spacer(minLength: max(geometry.safeAreaInsets.bottom, 50))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .blur(radius: selectionExists ? 50 : 0)
        .opacity(selectionExists ? 0 : 1)
    }

    @ViewBuilder func widgetEditor() -> some View {
        if selectionExists {
            WidgetEditor(widget: document.widgetsByID[selectedWidgetID!]!, toolbarBlur: $toolbarBlur, saveWidget: saveWidget, editorColorScheme: editorColorScheme, toolbarHeight: toolbarHeight)
                .transition(.move(edge: .bottom))
                .id(selectedWidgetID)
        }
    }

    func calculateOffset(geometry: GeometryProxy, widgetID _: UUID) -> CGFloat {
        let rect = geometry.frame(in: .local)

        // dump(rect)

        return -rect.minY
    }

    func widgetBinding(_ widgetID: UUID) -> Binding<WidgetModel> {
        Binding {
            document.widgetsByID[widgetID]!
        }
        set: {
            document.widgetsByID[widgetID] = $0
        }
    }

    func addWidget(_ widgetSize: WidgetModel.Size) {
        withAnimation { selectedWidgetID = document.addWidget(widgetSize: widgetSize) }
    }

    func saveWidget(_ widget: WidgetModel) {
        print("saveWidget")
        document.widgetsByID[widget.id] = widget
        document.save()
    }

    func saveAndCloseEditor() {
        if let editedWidgetID = selectedWidgetID {
            print("Bake started!")

            document.widgetsByID[editedWidgetID]?.bakeThumbnails {
                print("Bake finished!")

                document.save()

                WidgetCenter.shared.reloadAllTimelines()
            }
        }

        withAnimation {
            selectedWidgetID = nil
        }
    }

    func cancelAndCloseEditor() {
        NotificationCenter.default.post(name: .widgetEditorRevert, object: nil)

        withAnimation {
            selectedWidgetID = nil
        }
    }
}

struct MenuWidgetView: View {
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
            .gesture(widgetTapGesture())
        }
//        .compositingGroup()
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

                Button(action: deleteWidget) {
                    Label("Delete", systemImage: "minus.circle.fill")
                        // .labelStyle(DeleteLabelStyle(small: widgetSize == .small))
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                }
                .buttonStyle(DeleteButtonStyle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            } else {
                EmptyView()
            }
        }
        .animation(.none)
    }

    struct DeleteButtonStyle: ButtonStyle {
        public func makeBody(configuration: DeleteButtonStyle.Configuration) -> some View {
            let buttonColor: Color = configuration.isPressed ? Color("deletePressedColor") : Color("deleteColor")
            let textColor = Color(white: 1, opacity: configuration.isPressed ? 0.8 : 1)

            return configuration.label
                .font(Font.title3.bold())
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
