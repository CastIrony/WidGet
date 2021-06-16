//
//  FieldEditor.swift
//  WidGet
//
//  Created by Joel Bernstein on 9/26/20.
//

import SwiftUI

struct TextFieldEditor: View {
    @Binding var text: String

    let fieldName: String
    let fieldType: FieldType
    let hideFieldEditor: () -> Void

    @FocusState var isFocused: Bool
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            VStack {
                Text(fieldName).font(.title3).fontWeight(.semibold).frame(maxWidth: .infinity, alignment: .center)
                    .overlay(
                        Button(action: hideFieldEditor) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .frame(minWidth: 48, minHeight: 48)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(x: -15)
                    )
                    .padding(.bottom, 7)
                
                TextField(text: $text, prompt: Text("Foo"), label: { Text("Bar") })
                    .submitLabel(.done)
                    .keyboardType(fieldType.keyboardType)
                    .disableAutocorrection(fieldType.disableAutocorrection)
                    .autocapitalization(fieldType.autocapitalization)
                    .textContentType(fieldType.textContentType)
                    .focused($isFocused)
                    .padding(.leading, 8)
                    .frame(minWidth: 33)
                    .frame(maxWidth: .infinity)
                    .frame(height: 33)
                    .background(RoundedRectangle(cornerRadius: 7, style: .continuous).fill(colorScheme == .light ? Color.white : Color.black))
                    .background(RoundedRectangle(cornerRadius: 7, style: .continuous).inset(by: -1).fill(colorScheme == .light ? Color.black.opacity(0.15) : Color.white.opacity(0.35)))
            }
            .padding(15)
            .frame(maxWidth: .infinity)
            .background(colorScheme == .light ? Color.white.opacity(0.5) : Color.black.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).inset(by: -1).strokeBorder(colorScheme == .dark ? Color.white.opacity(0.35) : Color.black.opacity(0.1)))
            .onChange(of: isFocused) {
                if $0 == false { hideFieldEditor() }
            }
            .onAppear {
                isFocused = true
            }

            HStack {
                Button(action: { text = "https://" }) { Text("https://").fontWeight(.semibold) }
                    .buttonStyle(FormButtonStyle())

                Button(action: { text = "http://" }) { Text("http://").fontWeight(.semibold) }
                    .buttonStyle(FormButtonStyle())
            }
            .frame(maxWidth: .infinity)
            .opacity(fieldType == .URL && text.isEmpty ? 1 : 0)
        }
    }

    enum FieldType {
        case text
        case URL
        
        var keyboardType: UIKeyboardType {
            switch self {
            case .text: return .default
            case .URL: return .URL
            }
        }

        var disableAutocorrection: Bool {
            switch self {
            case .text: return false
            case .URL: return true
            }
        }
        
        var autocapitalization: UITextAutocapitalizationType {
            switch self {
            case .text: return .sentences
            case .URL: return .none
            }
        }

        var textContentType: UITextContentType? {
            switch self {
            case .text: return nil
            case .URL: return .URL
            }
        }
    }
}

struct ColorFieldEditor: View {
    @Binding var colorField: HSBColor
    let fieldName: String
    let widgetColors: [HSBColor]
    let hideFieldEditor: () -> Void

    enum Mode: String {
        case swatches
        case rgb
        case hsb
        case hex
    }

    @State var labelWidth: CGFloat = 120
    @State var mode: Mode = .swatches

    @State var selectedHexIndex: Int = 0

    @Environment(\.colorScheme) var colorScheme

