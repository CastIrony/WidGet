//
//  HSVRGB.swift
//  WidGet
//
//  Created by Joel Bernstein on 9/27/20.
//

import CoreGraphics
import Foundation
import UIKit

// https://gist.github.com/FredrikSjoberg/cdea97af68c6bdb0a89e3aba57a966ce
// https://www.cs.rit.edu/~ncs/color/t_convert.html

struct RGBColor: Equatable, Codable {
    // Percent
    var red: CGFloat // [0,1]
    var green: CGFloat // [0,1]
    var blue: CGFloat // [0,1]
    var alpha: CGFloat // [0,1]

    private static func hsbColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> HSBColor
    {
        let min = red < green ? (red < blue ? red : blue) : (green < blue ? green : blue)
        let max = red > green ? (red > blue ? red : blue) : (green > blue ? green : blue)

        let v = max
        let delta = max - min

        guard delta > 0.00001 else { return HSBColor(hue: 0, saturation: 0, brightness: max, alpha: alpha) }
        guard max > 0 else { return HSBColor(hue: -1, saturation: 0, brightness: v, alpha: alpha) } // Undefined, achromatic grey
        let s = delta / max

        let hue: (CGFloat, CGFloat) -> CGFloat = {
            max, delta -> CGFloat in

            if red == max { return (green - blue) / delta } // between yellow & magenta
            else if green == max { return 2 + (blue - red) / delta } // between cyan & yellow
            else { return 4 + (red - green) / delta } // between magenta & cyan
        }

        let h = hue(max, delta) / 6 // In degrees

        return HSBColor(hue: h < 0 ? h + 1 : h, saturation: s, brightness: v, alpha: alpha)
    }

    static func hsbColor(rgb: RGBColor) -> HSBColor {
        return hsbColor(red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: rgb.alpha)
    }

    var hsb: HSBColor {
        get {
            return RGBColor.hsbColor(rgb: self)
        }
        set {
            let rgbColor = newValue.rgb
            red = rgbColor.red
            green = rgbColor.green
            blue = rgbColor.blue
            alpha = rgbColor.alpha
        }
    }

    var uiColor: UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    init(uiColor: UIColor) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 1

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    enum CodingKeys: String, CodingKey {
        case red
        case green
        case blue
        case alpha
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        red = try container.decode(CGFloat.self, forKey: .red)
        green = try container.decode(CGFloat.self, forKey: .green)
        blue = try container.decode(CGFloat.self, forKey: .blue)
        alpha = (try? container.decode(CGFloat.self, forKey: .alpha)) ?? 1
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(red, forKey: .red)
        try container.encode(green, forKey: .green)
        try container.encode(blue, forKey: .blue)
        try container.encode(alpha, forKey: .alpha)
    }

    var hexString: String {
        get {
            return String(format: "#%02X%02X%02X", Int(round(red * 255)), Int(round(green * 255)), Int(round(blue * 255)))
        }

        set {
            let start = newValue.index(newValue.startIndex, offsetBy: newValue.hasPrefix("#") ? 1 : 0)
            let hexColor = String(newValue[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    red = CGFloat((hexNumber & 0xFF00_0000) >> 24) / 255
                    green = CGFloat((hexNumber & 0x00FF_0000) >> 16) / 255
                    blue = CGFloat((hexNumber & 0x0000_FF00) >> 8) / 255
                    alpha = CGFloat(hexNumber & 0x0000_00FF) / 255

                    return
                }
            }
            else if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    red = CGFloat((hexNumber & 0x00FF_0000) >> 16) / 255
                    green = CGFloat((hexNumber & 0x0000_FF00) >> 8) / 255
                    blue = CGFloat(hexNumber & 0x0000_00FF) / 255

                    return
                }
            }
            // TODO: Handle other string lengths
        }
    }

    var opticalLuminance: CGFloat {
        return (red * 299 + green * 587 + blue * 114) / 1000
    }
}

struct HSBColor: Equatable, Codable, Identifiable, Hashable {
    var id: String { "\(hue),\(saturation),\(brightness)" }

    var hue: CGFloat // [0,1]
    var saturation: CGFloat // [0,1]
    var brightness: CGFloat // [0,1]
    var alpha: CGFloat // [0,1]

    private static func rgbColor(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) -> RGBColor
    {
        if saturation == 0 { return RGBColor(red: brightness, green: brightness, blue: brightness, alpha: alpha) } // Achromatic grey

        let angle = (hue >= 1 ? 0 : hue)
        let sector = angle * 6 // Sector
        let i = floor(sector)
        let f = sector - i // Factorial part of h

        let p = brightness * (1 - saturation)
        let q = brightness * (1 - (saturation * f))
        let t = brightness * (1 - (saturation * (1 - f)))

        switch i {
        case 0: return RGBColor(red: brightness, green: t, blue: p, alpha: alpha)
        case 1: return RGBColor(red: q, green: brightness, blue: p, alpha: alpha)
        case 2: return RGBColor(red: p, green: brightness, blue: t, alpha: alpha)
        case 3: return RGBColor(red: p, green: q, blue: brightness, alpha: alpha)
        case 4: return RGBColor(red: t, green: p, blue: brightness, alpha: alpha)
        default: return RGBColor(red: brightness, green: p, blue: q, alpha: alpha)
        }
    }

    static func rgbColor(hsbColor: HSBColor) -> RGBColor {
        return rgbColor(hue: hsbColor.hue, saturation: hsbColor.saturation, brightness: hsbColor.brightness, alpha: hsbColor.alpha)
    }

    var rgb: RGBColor {
        get {
            return HSBColor.rgbColor(hsbColor: self)
        }
        set {
            let hsbColor = newValue.hsb
            hue = hsbColor.hue
            saturation = hsbColor.saturation
            brightness = hsbColor.brightness
            alpha = hsbColor.alpha
        }
    }

    var uiColor: UIColor {
        UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }

    init(uiColor: UIColor) {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 1

        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.alpha = alpha
    }

    init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.alpha = alpha
    }

    enum CodingKeys: String, CodingKey {
        case hue
        case saturation
        case brightness
        case alpha
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        hue = try container.decode(CGFloat.self, forKey: .hue)
        saturation = try container.decode(CGFloat.self, forKey: .saturation)
        brightness = try container.decode(CGFloat.self, forKey: .brightness)
        alpha = (try? container.decode(CGFloat.self, forKey: .alpha)) ?? 1
    }

    var hexString: String {
        get {
            rgb.hexString
        }

        set {
            var rgb = self.rgb
            rgb.hexString = newValue
            let hsb = rgb.hsb

            hue = hsb.hue
            saturation = hsb.saturation
            brightness = hsb.brightness
            alpha = hsb.alpha
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hue, forKey: .hue)
        try container.encode(saturation, forKey: .saturation)
        try container.encode(brightness, forKey: .brightness)
        try container.encode(alpha, forKey: .alpha)
    }

    func replacingAlpha(_ alpha: CGFloat) -> HSBColor {
        var color = self
        color.alpha = alpha
        return color
    }

    var opticalLuminance: CGFloat {
        return rgb.opticalLuminance
    }
}
