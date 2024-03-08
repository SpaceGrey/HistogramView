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
        
    private var step:Int

    public init(image: HistogramImage, channelOpacity: CGFloat = 1, blendMode: BlendMode = .screen, scale: CGFloat = 1, orientation: UIDeviceOrientation, multiChannel: Bool,step:Int) {
        self.image          = image.cgImage!
        self.channelOpacity = channelOpacity
        self.blendMode      = blendMode
        self.scale          = scale
        self.orientation    = orientation
        self.multiChannel   = multiChannel
        self.step           = step
    }

    public var body: some View {
        if multiChannel{
            if let data = image.histogram(step: step) {
                ZStack {
                    Group {
                        HistogramChannel(data: data.red, scale: scale, orientation: orientation).foregroundColor(.red)                    .opacity(channelOpacity)

                        HistogramChannel(data: data.green, scale: scale,orientation: orientation).foregroundColor(.green)
                            .opacity(channelOpacity)

                        HistogramChannel(data: data.blue, scale: scale,orientation: orientation).foregroundColor(.blue)
                            .opacity(channelOpacity)
                    }
                    .blendMode(blendMode)
                }
                .drawingGroup()
            }
        }
        else{
            if let data = image.singleHistogram(step: step){
                ZStack{
                    HistogramChannel(data: data, scale: scale, orientation: orientation)
                        .foregroundColor(.white)
                        .opacity(channelOpacity)

                    
                }
                    .drawingGroup()
            }
        }
    }
}



