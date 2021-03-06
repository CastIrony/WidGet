//
//  WidgetEditor.swift
//  WidGet
//
//  Created by Joel Bernstein on 8/22/20.
//

import SwiftUI

struct WidgetEditor: View {
    @State var widget: WidgetModel
    @Binding var toolbarBlur: Bool

    @ScaledMetric(wrappedValue: 60) var menuButtonHeight: CGFloat

    @State var undoStack: [WidgetModel] = []
    @State var redoStack: [WidgetModel] = []

    @State var selectedContentPanelID: UUID?
    @State var dragInProgress: Bool = false
    @State var undoInProgress: Bool = false

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.editorSnap) var editorSnap

    let editorColorScheme: ColorScheme

    let pasteboardItemChanged = NotificationCenter.default.publisher(for: UIPasteboard.changedNotification)
    let pasteboardItemRemoved = NotificationCenter.default.publisher(for: UIPasteboard.removedNotification)

    @State var activeGuideIDsX: Set<String> = []
    @State var activeGuideIDsY: Set<String> = []

    @State var impactGenerator = UIImpactFeedbackGenerator(style: .soft)

    @State var widgetTextField: WritableKeyPath<WidgetModel, String>?
    @State var widgetColorField: WritableKeyPath<WidgetModel, HSBColor>?

    @State var textField: (contentPanelID: UUID, keyPath: WritableKeyPath<ContentPanelModel, String>)?
    @State var colorField: (contentPanelID: UUID, keyPath: WritableKeyPath<ContentPanelModel, HSBColor>)?
    @State var urlField: (contentPanelID: UUID, keyPath: WritableKeyPath<ContentPanelModel, String>)?
    @State var fontField: (contentPanelID: UUID, keyPath: WritableKeyPath<ContentPanelModel, ContentPanelModel.FontModel>)?
    @State var fieldName: String = ""

    @State var pasteboardHasURL: Bool = false
    @State var pasteboardHasText: Bool = false
    @State var pasteboardHasImage: Bool = false

    @State var loadingContentPanelIDs: Set<UUID> = []

    let saveWidget: (WidgetModel) -> Void

    let toolbarHeight: CGFloat

    var body: some View {
        ZStack {
            ClearView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 0) {
                widgetView().padding(.top, toolbarHeight + 20)

                contentPanelForms()
            }
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .blur(radius: isShowingFieldEditor ? 50 : 0)
            .opacity(isShowingFieldEditor ? 0 : 1)

            fieldEditors()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: activeGuideIDsX) { if $0.count > 0 { impactGenerator.impactOccurred() } }
        .onChange(of: activeGuideIDsY) { if $0.count > 0 { impactGenerator.impactOccurred() } }
        .onChange(of: urlField?.contentPanelID) { if $0 == nil, let contentPanelID = selectedContentPanelID { self.loadContent(for: contentPanelID) } }
        .onAppear {
            NotificationCenter.default.post(name: UIPasteboard.changedNotification, object: "bar")
        }
        .onReceive(pasteboardItemChanged.merge(with: pasteboardItemRemoved)) {
            _ in

            pasteboardHasImage = UIPasteboard.general.hasImages
            pasteboardHasText = UIPasteboard.general.hasStrings

            UIPasteboard.general.detectPatterns(for: [.probableWebURL]) {
                result in

                if case let .success(patterns) = result, patterns.contains(.probableWebURL) {
                    pasteboardHasURL = true
                } else {
                    pasteboardHasURL = UIPasteboard.general.hasURLs
                }
            }
        }
        .onPreferenceChange(DragInProgressPreferenceKey.self) {
            dragInProgress = $0

            if !$0 {
                print("drag ended")
                undoStack.append(widget)
                saveWidget(widget)
            }
        }
        .onChange(of: widget) {
            newValue in

            if undoInProgress {
                undoInProgress = false

                print("widget changed, undo off")
            } else {
                if !dragInProgress {
                    print("widget changed, undo off, drag off")
                    undoStack.append(newValue)
                    saveWidget(newValue)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .widgetEditorUndo)) {
            _ in

            print("Undoing! \(undoStack.count)")

            if undoStack.count > 1 {
                withAnimation(.spring()) {
                    undoInProgress = true
                    if let undoneVersion = undoStack.popLast() {
                        redoStack.append(undoneVersion)
                    }

                    widget = undoStack.last!
                    saveWidget(widget)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .widgetEditorRedo)) {
            _ in

            print("Redoing! \(redoStack.count)")

            if undoStack.count > 1 {
                withAnimation(.spring()) {
                    undoInProgress = true
                    if let redoneVersion = redoStack.popLast() {
                        undoStack.append(redoneVersion)
                    }

                    widget = undoStack.last!
                    saveWidget(widget)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .widgetEditorRedo)) {
            _ in

            print("Reverting! \(redoStack.count)")

            if let firstVersion = undoStack.first {
                saveWidget(firstVersion)
            }
        }
        .preference(key: UndoStackCountPreferenceKey.self, value: undoStack.count)
        .preference(key: RedoStackCountPreferenceKey.self, value: redoStack.count)
    }

    @ViewBuilder
    func resizeHandleCanvas() -> some View {
        let deviceFrame = widget.widgetSize.deviceFrame

        ZStack {
            ForEach(widget.contentPanelIDs.reversed(), id: \.self) {
                contentPanelID in

                let snapGuidesActive = selectedContentPanelID != contentPanelID && (
                    (activeGuideIDsX.filter { $0.starts(with: String(describing: contentPanelID)) }.count > 0) ||
                    (activeGuideIDsY.filter { $0.starts(with: String(describing: contentPanelID)) }.count > 0)
                )

                ClearView()
                    .canvasResizable(coordinateSpace: "canvas", frame: frameBinding(for: contentPanelID), isSelected: contentPanelSelectionBinding(for: contentPanelID), snapGuidesX: snapGuidesX, snapGuidesY: snapGuidesY, activeGuideIDsX: $activeGuideIDsX, activeGuideIDsY: $activeGuideIDsY, snapGuidesActive: snapGuidesActive, cornerRadius: widget.cornerRadius(for: contentPanelID), colorScheme: colorScheme)
                    .zIndex(contentPanelID == selectedContentPanelID ? 2 : 1)
            }
        }
        .coordinateSpace(name: "canvas")
        .frame(width: deviceFrame.width, height: deviceFrame.height, alignment: .center)
        .mask(GradientMask(top: 0, bottom: 20).padding(.bottom, -20).padding(.horizontal, -100).padding(.top, -100))
    }

    @ViewBuilder
    func snapGuides() -> some View {
        let deviceFrame = widget.widgetSize.deviceFrame

        ZStack {
            ForEach(snapGuidesX) {
                guide in

                let guideActive = activeGuideIDsX.contains(guide.id)

                if !guide.projected, guideActive || guide.alwaysVisible {
                    Capsule().fill(guideActive ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: guideActive ? 3 : 1, height: deviceFrame.height + (guideActive ? 3 : 0))
                        .position(CGPoint(x: guide.position, y: 0.5 * deviceFrame.height))
                }
            }

            ForEach(snapGuidesY) {
                guide in

                let guideActive = activeGuideIDsY.contains(guide.id)

                if !guide.projected, guideActive || guide.alwaysVisible {
                    Capsule().fill(guideActive ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: deviceFrame.width + (guideActive ? 3 : 0), height: guideActive ? 3 : 1)
                        .position(CGPoint(x: 0.5 * deviceFrame.width, y: guide.position))
                }
            }
        }
        .frame(width: deviceFrame.width, height: deviceFrame.height, alignment: .center)
    }

    @ViewBuilder
    func widgetView() -> some View {
        let deviceFrame = widget.widgetSize.deviceFrame

        ZStack {
            Color(widget.backgroundColor.uiColor(for: editorColorScheme))
                .frame(width: deviceFrame.width, height: deviceFrame.height, alignment: .center)
                .fixedSize()
                .overlay(
                    ZStack {
                        ClearView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .onTapGesture { withAnimation(.spring()) { selectedContentPanelID = nil } }

                        ForEach(widget.contentPanelIDs.reversed(), id: \.self) {
                            contentPanelID in

                            let frame = widget.contentPanelsByID[contentPanelID]!.frame.deviceRect

                            ContentPanelView(contentPanel: contentPanelBinding(for: contentPanelID), isSelected: contentPanelSelectionBinding(for: contentPanelID), isLoading: loadingContentPanelIDs.contains(contentPanelID))
                                .id(contentPanelID)
                                .frame(width: frame.width, height: frame.height, alignment: widget.contentPanelsByID[contentPanelID]?.contentAlignment.alignment ?? .center)
                                .clipShape(RoundedRectangle(cornerRadius: widget.cornerRadius(for: contentPanelID), style: .continuous))
                                .position(CGPoint(x: frame.midX, y: frame.midY))
                        }

                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: widget.cornerRadius, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: widget.cornerRadius, style: .continuous).inset(by: -1).strokeBorder(colorScheme == .dark ? Color.white.opacity(0.35) : Color.black.opacity(0.1)))
                .id(widget.id)
                .environment(\.widgetColorScheme, editorColorScheme)

            resizeHandleCanvas()

            if editorSnap {
                snapGuides()
            }
        }
        .frame(height: deviceFrame.height, alignment: .center)
    }

    @ViewBuilder
    func addContentMenu() -> some View {
        Menu {
            Button(action: { addContentPanel(.text) }) { Label("Add Text", systemImage: "text.bubble") }
            Button(action: { addContentPanel(.image) }) { Label("Add Image", systemImage: "photo") }
            Button(action: { addContentPanel(.solidColor) }) { Label("Add Solid Color", systemImage: "rectangle.fill") }
            Button(action: { addContentPanel(.gradient) }) { Label("Add Gradient", systemImage: "lineweight") }
            Button(action: { addContentPanel(.remoteResource) }) { Label("Add Web Content", systemImage: "globe") }
        }
        label: {
            Label { Text("Add Panel") } icon: { Image(systemName: "plus.rectangle.on.rectangle") }
                .font(.title3.weight(.medium))
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                .padding(.horizontal, 20)
                .frame(minHeight: menuButtonHeight)
                .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).inset(by: -1).strokeBorder(colorScheme == .dark ? Color.white.opacity(0.35) : Color.black.opacity(0.1)))
                .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(colorScheme == .dark ? Color.black : Color.white))
        }
    }

    @ViewBuilder
    func pasteContentMenu() -> some View {
        Menu {
            if pasteboardHasImage {
                Button(action: { addContentPanel(.image, paste: true) }) { Label("Paste Image", systemImage: "photo") }
            }

            if pasteboardHasURL {
                Button(action: { addContentPanel(.remoteResource, paste: true) }) { Label("Paste Web URL", systemImage: "globe") }
            }

            if pasteboardHasText {
                Button(action: { addContentPanel(.text, paste: true) }) { Label("Paste Text", systemImage: "text.bubble") }
            }
        }
        label: {
            Label { Text("Paste") } icon: { Image(systemName: "doc.on.clipboard") }
                .font(.title3.weight(.medium))
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                .padding(.horizontal, 20)
                .frame(minHeight: menuButtonHeight)
                .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).inset(by: -1).strokeBorder(colorScheme == .dark ? Color.white.opacity(0.35) : Color.black.opacity(0.1)))
                .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(colorScheme == .dark ? Color.black : Color.white))
        }
    }

    @ViewBuilder
    func contentPanelForms() -> some View {
        ScrollViewReader {
            _ in

            ScrollView {
                VStack(spacing: 0) {
                    HStack {
                        addContentMenu()

                        if pasteboardHasURL || pasteboardHasText || pasteboardHasImage {
                            pasteContentMenu()
                        }
                    }
                    .padding(.top, 20)

                    VStack {
                        ForEach(widget.contentPanelIDs, id: \.self) {
                            contentPanelID in

                            contentPanelForm(for: contentPanelID, scroll: { /* scrollView.scrollTo(contentPanelID) */ })
                        }
                    }
                    .frame(maxWidth: .infinity)

                    WidgetForm(widget: $widget, showTextFieldEditor: showWidgetTextFieldEditor, showColorFieldEditor: showWidgetColorFieldEditor)
                }
            }
        }
        .mask(GradientMask(top: 20, bottom: 0))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    func contentPanelForm(for contentPanelID: UUID, scroll: @escaping () -> Void) -> some View {
        let contentPanelIndex = widget.contentPanelIDs.firstIndex(of: contentPanelID)!
        let isFirst = (contentPanelIndex == 0)
        let isLast = (contentPanelIndex == widget.contentPanelIDs.count - 1)

        let panelActions = ContentPanelForm.PanelActions(
            bringToFront: isFirst ? nil : { withAnimation(.spring()) { widget.contentPanelIDs.move(fromOffsets: IndexSet(integer: contentPanelIndex), toOffset: 0) } },
            bringForward: isFirst ? nil : { withAnimation(.spring()) { widget.contentPanelIDs.move(fromOffsets: IndexSet(integer: contentPanelIndex), toOffset: contentPanelIndex - 1) } },
            sendBackward: isLast ? nil : { withAnimation(.spring()) { widget.contentPanelIDs.move(fromOffsets: IndexSet(integer: contentPanelIndex), toOffset: contentPanelIndex + 2) } },
            sendToBack: isLast ? nil : { withAnimation(.spring()) { widget.contentPanelIDs.move(fromOffsets: IndexSet(integer: contentPanelIndex), toOffset: widget.contentPanelIDs.count) } },
            duplicate: { selectedContentPanelID = widget.duplicateContentPanel(widget.contentPanelsByID[contentPanelID]!) },
            resetFrame: { withAnimation(.spring()) { widget.contentPanelsByID[contentPanelID]?.frame = widget.defaultContentFrame } },
            delete: { widget.deleteContentPanel(contentPanelID) },
            scroll: scroll,
            loadContent: loadContentAction(for: contentPanelID),
            showTextFieldEditor: showTextFieldEditor(contentPanelID:keyPath:fieldName:),
            showURLFieldEditor: showURLFieldEditor(contentPanelID:keyPath:fieldName:),
            showColorFieldEditor: showColorFieldEditor(contentPanelID:keyPath:fieldName:),
            showFontFieldEditor: showFontFieldEditor(contentPanelID:keyPath:fieldName:)
        )

        ContentPanelForm(contentPanel: contentPanelBinding(for: contentPanelID),
                         isSelected: contentPanelSelectionBinding(for: contentPanelID),
                         isLoading: loadingContentPanelIDs.contains(contentPanelID),
                         panelActions: panelActions)
    }

    @ViewBuilder
    private func fieldEditors() -> some View {
        if let widgetTextField = widgetTextField {
            ClearView().onTapGesture { withAnimation(.spring()) { hideFieldEditors() } }

            TextFieldEditor(text: widgetKeyPathBinding(for: widgetTextField), fieldName: fieldName, fieldType: .text, hideFieldEditor: hideFieldEditors)
                .padding(.horizontal, 20)
                .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
        }

        if let widgetColorField = widgetColorField {
            ClearView().onTapGesture { withAnimation(.spring()) { hideFieldEditors() } }

            ColorFieldEditor(colorField: widgetKeyPathBinding(for: widgetColorField), fieldName: fieldName, widgetColors: widget.widgetColors(), hideFieldEditor: hideFieldEditors)
                .padding(.horizontal, 20)
                .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
        }

        if let textField = textField {
            ClearView().onTapGesture { withAnimation(.spring()) { hideFieldEditors() } }

            TextFieldEditor(text: contentPanelKeyPathBinding(for: textField.contentPanelID, keyPath: textField.keyPath), fieldName: fieldName, fieldType: .text, hideFieldEditor: hideFieldEditors)
                .padding(.horizontal, 20)
                .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
        }

        if let urlField = urlField {
            ClearView().onTapGesture { withAnimation(.spring()) { hideFieldEditors() } }

            TextFieldEditor(text: contentPanelKeyPathBinding(for: urlField.contentPanelID, keyPath: urlField.keyPath), fieldName: fieldName, fieldType: .URL, hideFieldEditor: hideFieldEditors)
                .padding(.horizontal, 20)
                .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
        }

        if let colorField = colorField {
            ClearView().onTapGesture { withAnimation(.spring()) { hideFieldEditors() } }

            ColorFieldEditor(colorField: contentPanelKeyPathBinding(for: colorField.contentPanelID, keyPath: colorField.keyPath), fieldName: fieldName, widgetColors: widget.widgetColors(exceptFor: colorField.0), hideFieldEditor: hideFieldEditors)
                .padding(.horizontal, 20)
                .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
        }

        if let fontField = fontField {
            ClearView().onTapGesture { withAnimation(.spring()) { hideFieldEditors() } }

            FontFieldEditor(font: contentPanelKeyPathBinding(for: fontField.contentPanelID, keyPath: fontField.keyPath), fieldName: fieldName, hideFieldEditor: hideFieldEditors)
                .padding(.horizontal, 20)
                .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
        }
    }

    var isShowingFieldEditor: Bool {
        let showingFieldEditor = widgetTextField != nil || widgetColorField != nil || textField != nil || urlField != nil || colorField != nil || fontField != nil

        DispatchQueue.main.async { toolbarBlur = showingFieldEditor }

        return showingFieldEditor
    }
    
    func addContentPanel(_ contentType: ContentPanelModel.ContentType, paste: Bool = false) {
        withAnimation {
            selectedContentPanelID = widget.addContentPanel(contentType: contentType, paste: paste)

            if let selectedContentPanelID = selectedContentPanelID, widget.contentPanelsByID[selectedContentPanelID]?.targetURLString != nil
            {
                self.loadContent(for: selectedContentPanelID)
            }
        }
    }

    func frameBinding(for contentPanelID: UUID) -> Binding<CGRect> {
        Binding {
            widget.contentPanelsByID[contentPanelID]!.frame.deviceRect
        }
        set: {
            widget.contentPanelsByID[contentPanelID]!.frame = ContentPanelModel.FrameModel(deviceRect: $0)
        }
    }

    func contentPanelBinding(for contentPanelID: UUID) -> Binding<ContentPanelModel> {
        Binding(get: { widget.contentPanelsByID[contentPanelID]! }, set: { widget.contentPanelsByID[contentPanelID] = $0 })
    }

    func contentPanelSelectionBinding(for contentPanelID: UUID) -> Binding<Bool> {
        Binding(get: { contentPanelID == selectedContentPanelID }, set: { selectedContentPanelID = $0 ? contentPanelID : nil })
    }

    func widgetKeyPathBinding<T>(for keyPath: WritableKeyPath<WidgetModel, T>) -> Binding<T> {
        Binding(get: { widget[keyPath: keyPath] }, set: { widget[keyPath: keyPath] = $0 })
    }

    func contentPanelKeyPathBinding<T>(for contentPanelID: UUID, keyPath: WritableKeyPath<ContentPanelModel, T>) -> Binding<T> {
        Binding(get: { widget.contentPanelsByID[contentPanelID]![keyPath: keyPath] }, set: { widget.contentPanelsByID[contentPanelID]![keyPath: keyPath] = $0 })
    }

    func showWidgetTextFieldEditor(keyPath: WritableKeyPath<WidgetModel, String>, fieldName: String) {
        self.fieldName = fieldName

        withAnimation(.spring()) { self.widgetTextField = keyPath }
    }

    func showWidgetColorFieldEditor(keyPath: WritableKeyPath<WidgetModel, HSBColor>, fieldName: String) {
        self.fieldName = fieldName

        withAnimation(.spring()) { self.widgetColorField = keyPath }
    }

    func showColorFieldEditor(contentPanelID: UUID, keyPath: WritableKeyPath<ContentPanelModel, HSBColor>, fieldName: String) {
        self.fieldName = fieldName

        withAnimation(.spring()) { self.colorField = (contentPanelID, keyPath) }
    }

    func showFontFieldEditor(contentPanelID: UUID, keyPath: WritableKeyPath<ContentPanelModel, ContentPanelModel.FontModel>, fieldName: String) {
        self.fieldName = fieldName

        withAnimation(.spring()) { self.fontField = (contentPanelID, keyPath) }
    }

    func showTextFieldEditor(contentPanelID: UUID, keyPath: WritableKeyPath<ContentPanelModel, String>, fieldName: String) {
        self.fieldName = fieldName

        withAnimation(.spring()) { self.textField = (contentPanelID, keyPath) }
    }

    func showURLFieldEditor(contentPanelID: UUID, keyPath: WritableKeyPath<ContentPanelModel, String>, fieldName: String) {
        self.fieldName = fieldName

        withAnimation(.spring()) { self.urlField = (contentPanelID, keyPath) }
    }

    func hideFieldEditors() {
        withAnimation(.spring()) {
            fieldName = ""
            widgetTextField = nil
            widgetColorField = nil
            textField = nil
            urlField = nil
            fontField = nil
            colorField = nil
        }
    }

    var snapGuidesX: [SnapGuide] {
        var snapGuides: [SnapGuide] = []

        let widgetFrame = widget.widgetSize.deviceFrame

        let fullWidth = widgetFrame.width

        let smallPadding = CGFloat(8)
        let largePadding = CGFloat(16)

        let strength = CGFloat(4)
        let highStrength: Double = 6

        snapGuides.append(SnapGuide(position: 0, id: "leading", strength: highStrength, alwaysVisible: true, projected: false))
        snapGuides.append(SnapGuide(position: smallPadding, id: "leading small padding", strength: strength, alwaysVisible: true, projected: false))
        snapGuides.append(SnapGuide(position: largePadding, id: "leading large padding", strength: strength, alwaysVisible: true, projected: false))
        
        snapGuides.append(SnapGuide(position: fullWidth * 0.5 - smallPadding, id: "horizontal center leading small padding", strength: strength, alwaysVisible: true, projected: false))
        snapGuides.append(SnapGuide(position: fullWidth * 0.5, id: "horizontal center", strength: strength, alwaysVisible: true, projected: false))
        snapGuides.append(SnapGuide(position: fullWidth * 0.5 + smallPadding, id: "horizontal center trailing small padding", strength: strength, alwaysVisible: true, projected: false))
        
        snapGuides.append(SnapGuide(position: fullWidth - largePadding, id: "trailing large padding", strength: strength, alwaysVisible: true, projected: false))
        snapGuides.append(SnapGuide(position: fullWidth - smallPadding, id: "trailing small padding", strength: strength, alwaysVisible: true, projected: false))
        snapGuides.append(SnapGuide(position: fullWidth, id: "trailing", strength: highStrength, alwaysVisible: true, projected: false))

        for contentPanelId in widget.contentPanelIDs {
            if contentPanelId != selectedContentPanelID {
                if let contentPanel = widget.contentPanelsByID[contentPanelId] {
                    let panelRect = contentPanel.frame.deviceRect

                    snapGuides.append(SnapGuide(position: panelRect.minX - largePadding, id: "\(contentPanelId) leading large padding", strength: strength - 1, alwaysVisible: false, projected: false))
                    snapGuides.append(SnapGuide(position: panelRect.minX - smallPadding, id: "\(contentPanelId) leading small padding", strength: strength - 1, alwaysVisible: false, projected: false))
                    snapGuides.append(SnapGuide(position: panelRect.minX, id: "\(contentPanelId) leading", strength: strength + 1, alwaysVisible: false, projected: false))
                    snapGuides.append(SnapGuide(position: panelRect.midX, id: "\(contentPanelId) horizontal center", strength: strength + 1, alwaysVisible: false, projected: false))
                    snapGuides.append(SnapGuide(position: panelRect.maxX, id: "\(contentPanelId) trailing", strength: strength + 1, alwaysVisible: false, projected: false))
                    snapGuides.append(SnapGuide(position: panelRect.maxX + smallPadding, id: "\(contentPanelId) trailing small padding", strength: strength - 1, alwaysVisible: false, projected: false))
                    snapGuides.append(SnapGuide(position: panelRect.maxX + largePadding, id: "\(contentPanelId) trailing large padding", strength: strength - 1, alwaysVisible: false, projected: false))
                }
            }
        }

        return snapGuides
    }

    var snapGuidesY: [SnapGuide] {
        var snapGuides: [SnapGuide] = []

        let widgetFrame = widget.widgetSize.deviceFrame

        let fullHeight = widgetFrame.height

        let smallPadding = CGFloat(8)
        let largePadding = CGFloat(16)

        let strength = CGFloat(4)
        let highStrength: Double = 6

        snapGuides.append(SnapGuide(position: 0, id: "top", strength: highStrength, alwaysVisible: true, projected: false))
        snapGuides.append(SnapGuide(position: smallPadding, id: "top small padding", strength: strength, alwaysVisible: true, projected: false))
        snapGuides.append(SnapGuide(position: largePadding, id: "top large padding", strength: strength, alwaysVisible: true, projected: false))
        
        snapGuides.append(SnapGuide(position: fullHeight * 0.5 - smallPadding, id: "vertical center top small padding", strength: strength, alwaysVisible: true, projected: false))
        snapGuides.append(SnapGuide(position: fullHeight * 0.5, id: "vertical center", strength: strength, alwaysVisible: true, projected: false))
        snapGuides.append(SnapGuide(position: fullHeight * 0.5 + smallPadding, id: "vertical center bottom small padding", strength: strength, alwaysVisible: true, projected: false))
        
        snapGuides.append(SnapGuide(position: fullHeight - largePadding, id: "bottom large padding", strength: strength, alwaysVisible: true, projected: false))
        snapGuides.append(SnapGuide(position: fullHeight - smallPadding, id: "bottom small padding", strength: strength, alwaysVisible: true, projected: false))
        snapGuides.append(SnapGuide(position: fullHeight, id: "bottom", strength: highStrength, alwaysVisible: true, projected: false))

        for contentPanelId in widget.contentPanelIDs {
            if contentPanelId != selectedContentPanelID {
                if let contentPanel = widget.contentPanelsByID[contentPanelId] {
                    let panelRect = contentPanel.frame.deviceRect

                    snapGuides.append(SnapGuide(position: panelRect.minY - largePadding, id: "\(contentPanelId) top large padding", strength: strength - 1, alwaysVisible: false, projected: false))
                    snapGuides.append(SnapGuide(position: panelRect.minY - smallPadding, id: "\(contentPanelId) top small padding", strength: strength - 1, alwaysVisible: false, projected: false))
                    snapGuides.append(SnapGuide(position: panelRect.minY, id: "\(contentPanelId) top", strength: strength + 1, alwaysVisible: false, projected: false))
                    snapGuides.append(SnapGuide(position: panelRect.midY, id: "\(contentPanelId) vertical center", strength: strength + 1, alwaysVisible: false, projected: false))
                    snapGuides.append(SnapGuide(position: panelRect.maxY, id: "\(contentPanelId) bottom", strength: strength + 1, alwaysVisible: false, projected: false))
                    snapGuides.append(SnapGuide(position: panelRect.maxY + smallPadding, id: "\(contentPanelId) bottom small padding", strength: strength - 1, alwaysVisible: false, projected: false))
                    snapGuides.append(SnapGuide(position: panelRect.maxY + largePadding, id: "\(contentPanelId) bottom large padding", strength: strength - 1, alwaysVisible: false, projected: false))
                }
            }
        }

        return snapGuides
    }

    func loadContent(for contentPanelID: UUID) {
        guard
            let contentPanel = widget.contentPanelsByID[contentPanelID],
            let url = URL(string: contentPanel.targetURLString)
        else { return }

        loadingContentPanelIDs.insert(contentPanelID)

        RemoteResourceLoader.loadResource(from: url) {
            response, error in

            loadingContentPanelIDs.remove(contentPanelID)

            if let response = response {
                let oldCacheFileURLs = widget.cacheFileURLs

                withAnimation(.spring()) {
                    if contentPanel.contentType == .remoteResource {
                        widget.contentPanelsByID[contentPanelID]?.contentType = response.contentType
                    }
                }

                if response.contentType == .remoteImage {
                    ImageCache.shared.storeImageData(response.data, for: response.resourceURL.absoluteString)

                    widget.contentPanelsByID[contentPanelID]?.image.lightIdentifier = response.resourceURL.absoluteString
                    widget.contentPanelsByID[contentPanelID]?.image.darkIdentifier = response.resourceURL.absoluteString
                }

                if let contentTitle = response.contentTitle, widget.widgetName.hasPrefix("Small Widget") || widget.widgetName.hasPrefix("Medium Widget") || widget.widgetName.hasPrefix("Large Widget")
                {
                    widget.widgetName = contentTitle
                }

                if response.contentItems.count == 0 || widget.contentPanelsByID[contentPanelID]?.contentItems != response.contentItems
                {
                    widget.contentPanelsByID[contentPanelID]?.lastRefresh = Date()
                }

                widget.contentPanelsByID[contentPanelID]?.resourceURL = response.resourceURL
                widget.contentPanelsByID[contentPanelID]?.targetURLString = url.absoluteString
                widget.contentPanelsByID[contentPanelID]?.contentItems = response.contentItems

                oldCacheFileURLs.subtracting(widget.cacheFileURLs).forEach {
                    do {
                        try FileManager.default.removeItem(at: $0)
                    } catch {
                        dump(error)
                    }
                }
            }

            widget.contentPanelsByID[contentPanelID]?.errorString = error

            print(widget.priorityScore)
        }
    }

    func loadContentAction(for contentPanelID: UUID) -> (() -> Void) {
        return { loadContent(for: contentPanelID) }
    }
}

