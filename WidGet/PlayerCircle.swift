//
//  PlayerCircle.swift
//  WidGet
//
//  Created by Bernstein, Joel on 7/20/20.
//

import SwiftUI

struct PlayerCircle: View, Identifiable {
    let id = UUID()
    @ObservedObject var player: Player

    @ScaledMetric(relativeTo: .body) var paddingSize: CGFloat = 8

    var body: some View {
        HStack(alignment: .center, spacing: paddingSize) {
            Image(systemName: "person.fill")
                .foregroundColor(player.color)
                .padding(paddingSize)
                .background(
                    Circle().foregroundColor(.yellow))

            Text(player.name)
                .layoutPriority(10)
        }
    }
}

struct PlayerCircle_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlayerCircle(player: Player(name: "Steve", color: .blue))
            PlayerCircle(player: Player(name: "Elizabeth", color: .purple))
            PlayerCircle(player: Player(name: "Elizabeth", color: .purple))
                .environment(\.sizeCategory, .accessibilityLarge)
        }
    }
}

class Player: Identifiable, ObservableObject {
    let id: UUID
    @Published var name: String
    @Published var color: Color

    init(id: UUID = UUID(), name: String, color: Color = .black) {
        self.id = id
        self.name = name
        self.color = color
    }
}
