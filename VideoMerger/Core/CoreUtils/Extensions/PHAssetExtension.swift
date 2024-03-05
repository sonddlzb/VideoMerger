//
//  PHAssetExtension.swift
//
//  Created by Thanh Vu on 12/02/2021.
//  Copyright © 2020 thanhvu. All rights reserved.
//

import Foundation
import Photos
import UIKit
import MobileCoreServices
import RxSwift

public extension PHAsset {
    func thumbnail(size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true
        option.deliveryMode = .highQualityFormat
        option.isSynchronous = true

        var result: UIImage?
        PHImageManager.default().requestImage(for: self, targetSize: size, contentMode: .aspectFill, options: option) {(image, _) in
            result = image
        }

        return result
    }

    func originalFileName() -> String? {
        if let resource = PHAssetResource.assetResources(for: self).first {
            return resource.originalFilename
        }

        return nil
    }

    static func fromLocalIdentifier(_ id: String) -> PHAsset? {
        let options = PHFetchOptions()
        options.fetchLimit = 1
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: options)
        return result.firstObject
    }

    func isGifType() -> Bool {
        if let identifier = self.value(forKey: "uniformTypeIdentifier") as? String {
             if identifier == kUTTypeGIF as String {
               return true
             }
        }

        return false
    }

    func getAVAsset() -> AVAsset? {
        let semaphore = DispatchSemaphore(value: 0)
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.version = .current
        options.deliveryMode = .mediumQualityFormat

        var result: AVAsset?
        PHCachingImageManager().requestAVAsset(forVideo: self, options: options) { (avAsset, _, _) in
            result = avAsset
            semaphore.signal()
        }

        semaphore.wait()
        return result
    }

    func getImage() -> UIImage? {
        let semaphore = DispatchSemaphore(value: 0)
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true

        var result: UIImage?
        if #available(iOS 13, *) {
            PHCachingImageManager().requestImageDataAndOrientation(for: self, options: options) { (imageData, _, _, _) in
                if let data = imageData {
                    result = UIImage(data: data)
                }

                semaphore.signal()
            }
        } else {
            PHCachingImageManager().requestImageData(for: self, options: options) { (imageData, _, _, _) in
                if let data = imageData {
                    result = UIImage(data: data)
                }

                semaphore.signal()
            }
        }

        semaphore.wait()
        return result
    }

    func fetchImage() -> Observable<UIImage?> {
        return Observable<UIImage?>.create { observer in
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true

            if #available(iOS 13, *) {
                PHCachingImageManager().requestImageDataAndOrientation(for: self, options: options) { (imageData, _, _, _) in
                    if let data = imageData {
                        let image = UIImage(data: data)
                        observer.onNext(image)
                    } else {
                        observer.onNext(nil)
                    }

                    observer.onCompleted()
                }
            } else {
                PHCachingImageManager().requestImageData(for: self, options: options) { (imageData, _, _, _) in
                    if let data = imageData {
                        let image = UIImage(data: data)
                        observer.onNext(image)
                    } else {
                        observer.onNext(nil)
                    }

                    observer.onCompleted()
                }
            }

            return Disposables.create()
        }
    }

    func fetchAVAsset() -> Observable<AVAsset?> {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.version = .current
        options.deliveryMode = .highQualityFormat

        return Observable<AVAsset?>.create { observer in
            PHCachingImageManager().requestAVAsset(forVideo: self, options: options) { (avAsset, _, _) in
                observer.onNext(avAsset)
                observer.onCompleted()
            }

            return Disposables.create()
        }
    }

    // MARK: convert video duration
    func formatVideoDuration() -> String {
        var res: String
        let interval = Int(self.duration)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        res = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        if interval < 3600 {
            let index = res.index(res.endIndex, offsetBy: -5)
            res = String(res.suffix(from: index))
        }

        return res
    }

    func exportAudio(using disposeBag: DisposeBag, completion: @escaping (_ audioURL: URL?) -> Void) {
        self.fetchAVAsset()
            .subscribe(onNext: { avAsset in
                guard let avAsset = avAsset else {
                    completion(nil)
                    return
                }

                guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetAppleM4A) else {
                    completion(nil)
                    return
                }

                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let outputURL = documentsDirectory.appendingPathComponent(self.originalFileName() ?? "video_audio")
                try? FileManager.default.removeItem(at: outputURL)

                exportSession.outputURL = outputURL
                exportSession.outputFileType = .m4a
                exportSession.exportAsynchronously {
                    switch exportSession.status {
                    case .completed:
                        completion(outputURL)
                    case .failed:
                        print("Export failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
                        completion(nil)
                    case .cancelled:
                        print("Export cancelled")
                        completion(nil)
                    default:
                        break
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}
