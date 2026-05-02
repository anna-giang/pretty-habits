//
//  RingViews.swift
//  pretty-habits
//  Credit to https://medium.com/@frankjia/creating-activity-rings-in-swiftui-11ef7d336676
//
import SwiftUI

extension Double {
    func toRadians() -> Double { self * Double.pi / 180 }
    func toCGFloat() -> CGFloat { CGFloat(self) }
}

struct RingShape: Shape {
    static func percentToAngle(percent: Double, startAngle: Double) -> Double {
        (percent / 100 * 360) + startAngle
    }

    private var percent: Double
    private var startAngle: Double
    private let drawnClockwise: Bool

    var animatableData: Double {
        get { percent }
        set { percent = newValue }
    }

    init(percent: Double = 100, startAngle: Double = -90, drawnClockwise: Bool = false) {
        self.percent = percent
        self.startAngle = startAngle
        self.drawnClockwise = drawnClockwise
    }

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let endAngle = Angle(degrees: RingShape.percentToAngle(percent: percent, startAngle: startAngle))
        return Path { path in
            path.addArc(center: center, radius: radius,
                        startAngle: Angle(degrees: startAngle),
                        endAngle: endAngle, clockwise: drawnClockwise)
        }
    }
}

struct PercentageRing: View {
    private static let ShadowColor: Color = Color.black.opacity(0.2)
    private static let ShadowRadius: CGFloat = 5
    private static let ShadowOffsetMultiplier: CGFloat = ShadowRadius + 2

    let ringWidth: CGFloat
    let percent: Double
    let backgroundColor: Color
    let foregroundColors: [Color]

    private let startAngle: Double = -90

    private var gradientStartAngle: Double {
        percent >= 100 ? relativePercentageAngle - 360 : startAngle
    }
    private var absolutePercentageAngle: Double {
        RingShape.percentToAngle(percent: percent, startAngle: 0)
    }
    private var relativePercentageAngle: Double {
        absolutePercentageAngle + startAngle
    }
    private var lastGradientColor: Color {
        foregroundColors.last ?? .black
    }
    private var ringGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: foregroundColors),
            center: .center,
            startAngle: Angle(degrees: gradientStartAngle),
            endAngle: Angle(degrees: relativePercentageAngle)
        )
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RingShape()
                    .stroke(style: StrokeStyle(lineWidth: ringWidth))
                    .fill(backgroundColor)
                RingShape(percent: percent, startAngle: startAngle)
                    .stroke(style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
                    .fill(ringGradient)
                if getShowShadow(frame: geometry.size) {
                    Circle()
                        .fill(lastGradientColor)
                        .frame(width: ringWidth, height: ringWidth)
                        .offset(x: getEndCircleLocation(frame: geometry.size).0,
                                y: getEndCircleLocation(frame: geometry.size).1)
                        .shadow(color: PercentageRing.ShadowColor,
                                radius: PercentageRing.ShadowRadius,
                                x: getEndCircleShadowOffset().0,
                                y: getEndCircleShadowOffset().1)
                }
            }
        }
        .padding(ringWidth / 2)
    }

    private func getEndCircleLocation(frame: CGSize) -> (CGFloat, CGFloat) {
        let angleOfEndInRadians = relativePercentageAngle.toRadians()
        let offsetRadius = min(frame.width, frame.height) / 2
        return (
            offsetRadius * cos(angleOfEndInRadians).toCGFloat(),
            offsetRadius * sin(angleOfEndInRadians).toCGFloat()
        )
    }

    private func getEndCircleShadowOffset() -> (CGFloat, CGFloat) {
        let angle = (absolutePercentageAngle + startAngle + 90).toRadians()
        return (
            cos(angle).toCGFloat() * PercentageRing.ShadowOffsetMultiplier,
            sin(angle).toCGFloat() * PercentageRing.ShadowOffsetMultiplier
        )
    }

    private func getShowShadow(frame: CGSize) -> Bool {
        let circleRadius = min(frame.width, frame.height) / 2
        let remainingAngle = (360 - absolutePercentageAngle).toRadians().toCGFloat()
        return percent >= 100 || circleRadius * remainingAngle <= ringWidth
    }
}

/// Stacked concentric rings for up to 5 habits
struct HabitRingsView: View {
    let habits: [HabitEntry]

    // Ring sizing: outermost ring is largest
    private let baseSize: CGFloat = 260
    private let ringSpacing: CGFloat = 36   // gap between ring centres
    private let ringWidth: CGFloat = 26

    var body: some View {
        ZStack {
            ForEach(Array(habits.prefix(5).enumerated()), id: \.element.id) { index, habit in
                let size = baseSize - CGFloat(index) * ringSpacing
                PercentageRing(
                    ringWidth: ringWidth,
                    percent: habit.completionPercent,
                    backgroundColor: habit.color.opacity(0.15),
                    foregroundColors: [habit.color, habit.color.opacity(0.7)]
                )
                .frame(width: size, height: size)
                .animation(.easeInOut(duration: 0.6), value: habit.completionPercent)
            }
        }
        .frame(height: baseSize + ringWidth)
    }
}
