//
//  LoadingOverlayView.swift
//  WidGet
//
//  Created by Joel Bernstein on 9/7/20.
//

import SwiftUI

struct LoadingOverlayView: View {
    let handlingLink: Bool
    let linkDescription: String

    var body: some View {
        ZStack {
            if handlingLink {
                Color(white: 0.2).ignoresSafeArea().transition(.identity)

                if linkDescription.count > 0 {
                    VStack(spacing: 30) {
                        Text("Loading").font(.largeTitle.bold().smallCaps()).foregroundColor(Color(white: 0.4)).transition(.identity)

                        Text(linkDescription)
                            .font(.largeTitle.bold())
                            .foregroundColor(Color(white: 0.4))
                            .multilineTextAlignment(.center)
                            .transition(.identity)
                    }
                    .padding(30)
                }
            }
        }
    }
}
