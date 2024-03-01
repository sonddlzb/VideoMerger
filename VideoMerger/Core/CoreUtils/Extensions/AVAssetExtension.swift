//
//  AVAssetExtension.swift
//
//  Created by Le Toan on 9/10/20.
//  Copyright © 2020 thanhvu. All rights reserved.
//

import AVFoundation
import UIKit

public extension AVAsset {
    var thumbnailImage: UIImage {
        var image = UIImage()
        do {
            let imgGenerator = AVAssetImageGenerator(asset: self)
            let cgImage = try! imgGenerator.copyCGImage(at: .zero, actualTime: nil)
            image = UIImage.init(cgImage: cgImage, scale: 1, orientation: image.imageOrientation)
            image = image.resize(to: CGSize(width: 800, height: 800))
        }

        return image
    }

    func resolution() -> CGSize {
        guard let videoTrack = self.tracks(withMediaType: .video).first else {
            return .zero
        }

        let orientation = self.videoOrientation
        if orientation == .left || orientation == .right || orientation == .leftMirrored || orientation == .rightMirrored {
            return CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
        }

        return videoTrack.naturalSize
    }

    var videoOrientation: UIImage.Orientation {
        guard let videoTrack = self.tracks(withMediaType: .video).first else {
            return .up
        }

        let transform = videoTrack.preferredTransform
        let videoAngleInDegree = radiansToDegrees(atan2(transform.b, transform.a))
        let scaleX = (transform.a/abs(transform.a)) * sqrt(pow(transform.a, 2) + pow(transform.c, 2))
        let scaleY = (transform.d/abs(transform.d)) * sqrt(pow(transform.b, 2) + pow(transform.d, 2))

        var orientation = UIImage.Orientation.up
        switch videoAngleInDegree {
            case 0:
                orientation = .up
            case 90:
                orientation = .right
            case 180:
                orientation = .down
            case -90:
                orientation = .left
            default:
                break
        }

        if scaleX == -1 {
        switch orientation {
            case .up:
                return .upMirrored
            case .down:
                return .downMirrored
            default:
                break
            }
        }

        return orientation
    }

    private func radiansToDegrees(_ value: CGFloat) -> CGFloat {
        return value * 180 / CGFloat.pi
    }

    func extractFrames(fps: Int64, completion: @escaping (Data?, Error?, Int, Bool, Double) -> Void) {
        let imageGenerator = AVAssetImageGenerator(asset: self)
        imageGenerator.apertureMode = .cleanAperture
        imageGenerator.appliesPreferredTrackTransform = true

        let track = self.tracks(withMediaType: .video).first
        let naturalSize = track?.naturalSize ?? CGSize.zero
        let scale = naturalSize.width/naturalSize.height

        let duration = CMTimeGetSeconds(self.duration)
        var count = 0
        let times = (0...Int64(duration)).map{CMTime(seconds: Double($0), preferredTimescale: 60)}.map{ NSValue(time: $0) }
        imageGenerator.generateCGImagesAsynchronously(forTimes: times) { _, cgImage, _, _, error in
            if let error = error {
                completion(nil, error, 0, false, 0)
                return
            }

            if let cgImage = cgImage {
                let imageData = UIImage(cgImage: cgImage).jpegData(compressionQuality: 0.0)
                completion(imageData, nil, count, count == times.count - 1, scale)
                count += 1
            }
        }
    }
}
