//
//  PopupMenu.swift
//  WidGet
//
//  Created by Joel Bernstein on 10/2/20.
//

import SwiftUI

struct PopupMenu: View {
    @GestureState var dragLocation: CGPoint? = nil
    @State var keepOpen = false
    @Namespace var namespace

    var menuOpen: Bool {
        keepOpen || dragLocation != nil
    }

    var body: some View {
        ZStack {
            Text("Hello, World!")
                .padding()
                .matchedGeometryEffect(id: "ID", in: namespace, anchor: .center, isSource: true)
                .background(VisualEffectBlur(blurStyle: menuOpen ? .prominent : .regular))
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .global)
                        .onChanged {
                            value in

                            if dragLocation == nil {
                                keepOpen.toggle()
                            }

                            if value.translation.width * value.translation.width + value.translation.height * value.translation.height > 4
                            {
                                keepOpen = false
                            }
                        }
                        .updating($dragLocation) { value, state, _ in state = value.location }
                )
                .overlay(
                    VStack {
                        VStack(spacing: 0) {
                            Item(label: Label("Add Remote Feed", systemImage: "globe"), dragLocation: dragLocation, menuOpen: menuOpen).opacity(menuOpen ? 1 : 0)
                            Item(label: Label("Add Gradient", systemImage: "lineweight"), dragLocation: dragLocation, menuOpen: menuOpen).opacity(menuOpen ? 1 : 0)
                            Item(label: Label("Add Solid Color", systemImage: "rectangle.fill"), dragLocation: dragLocation, menuOpen: menuOpen).opacity(menuOpen ? 1 : 0)
                            Item(label: Label("Add Link", systemImage: "link"), dragLocation: dragLocation, menuOpen: menuOpen).opacity(menuOpen ? 1 : 0)
                            Item(label: Label("Add Image", systemImage: "photo"), dragLocation: dragLocation, menuOpen: menuOpen).opacity(menuOpen ? 1 : 0)
                            Item(label: Label("Add Text", systemImage: "text.bubble"), dragLocation: dragLocation, menuOpen: menuOpen).opacity(menuOpen ? 1 : 0)
                        }
                        .background(VisualEffectBlur(blurStyle: .regular))
                        .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
//                .background(RoundedRectangle(cornerRadius: 11, style: .continuous).padding(-1).opacity(0.2))

                        VStack(spacing: 0) {
                            Item(label: Label("Paste as Remote Feed", systemImage: "doc.on.clipboard"), dragLocation: dragLocation, menuOpen: menuOpen).opacity(menuOpen ? 1 : 0)
                            Item(label: Label("Paste as Link", systemImage: "doc.on.clipboard"), dragLocation: dragLocation, menuOpen: menuOpen).opacity(menuOpen ? 1 : 0)
                        }
                        .background(VisualEffectBlur(blurStyle: .regular))
                        .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                    }
                    .padding(.horizontal, -80)
                    .padding(.vertical, -380)
                    .shadow(color: Color.black.opacity(0.1), radius: menuOpen ? 30 : 0, x: 0, y: menuOpen ? 10 : 0)
                    .opacity(menuOpen ? 1 : 0)
                    .matchedGeometryEffect(id: menuOpen ? "" : "ID", in: namespace, anchor: .center, isSource: false)
                    // .position(x: 100, y: 20)
                    .animation(.spring(response: 0.35, dampingFraction: 0.825, blendDuration: 0.0))
                )
        }
    }

    struct Item: View {
        let label: Label<Text, Image>
        let dragLocation: CGPoint?
        let menuOpen: Bool

        @State var isDraggingOver = false
        @GestureState var isTapping = false

        var body: some View {
            VStack(spacing: 0) {
                Color.white
                    .opacity(isDraggingOver || isTapping ? 0 : 0.5)
                    .frame(maxWidth: 320, maxHeight: 40, alignment: .leading)
                    .overlay(label.labelStyle(ItemLabelStyle()).padding().frame(maxWidth: 320, maxHeight: 40, alignment: .leading).opacity(menuOpen ? 0.7 : 0))
                    .overlay(hitTester())
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .global).updating($isTapping) { _, state, _ in state = true })
            }
        }

        func hitTester() -> some View {
            GeometryReader { geometry in
                let _ = DispatchQueue.main.async {
                    if let dragLocation = dragLocation { isDraggingOver = geometry.frame(in: .global).contains(dragLocation) }
                }

                Color.clear
            }
        }

        struct ItemLabelStyle: LabelStyle {
            func makeBody(configuration: Configuration) -> some View {
                HStack {
                    configuration.title
                    Spacer()
                    Color.clear.frame(width: 16, height: 1, alignment: .center).overlay(configuration.icon)
                }
            }
        }
    }
}

struct PopupMenu_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            FourPointGradient(startHue: 0.5, brightnessLight: 1.0, saturationLight: 0.5, brightnessDark: 0.4, saturationDark: 1.0)

            VStack {
                Spacer()
                PopupMenu()
            }
        }
        // .environment(\.sizeCategory, .extraSmall)
        .previewDevice("iPod touch (7th generation)")
    }
}