struct ContentPanelFormDeletionModifier: ViewModifier {
    @GestureState var dragWidth: CGFloat = .zero
    @GestureState var isDragging: Bool = false

    @State var baseAngle: CGFloat = 0
    @State var baseOffset: CGFloat = 0

    let delete: () -> Void

    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            Button(action: delete) { Image(systemName: "xmark").font(.title.bold()).frame(width: 60, height: 60, alignment: .center) }
                .buttonStyle(DeleteButtonStyle())
                .opacity(baseOffset < 0 ? 0 : 1)
                .accessibility(hidden: true)

            content

            Button(action: delete) { Image(systemName: "xmark").font(.title.bold()).frame(width: 60, height: 60, alignment: .center) }
                .buttonStyle(DeleteButtonStyle())
                .opacity(baseOffset > 0 ? 0 : 1)
                .accessibility(hidden: true)
        }
        .gesture(formDragGesture())
        .padding(.horizontal, -60)
        .offset(x: baseOffset + dragWidth)
        .animation(.interactiveSpring()) // isDragging ? .interactiveSpring() : .spring())
    }

    func formDragGesture() -> some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .updating($dragWidth) {
                value, state, _ in

                state = value.translation.width
            }
            .updating($isDragging) { _, state, _ in state = true }
            .onEnded {
                value in

                if value.translation.width + baseOffset > 40 {
                    baseOffset = 90
                } else if value.translation.width + baseOffset < -40 {
                    baseOffset = -90
                } else {
                    baseOffset = 0
                }
            }
    }
}