    @ViewBuilder func hexEditor() -> some View {
        VStack(spacing: 20) {
            HStack(spacing: 0) {
                let hexString = colorField.rgb.hexString

                if hexString.count == 7 {
                    ForEach(0 ..< 7) {
                        index in

                        let character = String(hexString[hexString.index(hexString.startIndex, offsetBy: index)])

                        if index == 0 {
                            Text(character)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        } else {
                            Button(action: { selectedHexIndex = index - 1 }) {
                                Text(character)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                                            .fill(colorScheme == .light ? Color(white: 0.5).opacity(selectedHexIndex == index - 1 ? 0.2 : 0) : Color(white: 0.5).opacity(selectedHexIndex == index - 1 ? 0.5 : 0))
                                            .animation(.interactiveSpring())
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .font(.system(size: 30, weight: .semibold, design: .monospaced))
            .foregroundColor(colorScheme == .light ? Color.black : Color.white)
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).inset(by: 1).fill(colorScheme == .light ? Color.white : Color.black))
            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(colorScheme == .light ? Color.black.opacity(0.22) : Color.white.opacity(0.35)))
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .contextMenu {
                Button(action: {}) { Label("Paste Hex Color", systemImage: "doc.on.clipboard") }
            }
            .padding(.top, 12)

            VStack(spacing: 8) {
                HStack {
                    Button(action: { self.type(hexChar: "1") }) { Text("1").frame(maxWidth: .infinity).frame(minHeight: 40) }.buttonStyle(FormButtonStyle())
                    Button(action: { self.type(hexChar: "2") }) { Text("2").frame(maxWidth: .infinity).frame(minHeight: 40) }.buttonStyle(FormButtonStyle())
                    Button(action: { self.type(hexChar: "3") }) { Text("3").frame(maxWidth: .infinity).frame(minHeight: 40) }.buttonStyle(FormButtonStyle())
                    Color.clear.frame(width: 4, height: 20)
                    Button(action: { self.type(hexChar: "A") }) { Text("A").frame(maxWidth: .infinity).frame(minHeight: 40) }.buttonStyle(FormButtonStyle())
                    Button(action: { self.type(hexChar: "B") }) { Text("B").frame(maxWidth: .infinity).frame(minHeight: 40) }.buttonStyle(FormButtonStyle())
                }

                HStack {
                    Button(action: { self.type(hexChar: "4") }) { Text("4").frame(maxWidth: .infinity).frame(minHeight: 40) }.buttonStyle(FormButtonStyle())
                    Button(action: { self.type(hexChar: "5") }) { Text("5").frame(maxWidth: .infinity).frame(minHeight: 40) }.buttonStyle(FormButtonStyle())
                    Button(action: { self.type(hexChar: "6") }) { Text("6").frame(maxWidth: .infinity).frame(minHeight: 40) }.buttonStyle(FormButtonStyle())
                    Color.clear.frame(width: 4, height: 20)
                    Button(action: { self.type(hexChar: "C") }) { Text("C").frame(maxWidth: .infinity).frame(minHeight: 40) }.buttonStyle(FormButtonStyle())
                    Button(action: { self.type(hexChar: "D") }) { Text("D").frame(maxWidth: .infinity).frame(minHeight: 40) }.buttonStyle(FormButtonStyle())
                }

                HStack {
                    Button(action: { self.type(hexChar: "7") }) { Text("7").frame(maxWidth: .infinity).frame(minHeight: 40) }.buttonStyle(FormButtonStyle())
                    Button(action: { self.type(hexChar: "8") }) { Text("8").frame(maxWidth: .infinity).frame(minHeight: 40) }.buttonStyle(FormButtonStyle())
                    Button(action: { self.type(hexChar: "9") }) { Text("9").frame(maxWidth: .infinity).frame(minHeight: 40) }.buttonStyle(FormButtonStyle())
                    Color.clear.frame(width: 4, height: 20)
                    Button(action: { self.type(hexChar: "E") }) { Text("E").frame(maxWidth: .infinity).frame(minHeight: 40) }.buttonStyle(FormButtonStyle())
                    Button(action: { self.type(hexChar: "F") }) { Text("F").frame(maxWidth: .infinity).frame(minHeight: 40) }.buttonStyle(FormButtonStyle())
                }

                HStack {
                    Button(action: { self.decrementHexIndex() }) { Image(systemName: "arrow.backward").frame(maxWidth: .infinity).frame(minHeight: 40) }.buttonStyle(PlainButtonStyle())
                    Button(action: { self.type(hexChar: "0") }) { Text("0").frame(maxWidth: .infinity).frame(minHeight: 40) }.buttonStyle(FormButtonStyle())
                    Button(action: { self.incrementHexIndex() }) { Image(systemName: "arrow.forward").frame(maxWidth: .infinity).frame(minHeight: 40) }.buttonStyle(PlainButtonStyle())
                    Color.clear.frame(width: 4, height: 20)
                    Button(action: {}) { Image(systemName: "arrow.forward").frame(maxWidth: .infinity).frame(minHeight: 40) }.buttonStyle(PlainButtonStyle()).hidden()
                    Button(action: {}) { Image(systemName: "arrow.forward").frame(maxWidth: .infinity).frame(minHeight: 40) }.buttonStyle(PlainButtonStyle()).hidden()
                }
            }
        }
    }

    func type(hexChar: String) {
        var hexString = colorField.hexString

        let index = hexString.index(hexString.startIndex, offsetBy: selectedHexIndex + 1)
        hexString.replaceSubrange(index ... index, with: hexChar)

        print(hexString)

        colorField.hexString = hexString

        print(colorField.hexString)

        incrementHexIndex()
    }

    func incrementHexIndex() {
        selectedHexIndex = min(5, selectedHexIndex + 1)
    }

    func decrementHexIndex() {
        selectedHexIndex = max(0, selectedHexIndex - 1)
    }

    var body: some View {
        VStack {
            Text(fieldName).font(.title3).fontWeight(.semibold).frame(maxWidth: .infinity, alignment: .center)
                .overlay(
                    Button(action: hideFieldEditor) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .frame(minWidth: 48, minHeight: 48)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(x: -15)
                )
                .padding(.bottom, 7)

            ZStack {
                Image("alpha").resizable(resizingMode: .tile)
                Color(colorField.uiColor)
            }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Picker("Color Panel Mode", selection: $mode.animation(.spring())) {
                ForEach([Mode.swatches, Mode.rgb, Mode.hsb, Mode.hex], id: \.self) {
                    switch $0 {
                    case .swatches: Text("Swatches")
                    case .rgb: Text("RGB")
                    case .hsb: Text("HSB")
                    case .hex: Text("Hex")
                    }
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            switch mode {
            case .swatches:
                swatchPicker()
            case .rgb:
                channelRow(value: $colorField.rgb.red, label: "Red:", backgroundGradient: redGradient).padding(.top, 20)
                channelRow(value: $colorField.rgb.green, label: "Green:", backgroundGradient: greenGradient)
                channelRow(value: $colorField.rgb.blue, label: "Blue:", backgroundGradient: blueGradient)
            case .hsb:
                channelRow(value: $colorField.hue, label: "Hue:", backgroundGradient: hueGradient).padding(.top, 20)
                channelRow(value: $colorField.saturation, label: "Saturation:", backgroundGradient: saturationGradient)
                channelRow(value: $colorField.brightness, label: "Brightness:", backgroundGradient: brightnessGradient)
            case .hex:
                hexEditor()
            }
                        
            channelRow(value: $colorField.alpha, label: "Opacity:", backgroundGradient: alphaGradient).padding(.top, 20)
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background((colorScheme == .light ? Color.white.opacity(0.5) : Color.black.opacity(0.5)).clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous)))
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .inset(by: -1)
                .strokeBorder(colorScheme == .dark ? Color.white.opacity(0.35) : Color.black.opacity(0.1))
        )
        .onPreferenceChange(LabelWidthPreferenceKey.self) { labelWidth = $0 }
    }

    @ViewBuilder
    func swatchPicker() -> some View {
        ScrollView {
            VStack {
                if widgetColors.count > 0 {
                    Text("Widget Colors").font(.title3.weight(.semibold)).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 20)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 6), alignment: .leading, spacing: 10, pinnedViews: .sectionHeaders) {
                        ForEach(widgetColors) { hsbColor in
                            Button(action: { colorField = hsbColor.replacingAlpha(colorField.alpha) }) { Color.clear }
                                .buttonStyle(FormColorButtonStyle(hsbColor: hsbColor.replacingAlpha(colorField.alpha)))
                                .aspectRatio(1, contentMode: .fill)
                        }
                    }
                }

                Text("System Colors").font(.title3.weight(.semibold)).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 20)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 6), alignment: .leading, spacing: 10, pinnedViews: .sectionHeaders)
                {
                    ForEach(systemColorsLight, id: \.name) { systemColor in
                        Button(action: { colorField = systemColor.color.replacingAlpha(colorField.alpha) }) {
                            Color.clear
                        }
                        .buttonStyle(FormColorButtonStyle(hsbColor: systemColor.color.replacingAlpha(colorField.alpha)))
                        .aspectRatio(1, contentMode: .fill)
                    }
                }
                .padding(.bottom, 20)

                Text("System Grays").font(.title3.weight(.semibold)).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 20)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 6), alignment: .leading, spacing: 10, pinnedViews: .sectionHeaders)
                {
                    ForEach(systemGrays, id: \.name) { systemColor in
                        Button(action: { colorField = systemColor.color.replacingAlpha(colorField.alpha) }) {
                            Color.clear
                        }
                        .buttonStyle(FormColorButtonStyle(hsbColor: systemColor.color.replacingAlpha(colorField.alpha)))
                        .aspectRatio(1, contentMode: .fill)
                    }
                }
                .padding(.bottom, 20)

                Text("Named Colors").font(.title3.weight(.semibold)).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 20)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 1), alignment: .leading, spacing: 10, pinnedViews: .sectionHeaders)
                    {
                        ForEach(x11Colors, id: \.name) {
                            systemColor in

                            Button(action: { colorField = systemColor.color.replacingAlpha(colorField.alpha) }) {
                                Text(systemColor.name)
                                    .multilineTextAlignment(.center)
                                    .font(.body.bold())
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .frame(minHeight: 45)
                            }
                            .buttonStyle(FormColorButtonStyle(hsbColor: systemColor.color.replacingAlpha(colorField.alpha)))
                        }
                    }
                    .padding(.bottom, 20)
            }
            .padding(.trailing, 10)
            .padding(.horizontal, 1)
        }
        .padding(.trailing, -10)
        .frame(maxHeight: 320)
        .mask(GradientMask(top: 20, bottom: 20).padding(.horizontal, -20))

    }
    
    func channelRow(value: Binding<CGFloat>, label: String, backgroundGradient: Gradient) -> some View
    {
        HStack {
            Text(label).fontWeight(.semibold).measureLabelWidth().frame(minWidth: labelWidth, alignment: .trailing)
            FormSlider(value: value, bounds: ClosedRange<CGFloat>(uncheckedBounds: (lower: 0, upper: 1)), step: 0.01, labelSpecifier: "%0.2f", backgroundGradient: backgroundGradient)
        }
    }

    var hueGradient: Gradient { Gradient(colors: stride(from: CGFloat(0.0), through: CGFloat(1.0), by: CGFloat(0.01)).map { Color(hue: Double($0), saturation: Double(colorField.saturation), brightness: Double(colorField.brightness), opacity: Double(colorField.alpha)) }) }
    var saturationGradient: Gradient { Gradient(colors: stride(from: CGFloat(0.0), through: CGFloat(1.0), by: CGFloat(0.01)).map { Color(hue: Double(colorField.hue), saturation: Double($0), brightness: Double(colorField.brightness), opacity: Double(colorField.alpha)) }) }
    var brightnessGradient: Gradient { Gradient(colors: stride(from: CGFloat(0.0), through: CGFloat(1.0), by: CGFloat(0.01)).map { Color(hue: Double(colorField.hue), saturation: Double(colorField.saturation), brightness: Double($0), opacity: Double(colorField.alpha)) }) }
    var redGradient: Gradient { Gradient(colors: stride(from: CGFloat(0.0), through: CGFloat(1.0), by: CGFloat(0.01)).map { Color(red: Double($0), green: Double(colorField.rgb.green), blue: Double(colorField.rgb.blue), opacity: Double(colorField.alpha)) }) }
    var greenGradient: Gradient { Gradient(colors: stride(from: CGFloat(0.0), through: CGFloat(1.0), by: CGFloat(0.01)).map { Color(red: Double(colorField.rgb.red), green: Double($0), blue: Double(colorField.rgb.blue), opacity: Double(colorField.alpha)) }) }
    var blueGradient: Gradient { Gradient(colors: stride(from: CGFloat(0.0), through: CGFloat(1.0), by: CGFloat(0.01)).map { Color(red: Double(colorField.rgb.red), green: Double(colorField.rgb.green), blue: Double($0), opacity: Double(colorField.alpha)) }) }
    var alphaGradient: Gradient { Gradient(colors: stride(from: CGFloat(0.0), through: CGFloat(1.0), by: CGFloat(0.01)).map { Color(red: Double(colorField.rgb.red), green: Double(colorField.rgb.green), blue: Double(colorField.rgb.blue), opacity: Double($0)) }) }
}

