//
//  HistogramChannel.swift
//  
//
//  Created by Vasilis Akoinoglou on 20/10/21.
//

import SwiftUI

struct HistogramChannel: Shape {

    let data: [UInt]
    let scale: CGFloat
    let orientation:UIDeviceOrientation
    var points:[CGPoint]{
        return Array(data.enumerated().map { (index, element) in
            let y = 1 - (CGFloat(element) / CGFloat(maximum)) * scale
            let x = CGFloat(index) / CGFloat(data.count-1)
            let offset = 1/CGFloat(data.count)
            return [CGPoint(x: x-offset, y: y),CGPoint(x:x, y:y)]
        }.joined())
    }
    private var maximum: UInt { data.max() ?? 0 }
    
    func path(in rect: CGRect) -> Path {
        
        Path { path in
            switch orientation {
            case .portrait,.unknown,.faceUp,.faceDown:
                path.move(to: CGPoint(x: 0, y: rect.height))
                path.addLines(points.map{
                    CGPoint(x: $0.x * rect.width, y: $0.y * rect.height)
                })
                path.addLine(to: CGPoint(x: rect.width, y: rect.height))
                path.addLine(to: CGPoint(x: 0, y: rect.height))
            case .portraitUpsideDown:
                path.move(to: CGPoint(x: rect.width, y: 0))
                path.addLines(points.map{
                    CGPoint(x: rect.width - $0.x * rect.width, y: rect.height - $0.y * rect.height)
                })
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: rect.width, y: 0))
            case .landscapeRight:
                path.move(to: CGPoint(x: rect.width, y: rect.height))
                path.addLines(points.map{
                   CGPoint(x: $0.y * rect.width, y: (1-$0.x) * rect.height)
                })
                path.addLine(to: CGPoint(x: rect.width, y: 0))
                path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            case .landscapeLeft:
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLines(points.map{
                    CGPoint(x: rect.width - $0.y * rect.width, y: rect.height - (1-$0.x) * rect.height)
                })
                path.addLine(to: CGPoint(x: 0, y: rect.height))
                path.addLine(to: CGPoint(x: 0, y: 0))
            }
        }
    }

}
