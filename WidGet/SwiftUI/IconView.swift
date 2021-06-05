//
//  IconView.swift
//  WidGet
//
//  Created by Bernstein, Joel on 7/20/20.
//

import SwiftUI

struct IconView: View {
    let cornerRadius = CGFloat(115)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius * 2 * 0, style: .continuous)
                .fill(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 1, green: 0.6235829871, blue: 0, alpha: 1)), Color(#colorLiteral(red: 0.9130458252, green: 0.3243066352, blue: 0, alpha: 1)), Color(#colorLiteral(red: 0.919741599, green: 0, blue: 0.01532902666, alpha: 1))]), startPoint: .top, endPoint: .bottom))
//                .frame(width: 1024, height: 1024, alignment: .center)

//            ZStack
//            {
//            }
//            .compositingGroup()
//            .blendMode(.screen)

            RoundedRectangle(cornerRadius: cornerRadius * 2, style: .continuous)
                .inset(by: 120)
                .fill(Color.white)
                // .frame(width: 1024, height: 1024, alignment: .center)
                .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 35)

            RoundedRectangle(cornerRadius: cornerRadius * 2, style: .continuous)
                .inset(by: 150)
                .fill(Color(white: 0.96, opacity: 1))
            // .frame(width: 1024, height: 1024, alignment: .center)
            // .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 35)

            Text("WID")
                .foregroundColor(.black)
                .font(Font.system(size: 360, weight: Font.Weight.bold, design: Font.Design.rounded).smallCaps())
                .offset(x: 0, y: -162 - 27)

            Text("GET")
                .foregroundColor(.black)
                .font(Font.system(size: 360, weight: Font.Weight.bold, design: Font.Design.rounded).smallCaps())
                .offset(x: 0, y: 162 - 22)
        }
    }
}

struct IconView_Previews: PreviewProvider {
    static var previews: some View {
        IconView()
            .previewLayout(.fixed(width: 1024, height: 1024))
    }
}
