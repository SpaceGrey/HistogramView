//
//  CGImage+Histogram.swift
//  
//
//  Created by Vasilis Akoinoglou on 20/10/21.
//

import Foundation
import Accelerate

extension CGImage {

    /// The function calculates the histogram for each channel completely separately from the others.
    /// - Returns: A tuple contain the three histograms for the corresponding channels. Each of the three histograms will be an array with 256 elements.
    func histogram(step:Int = 1) -> (red: [UInt], green: [UInt], blue: [UInt])? {
        let format = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
            renderingIntent: .defaultIntent)!

        guard var sourceBuffer = try? vImage_Buffer(cgImage: self, format: format) else {
            return nil
        }

        defer {
            sourceBuffer.free()
        }

        var histogramBinZero  = [vImagePixelCount](repeating: 0, count: 256)
        var histogramBinOne   = [vImagePixelCount](repeating: 0, count: 256)
        var histogramBinTwo   = [vImagePixelCount](repeating: 0, count: 256)
        var histogramBinThree = [vImagePixelCount](repeating: 0, count: 256)

        histogramBinZero.withUnsafeMutableBufferPointer { zeroPtr in
            histogramBinOne.withUnsafeMutableBufferPointer { onePtr in
                histogramBinTwo.withUnsafeMutableBufferPointer { twoPtr in
                    histogramBinThree.withUnsafeMutableBufferPointer { threePtr in

                        var histogramBins = [zeroPtr.baseAddress, onePtr.baseAddress,
                                             twoPtr.baseAddress, threePtr.baseAddress]

                        histogramBins.withUnsafeMutableBufferPointer { histogramBinsPtr in
                            let error = vImageHistogramCalculation_ARGB8888(&sourceBuffer,
                                                                            histogramBinsPtr.baseAddress!,
                                                                            vImage_Flags(kvImageNoFlags))

                            guard error == kvImageNoError else {
                                fatalError("Error calculating histogram: \(error)")
                            }
                        }
                    }
                }
            }
        }
        for i in stride(from: 0, through: 255, by: step){
            for j in 0..<step{
                histogramBinZero[i/step] += histogramBinZero[i+j]
                histogramBinOne[i/step] += histogramBinOne[i+j]
                histogramBinTwo[i/step] += histogramBinTwo[i+j]
            }
        }
        let num = 256/step - 1
        histogramBinZero = Array(histogramBinZero[0...num])
        histogramBinOne = Array(histogramBinOne[0...num])
        histogramBinTwo = Array(histogramBinTwo[0...num])
        return (histogramBinZero, histogramBinOne, histogramBinTwo)
    }
    // create a single channel histogram
    public func singleHistogram(step:Int = 1) -> [UInt]? {
        let format = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
            renderingIntent: .defaultIntent)!
        
        guard var sourceBuffer = try? vImage_Buffer(cgImage: self, format: format) else {
            return nil
        }
        
        defer {
            sourceBuffer.free()
        }
        
        var histogramBinZero  = [vImagePixelCount](repeating: 0, count: 256)
        histogramBinZero.withUnsafeMutableBufferPointer { zeroPtr in
            let error = vImageHistogramCalculation_Planar8(&sourceBuffer, zeroPtr.baseAddress!, vImage_Flags(kvImageNoFlags))
            
            guard error == kvImageNoError else {
                fatalError("Error calculating histogram: \(error)")
            }
        }
        //return the slide of histogram
        for i in stride(from: 0, through: 255, by: step){
            for j in 0..<step{
                histogramBinZero[i/step] += histogramBinZero[i+j]
            }
        }
        let num = 256/step - 1
        return Array(histogramBinZero[0...num-1])
    }

}

#if os(macOS)
import AppKit
public extension NSImage {
    var cgImage: CGImage? {
        guard let imageData = tiffRepresentation else { return nil }
        guard let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(sourceData, 0, nil)
    }
}
#endif
