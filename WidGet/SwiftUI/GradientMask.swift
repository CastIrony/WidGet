//
//  GradientMask.swift
//  WidGet
//
//  Created by Joel Bernstein on 8/22/20.
//

import SwiftUI

struct GradientMask: View {
    let top: CGFloat
    let bottom: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black]), startPoint: .top, endPoint: .bottom)
                .frame(height: top)
                .fixedSize(horizontal: false, vertical: true)
                .ignoresSafeArea()

            Color.black
                .ignoresSafeArea()

            LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear]), startPoint: .top, endPoint: .bottom)
                .frame(height: bottom)
                .fixedSize(horizontal: false, vertical: true)
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }
}
