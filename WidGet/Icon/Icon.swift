//
//  Icon.swift
//
//  Created by Zac White.
//  Copyright © 2020 Velos Mobile LLC / https://velosmobile.com / All rights reserved.
//

import SwiftUI

struct Icon: View {
    var body: some View {
        let cornerRadius = CGFloat(230)

        IconStack {
            canvas in
            ZStack {
//                RoundedRectangle(cornerRadius: canvas[cornerRadius * 0] , style: .continuous)
//                    .fill(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 1, green: 0.6235829871, blue: 0, alpha: 1)), Color(#colorLiteral(red: 0.9488901478, green: 0.3370382543, blue: 0, alpha: 1)), Color(#colorLiteral(red: 0.919741599, green: 0, blue: 0.01532902666, alpha: 1)), Color(#colorLiteral(red: 0.7517621157, green: 0, blue: 0.6094596243, alpha: 1))]), startPoint: .top, endPoint: .bottom))
//
//                RoundedRectangle(cornerRadius: canvas[cornerRadius], style: .continuous)
//                    .inset(by: canvas[120])
//                    .fill(Color.white)
//                    .shadow(color: Color(#colorLiteral(red: 0.5, green: 0.1775960342, blue: 0, alpha: 1)).opacity(0.6), radius: canvas[10], x: 0, y: canvas[18])
//
//                RoundedRectangle(cornerRadius: canvas[cornerRadius], style: .continuous)
//                    .inset(by: canvas[150])
//                    .fill(Color(#colorLiteral(red: 0.8537944547, green: 0.9499960396, blue: 1, alpha: 1)))
//
//                Text("WID")
//                    .foregroundColor(Color(#colorLiteral(red: 0, green: 0.4245878609, blue: 0.6526296053, alpha: 1)))
//                    .font(Font.system(size: canvas[360], weight: Font.Weight.bold, design: Font.Design.rounded).smallCaps())
//                    .offset(x: 0, y: canvas[-162 - 27])
//
//                Text("GET")
//                    .foregroundColor(Color(#colorLiteral(red: 0, green: 0.4245878609, blue: 0.6526296053, alpha: 1)))
//                    .font(Font.system(size: canvas[360], weight: Font.Weight.bold, design: Font.Design.rounded).smallCaps())
//                    .offset(x: 0, y: canvas[162 - 22])

                Color.black

                ZStack {
                    RoundedRectangle(cornerRadius: canvas[cornerRadius], style: .continuous)
                        .inset(by: canvas[120])
                        .fill(Color.white)

                    RoundedRectangle(cornerRadius: canvas[cornerRadius], style: .continuous)
                        .inset(by: canvas[150])
                        .fill(Color(white: 0))

                    Text("WID")
                        .foregroundColor(Color.white)
                        .font(Font.system(size: canvas[360], weight: Font.Weight.bold, design: Font.Design.rounded).smallCaps())
                        .offset(x: 0, y: canvas[-162 - 27])

                    Text("GET")
                        .foregroundColor(Color.white)
                        .font(Font.system(size: canvas[360], weight: Font.Weight.bold, design: Font.Design.rounded).smallCaps())
                        .offset(x: 0, y: canvas[162 - 22])
                }
                .compositingGroup()
                // .opacity(0.1)
            }
        }
    }

    //        /// Note: All of these assume a canvas size of 1024.
//        let spacing: CGFloat = 80
//        let radius: CGFloat = 135
//        let pillLength: CGFloat = 350
//        let pillRotation: Angle = .degrees(30)
//        let circleOffsetX: CGFloat = 50
//        let circleOffsetY: CGFloat = 20
//
//        let velosBackground = Color(red: 0/256, green: 180/256, blue: 185/256)
//        let velosPrimary = Color.white
//        let velosSecondary = Color(red: 248/256, green: 208/256, blue: 55/256)
//
//        return IconStack { canvas in
//            velosBackground
//                .edgesIgnoringSafeArea(.all)
//
//            HStack(alignment: .center, spacing: canvas[spacing]) {
//                HStack(alignment: .top, spacing: canvas[spacing]) {
//                    Circle()
//                        .fill(velosPrimary)
//                        .frame(width: canvas[radius], height: canvas[radius])
//                        .offset(x: canvas[circleOffsetX], y: canvas[circleOffsetY])
//                    RoundedRectangle(cornerRadius: canvas[radius])
//                        .fill(velosPrimary)
//                        .frame(width: canvas[radius], height: canvas[pillLength])
//                        .rotationEffect(pillRotation)
//                }
//                HStack(alignment: .bottom, spacing: canvas[spacing]) {
//                    RoundedRectangle(cornerRadius: canvas[radius])
//                        .fill(velosSecondary)
//                        .frame(width: canvas[radius], height: canvas[pillLength])
//                        .rotationEffect(pillRotation)
//                    RoundedRectangle(cornerRadius: canvas[radius])
//                        .fill(velosSecondary)
//                        .frame(width: canvas[radius], height: canvas[pillLength])
//                        .rotationEffect(pillRotation)
//                    Circle()
//                        .fill(velosSecondary)
//                        .frame(width: canvas[radius], height: canvas[radius])
//                        .offset(x: -canvas[circleOffsetX], y: -canvas[circleOffsetY])
//                }
//            }
//        }
}

#if DEBUG
    struct Icon_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                Icon()
//                .previewIcon()
                    .previewLayout(.fixed(width: 512, height: 512))

                Icon()
                    .previewHomescreen()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .orange]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .previewLayout(.fixed(width: 500, height: 500))
            }
        }
    }
#endif
