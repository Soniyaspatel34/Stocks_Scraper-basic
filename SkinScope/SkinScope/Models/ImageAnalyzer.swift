import CoreImage
import UIKit

/// Whole-image average color stats — nothing more. This is a coarse pixel
/// average (via Core Image's area-average filter), not a measurement of skin
/// condition: lighting, white balance, distance, and angle will move these
/// numbers more than any actual change in skin would. Shown in the Compare
/// view as a rough visual aid only.
struct ImageMetrics {
    /// 0 (black) – 1 (white) average brightness across the whole frame.
    let brightness: Double
    /// 0–1 share of the red channel within R+G+B; higher reads "redder".
    let redness: Double
}

enum ImageAnalyzer {
    static func metrics(for image: UIImage) -> ImageMetrics? {
        guard let ciImage = CIImage(image: image) else { return nil }

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: ciImage,
            kCIInputExtentKey: CIVector(cgRect: ciImage.extent)
        ]), let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: NSNull()])
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )

        let r = Double(bitmap[0]) / 255.0
        let g = Double(bitmap[1]) / 255.0
        let b = Double(bitmap[2]) / 255.0
        let total = r + g + b

        return ImageMetrics(
            brightness: total / 3.0,
            redness: total > 0 ? r / total : 0
        )
    }
}
