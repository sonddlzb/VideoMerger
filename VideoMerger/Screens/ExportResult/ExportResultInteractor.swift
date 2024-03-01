//
//  ExportResultInteractor.swift
//  VideoMerger
//
//  Created by đào sơn on 05/03/2024.
//

import RIBs
import RxSwift
import AVFoundation

protocol ExportResultRouting: ViewableRouting {
}

protocol ExportResultPresentable: Presentable {
    var listener: ExportResultPresentableListener? { get set }
}

protocol ExportResultListener: AnyObject {
    func exportResultWantToDismiss()
    func exportResultWantToBackToHome()
}

final class ExportResultInteractor: PresentableInteractor<ExportResultPresentable>, ExportResultInteractable {

    weak var router: ExportResultRouting?
    weak var listener: ExportResultListener?
    var viewModel: ExportResultViewModel

    init(presenter: ExportResultPresentable, avAsset: AVAsset, config: ExportConfiguration) {
        self.viewModel = ExportResultViewModel(avAsset: avAsset, config: config)
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
    }

    override func willResignActive() {
        super.willResignActive()
    }

    func configExportSession(resolution: VideoResolution, fps: Int) -> AVAssetExportSession? {
        let exportAsset = self.viewModel.avAsset
        guard let exportSession = AVAssetExportSession(asset: exportAsset, presetName: AVAssetExportPresetHighestQuality) else {
            return nil
        }

        guard let videoTrack = exportAsset.tracks(withMediaType: .video).first else {
            return nil
        }

        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = resolution.size
        videoComposition.frameDuration = CMTime(value: 1, timescale: Int32(fps))

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: exportAsset.duration)
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]

        exportSession.outputFileType = AVFileType.mp4
        exportSession.videoComposition = videoComposition
        return exportSession
    }

    func exportAsset(resolution: VideoResolution, fps: Int, name: String, completion: @escaping (_ outputURL: URL?) -> Void) -> Observable<Float>? {
        guard let exportSession = self.configExportSession(resolution: resolution, fps: fps) else {
            completion(nil)
            return nil
        }

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("exported")
        try? documentsDirectory.createDirectoryIfNeeded()

        let outputURL = documentsDirectory.appendingPathComponent("\(name).mp4")
        try? FileManager.default.removeItem(at: outputURL)

        exportSession.outputURL = outputURL

        return Observable<Float>.create { observer in
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                let progress = exportSession.progress
                observer.onNext(progress)
                if progress == 1 {
                    observer.onCompleted()
                }

                print("current progress is \(progress)")
            }

            exportSession.exportAsynchronously(completionHandler: {
                switch exportSession.status {
                case .completed:
                    print("Export completed. Video file saved at \(outputURL) with file size \(self.getFileSize(atURL: outputURL)!.formatStorage()))")
                case .failed:
                    print("Export failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
                case .cancelled:
                    print("Export cancelled")
                default:
                    break
                }
            })

            return Disposables.create()
        }
    }

    func estimatedStorage(exportSession: AVAssetExportSession, completion: @escaping (String) -> Void) {
        exportSession.estimateOutputFileLength { size, _ in
            completion(size.formatStorage())
        }
    }

    func getFileSize(atURL fileURL: URL) -> Int64? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let fileSize = attributes[.size] as? Int64 {
                return fileSize
            } else {
                print("Failed to retrieve file size.")
                return nil
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - ExportResultPresentableListener
extension ExportResultInteractor: ExportResultPresentableListener {
    func didTapBack() {
        self.listener?.exportResultWantToDismiss()
    }

    func didTapHome() {
        self.listener?.exportResultWantToBackToHome()
    }
}