struct FontFieldEditor: View {
    @Binding var font: ContentPanelModel.FontModel

    let fieldName: String
    let hideFieldEditor: () -> Void

    @State var showingStylePopover: Bool = false
    @State var showingModifiersPopover: Bool = false

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .center) {
            Text(fieldName).font(.title3).fontWeight(.semibold).frame(maxWidth: .infinity, alignment: .center)
                .overlay(
                    Button(action: hideFieldEditor) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .frame(minWidth: 48, minHeight: 48)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(x: -15)
                )
                .padding(.bottom, 7)

            Divider()

            Color.clear
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .overlay(
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi at semper est, vel ultricies enim. Suspendisse bibendum mi in tortor tincidunt, sed eleifend ipsum cursus. Nulla tempus mi nec purus convallis, feugiat suscipit lacus interdum. Cras vestibulum maximus ante, et porta velit efficitur id. Ut quis erat mollis, tempus lacus eget, suscipit felis. Nullam est mauris, convallis ut pharetra ut, condimentum pharetra quam. Donec tempor egestas volutpat. Fusce et ullamcorper dolor, nec porttitor nunc. Sed eu metus sed ex consequat ullamcorper eget eu ante. Morbi arcu sem, tincidunt in mauris sit amet, cursus sodales arcu. Nulla odio mi, maximus a egestas aliquam, lacinia et quam. Aenean malesuada consectetur tellus. Phasellus tincidunt, risus non tincidunt sollicitudin, massa arcu hendrerit nisi, sit amet porttitor risus libero ac tellus. Phasellus et urna laoreet velit efficitur elementum. Nullam vulputate libero quis nunc lacinia scelerisque. Nullam placerat eget neque egestas posuere")
                        .textCaseMode(font.textCaseMode)
                        .lineLimit(3)
                        .font(font.font(size: 20))
                )
                .animation(.spring())

            fontList()
            
            Picker("", selection: $font.textCaseMode) {
                Text("Normal").tag(ContentPanelModel.TextCaseMode.normal)
                Text("UPPERCASE").tag(ContentPanelModel.TextCaseMode.uppercase)
                Text("lowercase").tag(ContentPanelModel.TextCaseMode.lowercase)
            }
            .pickerStyle(SegmentedPickerStyle())

//            Picker("", selection: $font.smallCapsMode)
//            {
//                Text("Normal").tag(ContentPanelModel.SmallCapsMode.normal)
//                Text("Lower Small Caps").tag(ContentPanelModel.SmallCapsMode.lowercaseSmallCaps)
//                Text("Small Caps").tag(ContentPanelModel.SmallCapsMode.smallCaps)
//            }
//            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 550)
        .background((colorScheme == .light ? Color.white.opacity(0.5) : Color.black.opacity(0.5)).clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous)))
        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).inset(by: -1).strokeBorder(colorScheme == .dark ? Color.white.opacity(0.35) : Color.black.opacity(0.1)))
    }

    func isSymbolic(_ familyName: String) -> Bool {
        UIFontDescriptor(name: familyName, size: 12).symbolicTraits.contains(.classSymbolic)
    }

    func faceName(_ fontName: String) -> String {
        print("~~~~~~ \(fontName)")
        dump(UIFontDescriptor(name: fontName, size: 12).fontAttributes)

        return fontName
    }
    
    @ViewBuilder
    func fontList() -> some View {
        ScrollViewReader {
            scroll in

            ScrollView {
                VStack(spacing: 20) {
                    ForEach(ContentPanelModel.FontModel.familyNames, id: \.self) { familyName in
                        fontRow(familyName: familyName)
                    }
                }
                .animation(.spring())
                .padding(.vertical, 8)
                .onAppear {
                    scroll.scrollTo(font.fontName, anchor: .center)
                }
                .onChange(of: font) {
                    newValue in

                    withAnimation(.spring()) {
                        scroll.scrollTo(newValue.fontName, anchor: .center)
                    }
                }
            }
        }
        .background(colorScheme == .light ? Color.white : Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).inset(by: -1).strokeBorder(Color.black.opacity(0.2)))
        .padding(1)

    }
    
    @ViewBuilder
    func fontRow(familyName: String) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                // Color.clear.frame(width: 24, height: 24).overlay(Image(systemName: familyName == font.familyName ? "checkmark" : ""))

                Text(familyName)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if font.familyName != familyName {
                            font.familyName = familyName
                            font.fontName = ContentPanelModel.FontModel.fontNames(forFamilyName: familyName).first ?? familyName
                        }
                    }
                    .padding(.horizontal, 15)
            }

            if familyName == font.familyName {
                VStack(spacing: 16) {
                    ForEach(ContentPanelModel.FontModel.fontNames(forFamilyName: familyName), id: \.self)
                        {
                            fontName in

                            HStack(alignment: .center, spacing: 8) {
                                Color.clear.frame(width: 24, height: 0).overlay(Image(systemName: fontName == font.fontName ? "checkmark" : "")).animation(nil)

                                Text(faceName(fontName))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if font.fontName != fontName {
                                            font.fontName = fontName
                                        }
                                    }
                            }
                            .padding(.horizontal, 15)
                            .background((fontName == font.fontName ? Color.accentColor.opacity(colorScheme == .light ? 0.2 : 0.3) : Color.clear).padding(.vertical, -8))
                        }
                }
                .padding(.top, 16)
            }
        }
        .background((familyName == font.familyName ? Color.accentColor.opacity(0.1) : Color.clear).padding(.vertical, -8))

    }
}

