//
//  ClockView.swift
//  Rise by We
//
//  Created by Benjamin Leonardo Sage on 6/29/21.
//

import SwiftUI

struct ClockView: View {
    @State var timeElapsed: TimeInterval = 0
    let start = Date()
    var timer = Timer.publish(every: 0.016666666666667, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Clock(time: timeElapsed).onReceive(timer) { t in
            timeElapsed = t.timeIntervalSince(start)
        }
    }
}

struct Clock: View {
    var time: TimeInterval
    
    func tick(at tick: Int) -> some View {
        VStack(spacing: 3) {
            Rectangle()
                .rotation(Angle.degrees(1))
                .rotation(Angle.degrees(-1))
                .fill(tick % 10 == 0 ? Color.primary : Color.secondary, style: FillStyle(antialiased: true))
                .frame(width: 2, height: tick % 2 == 0 ? 15 : 7)
            if tick % 30 == 0 {
                Text(tick == 0 ? "60" : String(tick/2))
                    .font(.title)
                    .rotationEffect(-Angle.degrees(Double(tick)/120 * 360))
            }
            Spacer()
        }
        .rotationEffect(Angle.degrees(Double(tick)/120 * 360))
    }
    
    var body: some View {
        ZStack {
            ForEach(0..<60*2) { tick in
                self.tick(at: tick)
            }
            Pointer()
                .stroke(Color.orange, lineWidth: 2)
                .rotationEffect(Angle.degrees(Double(time)) * 360/60)
            Color.clear
        }
    }
}

struct Pointer: Shape {
    var circleRadius: CGFloat = 3
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.midX, y: rect.midY - circleRadius))
            p.addEllipse(in: CGRect(center: rect.center, radius: circleRadius))
            p.move(to: CGPoint(x: rect.midX, y: rect.midY + circleRadius))
            p.addLine(to: CGPoint(x: rect.midX, y: rect.midY + rect.height / 10))
        }
    }
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
    
    init(center: CGPoint, radius: CGFloat) {
        self = CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        )
    }
}

struct ClockView_Previews: PreviewProvider {
    static var previews: some View {
        Clock(time: 17)
            .frame(width: 200, height: 200)
    }
}