struct DeleteButtonStyle: ButtonStyle {
    public func makeBody(configuration: DeleteButtonStyle.Configuration) -> some View {
        let buttonColor: Color = configuration.isPressed ? Color("deletePressedColor") : Color("deleteColor")
        let textColor = Color(white: 1, opacity: configuration.isPressed ? 0.8 : 1)

        return configuration.label
            .foregroundColor(textColor)
            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(buttonColor))
    }
}

struct WidgetForm: View {
    @Binding var widget: WidgetModel
    @Environment(\.colorScheme) var colorScheme
    @State var labelWidth: CGFloat = 0

    let showTextFieldEditor: (_ keyPath: WritableKeyPath<WidgetModel, String>, _ fieldName: String) -> Void
    let showColorFieldEditor: (_ keyPath: WritableKeyPath<WidgetModel, HSBColor>, _ fieldName: String) -> Void

    var widgetDescription: String {
        switch widget.widgetSize {
        case .small: return "Small Widget"
        case .medium: return "Medium Widget"
        case .large: return "Large Widget"
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(widgetDescription)
                .font(.title2.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)

            FormDivider()

            TextRow(widget: $widget, fieldName: "Name", fieldKeyPath: \.widgetName, showTextFieldEditor: showTextFieldEditor, labelWidth: labelWidth)
            ColorRow(widget: $widget, fieldName: "Color", fieldKeyPath: \.backgroundColor, showColorFieldEditor: showColorFieldEditor, labelWidth: labelWidth)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background((colorScheme == .dark ? Color.black : Color.white).opacity(0.2))
        .overlay(Rectangle().inset(by: -1).strokeBorder(colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.05)))
//        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
//        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).inset(by: -1).strokeBorder(colorScheme == .dark ? Color.white.opacity(0.35) : Color.black.opacity(0.1)))
//        .padding(.horizontal, 8)
        .padding(.top, 20)
        .padding(.bottom, 40)
        .onPreferenceChange(LabelWidthPreferenceKey.self) {
            newValue in

            labelWidth = newValue
        }
    }

