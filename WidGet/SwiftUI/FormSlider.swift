//
//  FormSlider.swift
//  WidGet
//
//  Created by Joel Bernstein on 9/25/20.
//

import SwiftUI

struct FormSlider: View {
    @Binding var value: CGFloat
    let bounds: ClosedRange<CGFloat>
    let step: CGFloat.Stride
    let labelSpecifier: String

    @ScaledMetric(wrappedValue: 48, relativeTo: .body) var handleWidth: CGFloat
    @ScaledMetric(wrappedValue: 36, relativeTo: .body) var handleHeight: CGFloat

    let backgroundGradient: Gradient?

    @GestureState var isDragging: Bool = false
    @State var impactGenerator = UIImpactFeedbackGenerator(style: .soft)

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader {
            geometry in

            let sliderWidth = geometry.size.width - handleWidth
            let handlePosition = CGFloat((value - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)) * sliderWidth

            ZStack {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .inset(by: -1)
                    .fill(colorScheme == .light ? Color.black.opacity(0.078) : Color.white.opacity(0.15))
                    .overlay(
                        sliderTrack(handlePosition: handlePosition)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .inset(by: -1)
                            .strokeBorder(colorScheme == .light ? Color.black.opacity(0.15) : Color.white.opacity(0.15))
                    )
                    .overlay(
                        sliderHandle(handlePosition: handlePosition)
                            .gesture(sliderDragGesture(sliderWidth: sliderWidth))
                    )
                    .coordinateSpace(name: "slider")
            }
        }
        .frame(height: handleHeight)
        .onChange(of: value) {
            _ in

            if (bounds.upperBound - bounds.lowerBound) / step.magnitude < 25 {
                impactGenerator.impactOccurred()
            }
        }
        .preference(key: DragInProgressPreferenceKey.self, value: isDragging)
    }

    @ViewBuilder
    func sliderHandle(handlePosition: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: isDragging ? 12 : 6, style: .continuous).inset(by: -1)
            .fill(colorScheme == .light ? Color.white : Color.black)
            .overlay(RoundedRectangle(cornerRadius: isDragging ? 12 : 6, style: .continuous).inset(by: -1).strokeBorder(Color.white.opacity((colorScheme == .dark && isDragging) ? 0.35 : 0)))
            .frame(width: isDragging ? handleWidth + 20 : handleWidth - 2, height: isDragging ? handleHeight + 60 : handleHeight - 2)
            .position(x: handlePosition + handleWidth / 2, y: isDragging ? handleHeight / 2 - 31 : handleHeight / 2)
            .shadow(color: colorScheme == .light ? Color.black.opacity(isDragging ? 0.3 : 0) : Color.purple.opacity(isDragging ? 0.7 : 0), radius: isDragging ? 5 : 0, x: 0, y: 0)
            .overlay(
                Text("\(value, specifier: labelSpecifier)")
                    .fontWeight(.semibold)
                    .position(x: handlePosition + handleWidth / 2, y: isDragging ? handleHeight / 2 - 59 : handleHeight / 2)
            )
    }

    @ViewBuilder
    func sliderTrack(handlePosition: CGFloat) -> some View {
        if let backgroundGradient = backgroundGradient {
            ZStack {
                Image("alpha").resizable(resizingMode: .tile)
                LinearGradient(gradient: backgroundGradient, startPoint: .leading, endPoint: .trailing)
            }
            .padding(-1)
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous).inset(by: -1))
        } else {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .inset(by: -1)
                .fill(colorScheme == .light ? Color.white : Color.black)
                .frame(width: handlePosition + handleWidth - 2, height: handleHeight - 2)
                .position(x: (handlePosition + handleWidth - 2) / 2 + 1, y: handleHeight / 2)
                .animation(.interactiveSpring())
        }
    }

    func sliderDragGesture(sliderWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named("slider"))
            .updating($isDragging) {
                _, state, _ in

                withAnimation(.spring()) {
                    state = true
                }
            }
            .onChanged {
                gestureValue in

                if isDragging {
                    let proportion = max(min((gestureValue.location.x - handleWidth / 2) / sliderWidth, 1), 0)
                    let unroundedValue = CGFloat(proportion) * (bounds.upperBound - bounds.lowerBound)

                    withAnimation(.interactiveSpring()) {
                        value = round(unroundedValue / step) * step + bounds.lowerBound
                    }
                }
            }
    }
}

struct FormSlider_Previews: PreviewProvider {
    struct Wrapper: View {
        @State var value: CGFloat = 10

        var body: some View {
            let bounds: ClosedRange<CGFloat> = ClosedRange(uncheckedBounds: (lower: 0, upper: 20))

            FormSlider(value: $value, bounds: bounds, step: 1, labelSpecifier: "%0.0f", backgroundGradient: nil)
        }
    }

    static var previews: some View {
        Wrapper().padding(40)
    }
}
