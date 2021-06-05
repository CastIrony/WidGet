//
//  File.swift
//  WidGet
//
//  Created by Joel Bernstein on 8/14/20.
//

import SwiftUI

struct FourPointGradient: View {
    let startHue: Double

    let brightnessLight: Double
    let saturationLight: Double

    let brightnessDark: Double
    let saturationDark: Double

    var body: some View {
        Color.clear
            .ignoresSafeArea()
            .modifier(Modifier(startHue: startHue, brightnessLight: brightnessLight, saturationLight: saturationLight, brightnessDark: brightnessDark, saturationDark: saturationDark))
            .onAppear {
//            withAnimation(Animation.linear(duration: 60).repeatForever(autoreverses: false))
//            {
//                startHue += 1
//            }
            }
    }

    struct Modifier: ViewModifier {
        @Environment(\.colorScheme) var colorScheme

        var startHue: Double

        let brightnessLight: Double
        let saturationLight: Double

        let brightnessDark: Double
        let saturationDark: Double

        var saturation: Double { colorScheme == .dark ? saturationDark : saturationLight }
        var brightness: Double { colorScheme == .dark ? brightnessDark : brightnessLight }

        var offset1: Double = 1.0 / 8.0
        var offset2: Double = 0.0 / 8.0
        var offset4: Double = -1.0 / 8.0
        var offset3: Double = -2.0 / 8.0

//        var animatableData: Double
//        {
//            get { startHue }
//            set { startHue = newValue }
//        }

        func body(content: Content) -> some View {
            let color1 = Color(hue: wrap(startHue + offset1, to: 1.0), saturation: saturation, brightness: brightness)
            let color2 = Color(hue: wrap(startHue + offset2, to: 1.0), saturation: saturation, brightness: brightness)
            let color3 = Color(hue: wrap(startHue + offset3, to: 1.0), saturation: saturation, brightness: brightness)
            let color4 = Color(hue: wrap(startHue + offset4, to: 1.0), saturation: saturation, brightness: brightness)

            let gradient1 = Gradient(colors: [color1, color2])
            let gradient2 = Gradient(colors: [color4, color3])
            let gradient3 = Gradient(colors: [.black, .clear])

            return content.overlay(
                LinearGradient(gradient: gradient1, startPoint: .leading, endPoint: .trailing)
                    .ignoresSafeArea()
                    // .aspectRatio(1, contentMode: .fill)
                    .overlay(
                        LinearGradient(gradient: gradient2, startPoint: .leading, endPoint: .trailing)
                            .ignoresSafeArea()
                            .mask(
                                LinearGradient(gradient: gradient3, startPoint: .bottom, endPoint: .top)
                                    .ignoresSafeArea()
                            )
                    )
                // .scaleEffect(1.2)
                // .rotationEffect(Angle(degrees: startHue * -360))
            )
        }
    }
}

func wrap<T>(_ number: T, to limit: T) -> T where T: FloatingPoint {
    return fmod(fmod(number, limit) + limit, limit)
}

struct FourPointGradient_Previews: PreviewProvider {
    static var previews: some View {
        FourPointGradient(startHue: 0.5, brightnessLight: 1.0, saturationLight: 0.5, brightnessDark: 0.2, saturationDark: 1.0)
    }
}
