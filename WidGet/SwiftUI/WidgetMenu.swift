//
//  MenuView.swift
//
//
//  Created by Bernstein, Joel on 7/4/20.
//

import SwiftUI
import WidgetKit

struct WidgetMenu: View {
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

    // MARK: - View Builders
    
    var body: some View {
        GeometryReader {
            geometry in

            ZStack {
                background()
                    .zIndex(0)

                widgetList(geometry: geometry)
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
    
    @ViewBuilder
    func widgetList(geometry: GeometryProxy) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: WidgetModel.Size.large.deviceFrame.height * 0.15) {
                Menu {
                    Button(action: { addWidget(.small) }) { Label("Create Small Widget", systemImage: WidgetModel.Size.small.iconName) }
                    Button(action: { addWidget(.medium) }) { Label("Create Medium Widget", systemImage: WidgetModel.Size.medium.iconName) }
                    Button(action: { addWidget(.large) }) { Label("Create Large Widget", systemImage: WidgetModel.Size.large.iconName) }
                }
                label: {
                    Label { Text("Create Widget") } icon: { Image(systemName: "plus.square.on.square") }
                        .font(.title3.weight(.medium))
                        .foregroundColor(colorScheme == .light ? .black : .white)
                        .padding(20)
                        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).inset(by: -1).strokeBorder(colorScheme == .dark ? Color.white.opacity(0.35) : Color.black.opacity(0.1)))
                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(colorScheme == .light ? Color.white : Color.black))
                }
                .padding(.top, toolbarHeight + 20)

                ForEach(document.widgetIDs, id: \.self) {
                    widgetID in

                    WidgetMenuItem(widget: widgetBinding(for: widgetID), selectWidget: selectWidgetAction(for: widgetID), deleteWidget: deleteWidgetAction(for: widgetID))
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .blur(radius: selectionExists ? 50 : 0)
        .opacity(selectionExists ? 0 : 1)
    }

    @ViewBuilder
    func deletedWidgetList() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            if document.deletedWidgetIDs.count > 0 {
                Text("Deleted Widgets:").font(.title.weight(.semibold))

                ForEach(document.deletedWidgetIDs.reversed(), id: \.self) {
                    widgetID in

                    if let widget = document.widgetsByID[widgetID] {
                        HStack {
                            Label(widget.widgetName, systemImage: widget.widgetSize.iconName)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Button(action: {}) {
                                Image(systemName: "trash.fill").padding(15)
                            }
                            .buttonStyle(DeleteButtonStyle())
                        }
                        .padding(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.white.opacity(0.2)))
                        .imageScale(.large)
                        .font(.title3.weight(.semibold))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(30)
    }
    
    @ViewBuilder
    func widgetEditor() -> some View {
        if selectionExists {
            WidgetEditor(widget: document.widgetsByID[selectedWidgetID!]!, toolbarBlur: $toolbarBlur, editorColorScheme: editorColorScheme, saveWidget: saveWidget, toolbarHeight: toolbarHeight)
                .transition(.move(edge: .bottom))
                .id(selectedWidgetID)
        }
    }

    @ViewBuilder
    func background() -> some View {
        Color(white: colorScheme == .light ? 0.65 : 0.2)
        FourPointGradient(startHue: 0.0, brightnessLight: 1.0, saturationLight: 0.5, brightnessDark: 0.2, saturationDark: 1.0)
        FourPointGradient(startHue: 0.9, brightnessLight: 1.0, saturationLight: 0.5, brightnessDark: 0.4, saturationDark: 1.0).opacity(selectionExists ? 1 : 0)
    }

    @ViewBuilder
    func toolbar(geometry: GeometryProxy) -> some View {
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
                        .contextMenu {
                            Button(action: saveAndCloseEditor) { Label("Save", systemImage: "arrow.down.square") }
                            Button(action: cancelAndCloseEditor) { Label("Cancel", systemImage: "xmark.square") }
                        }

                        Button(action: { NotificationCenter.default.post(name: .widgetEditorUndo, object: nil) })
                            {
                                Label("Undo", systemImage: "arrow.uturn.backward").labelStyle(IconOnlyLabelStyle())
                            }
                            .buttonStyle(FormButtonStyle())
                            .opacity(undoEnabled ? 1 : 0)

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
            .background(Material.regular)
            .measureToolbarHeight()
            .overlay(Rectangle().inset(by: -1).strokeBorder(colorScheme == .dark ? Color.white.opacity(0.35) : Color.black.opacity(0.1)))
            .blur(radius: toolbarBlur ? 50 : 0)
            .opacity(toolbarBlur ? 0 : 1)
            .animation(.spring())

            Spacer()
        }
    }

    // MARK: - Private

    private var editorColorScheme: ColorScheme {
        if invertEditorColorScheme && colorScheme == .light || !invertEditorColorScheme && colorScheme == .dark
        {
            return .dark
        }

        return .light
    }

    private var selectionExists: Bool {
        selectedWidgetID != nil
    }
    
    private func widgetBinding(for widgetID: UUID) -> Binding<WidgetModel> {
        Binding {
            document.widgetsByID[widgetID]!
        }
        set: {
            document.widgetsByID[widgetID] = $0
        }
    }

    // MARK: - Actions

    private func selectWidgetAction(for widgetID: UUID) -> (() -> Void) {
        { withAnimation(.spring(response: 0.6, dampingFraction: 0.825)) { selectedWidgetID = selectionExists ? nil : widgetID } }
    }
    
    private func deleteWidgetAction(for widgetID: UUID) -> (() -> Void) {
        { withAnimation { document.deleteWidget(id: widgetID); document.save() } }
    }
    
    
    private func addWidget(_ widgetSize: WidgetModel.Size) {
        withAnimation { selectedWidgetID = document.addWidget(widgetSize: widgetSize) }
    }

    private func saveWidget(_ widget: WidgetModel) {
        document.widgetsByID[widget.id] = widget
        document.save()
    }

    private func saveAndCloseEditor() {
        if let editedWidgetID = selectedWidgetID {
            document.widgetsByID[editedWidgetID]?.bakeThumbnails {
                document.save()
                WidgetCenter.shared.reloadAllTimelines()
            }
        }

        withAnimation {
            selectedWidgetID = nil
        }
    }

    private func cancelAndCloseEditor() {
        NotificationCenter.default.post(name: .widgetEditorRevert, object: nil)

        withAnimation {
            selectedWidgetID = nil
        }
    }
}