    struct TextRow: View {
        @Binding var widget: WidgetModel

        let fieldName: String
        let fieldKeyPath: WritableKeyPath<WidgetModel, String>

        let showTextFieldEditor: (_ keyPath: WritableKeyPath<WidgetModel, String>, _ fieldName: String) -> Void

        let labelWidth: CGFloat

        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            HStack {
                Text("\(fieldName):")
                    .fontWeight(.semibold)
                    .measureLabelWidth()
                    .applyIf(labelWidth > 10) { $0.frame(minWidth: labelWidth, alignment: .trailing) }

                Button(action: { showTextFieldEditor(fieldKeyPath, fieldName) }) { Text(widget[keyPath: fieldKeyPath]).frame(maxWidth: .infinity, alignment: .leading) }
                    .buttonStyle(FormButtonStyle())
            }
            .frame(maxWidth: .infinity, minHeight: 35)
        }
    }

    struct ColorRow: View {
        @Binding var widget: WidgetModel

        let fieldName: String
        let fieldKeyPath: WritableKeyPath<WidgetModel, ContentPanelModel.ColorModel>
        let showColorFieldEditor: (_ keyPath: WritableKeyPath<WidgetModel, HSBColor>, _ fieldName: String) -> Void
        let labelWidth: CGFloat

        @Environment(\.colorScheme) var colorScheme
        @ScaledMetric(wrappedValue: 24, relativeTo: .body) var height: CGFloat

        var body: some View {
            HStack {
                (Text(fieldName) + Text(":"))
                    .fontWeight(.semibold)
                    .measureLabelWidth()
                    .frame(minWidth: labelWidth, alignment: .trailing)

                Button(action: { showColorFieldEditor(fieldKeyPath.appending(path: \.lightColor), "\(fieldName)\(widget[keyPath: fieldKeyPath].enableDarkColor ? " (Light)" : "")") })
                    {
                        Text(widget[keyPath: fieldKeyPath].enableDarkColor ? "Light" : "")
                            .font(.body.bold().smallCaps())
                            .padding(.bottom, 1)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(FormColorButtonStyle(hsbColor: widget[keyPath: fieldKeyPath.appending(path: \.lightColor)]))
                    .animation(.interactiveSpring())

                if widget[keyPath: fieldKeyPath].enableDarkColor {
                    Button(action: { showColorFieldEditor(fieldKeyPath.appending(path: \.darkColor), "\(fieldName) (Dark)") })
                        {
                            Text("Dark")
                                .font(.body.bold().smallCaps())
                                .padding(.bottom, 1)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(FormColorButtonStyle(hsbColor: widget[keyPath: fieldKeyPath.appending(path: \.darkColor)]))
                        .animation(.interactiveSpring())
                }

                Button {
                    widget[keyPath: fieldKeyPath].enableDarkColor.toggle()
                }
                label: {
                    Image(systemName: colorScheme == .light ? "circle.righthalf.fill" : "circle.lefthalf.fill")
                        .imageScale(.large)
                        .frame(minWidth: height, minHeight: height)
                }
                .buttonStyle(FormButtonStyle())
                .layoutPriority(-1)
                .animation(.interactiveSpring())
            }
            .frame(minHeight: 35)
        }
    }
}