struct FieldEditor_Previews: PreviewProvider {
    struct Wrapper: View {
        @State var hsb = HSBColor(hue: 0.75, saturation: 0.75, brightness: 0.75, alpha: 1)
        @State var font = ContentPanelModel.FontModel(familyName: "System Serif", fontName: "Arial-BoldMT", size: 12, textCaseMode: .normal, smallCapsMode: .normal)

        let widgetColors = [
            HSBColor(uiColor: UIColor.red),
            HSBColor(uiColor: UIColor.orange),
            HSBColor(uiColor: UIColor.yellow),
            HSBColor(uiColor: UIColor.green),
            HSBColor(uiColor: UIColor.blue),
            HSBColor(uiColor: UIColor.purple),
            HSBColor(uiColor: UIColor.brown),
        ]

        var body: some View {
            ColorFieldEditor(colorField: $hsb, fieldName: "Text Color", widgetColors: widgetColors, hideFieldEditor: {})
        }
    }

    static var previews: some View {
        ZStack {
            Wrapper().frame(maxHeight: 700).padding(20)
        }
//        .previewDevice("iPod touch (7th generation)")
        .previewDevice("iPhone SE (2nd generation)")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FourPointGradient(startHue: 0.5, brightnessLight: 1.0, saturationLight: 0.35, brightnessDark: 0.2, saturationDark: 1.0))
        .ignoresSafeArea()
        .environment(\.sizeCategory, .extraSmall)
    }
}
