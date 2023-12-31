import SwiftUI
import CoreGraphics
import Accelerate

#if canImport(UIKit)
import UIKit
public typealias HistogramImage = UIImage
#endif

#if canImport(AppKit)
import AppKit
public typealias HistogramImage = NSImage
#endif


/// A SwiftUI Image Histogram View (for RGB channels)
public struct HistogramView: View {

    /// The image from which the histogram will be calculated
    private let image: CGImage

    /// The opacity of each channel layer. Default is `1`
    private let channelOpacity: CGFloat

    /// The blend mode for the channel layers. Default is `.screen`
    private let blendMode: BlendMode

    /// The scale of each layer. Default is `1`
    private let scale: CGFloat
    
    private let orientation: UIDeviceOrientation
    
    private let multiChannel: Bool
    
    private let lineWidth: CGFloat = 1.0

    public init(image: HistogramImage, channelOpacity: CGFloat = 1, blendMode: BlendMode = .screen, scale: CGFloat = 1, orientation: UIDeviceOrientation, multiChannel: Bool) {
        self.image          = image.cgImage!
        self.channelOpacity = channelOpacity
        self.blendMode      = blendMode
        self.scale          = scale
        self.orientation    = orientation
        self.multiChannel   = multiChannel
    }

    public var body: some View {
        if multiChannel{
            if let data = image.histogram() {
                ZStack {
                    Group {
                        HistogramChannel(data: data.red, scale: scale, orientation: orientation).foregroundColor(.red)                    .opacity(channelOpacity)
                        HistogramChannel(data: data.red, scale: scale, orientation: orientation).stroke(.red, lineWidth: lineWidth)
                        HistogramChannel(data: data.green, scale: scale,orientation: orientation).foregroundColor(.green)
                            .opacity(channelOpacity)
                        HistogramChannel(data: data.green, scale: scale,orientation: orientation).stroke(.green, lineWidth: lineWidth)
                        HistogramChannel(data: data.blue, scale: scale,orientation: orientation).foregroundColor(.blue)
                            .opacity(channelOpacity)
                        HistogramChannel(data: data.blue, scale: scale,orientation: orientation).stroke(.blue,lineWidth: lineWidth)
                    }
                    .blendMode(blendMode)
                }
                .drawingGroup()
            }
        }
        else{
            if let data = image.singleHistogram(){
                ZStack{
                    HistogramChannel(data: data, scale: scale, orientation: orientation)
                        .foregroundColor(.white)
                        .opacity(channelOpacity)
                    HistogramChannel(data: data, scale: scale, orientation: orientation)
                        .stroke(.white, lineWidth: lineWidth)
                    
                }
                    .drawingGroup()
            }
        }
    }
}



