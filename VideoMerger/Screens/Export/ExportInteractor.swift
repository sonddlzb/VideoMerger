//
//  ExportInteractor.swift
//  VideoMerger
//
//  Created by đào sơn on 23/01/2024.
//

import RIBs
import RxSwift
import AVFoundation

protocol ExportRouting: ViewableRouting {
}

protocol ExportPresentable: Presentable {
    var listener: ExportPresentableListener? { get set }

    func bind(viewModel: ExportViewModel)
    func bind(estimatedSize: String)
}

protocol ExportListener: AnyObject {
    func exportWantToDismiss()
    func exportWantToShowExportResult(exportSession: AVAssetExportSession?)
}

final class ExportInteractor: PresentableInteractor<ExportPresentable>, ExportInteractable {

    weak var router: ExportRouting?
    weak var listener: ExportListener?

    private var viewModel: ExportViewModel

    init(presenter: ExportPresentable, avAsset: AVAsset, volume: Float) {
        self.viewModel = ExportViewModel(avAsset: avAsset, config: ExportConfiguration(resolution: .p1080, fps: .fps30, volume: volume))
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        self.presenter.bind(viewModel: self.viewModel)
    }

    override func willResignActive() {
        super.willResignActive()
    }

    func configExportSession(resolution: VideoResolution, fps: Int) -> AVAssetExportSession? {
        let exportAsset = self.viewModel.avAsset
        guard let exportSession = AVAssetExportSession(asset: exportAsset, presetName: AVAssetExportPresetHighestQuality) else {
            return nil
        }

        guard let videoTrack = exportAsset.tracks(withMediaType: .video).first,
              let audioTrack = exportAsset.tracks(withMediaType: .audio).first else {
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
        let audioMix = AVMutableAudioMix()
        let audioMixInputParams = AVMutableAudioMixInputParameters(track: audioTrack)
        audioMixInputParams.setVolume(self.viewModel.config.volume, at: .zero)
        audioMix.inputParameters = [audioMixInputParams]

        //exportSession.audioMix = audioMix
        exportSession.outputFileType = AVFileType.mp4
        exportSession.videoComposition = videoComposition
        return exportSession
    }

    func estimatedStorage(exportSession: AVAssetExportSession, completion: @escaping (String) -> Void) {
        exportSession.estimateOutputFileLength { size, _ in
            completion(size.formatStorage())
        }
    }
}

// MARK: - ExportPresentableListener
extension ExportInteractor: ExportPresentableListener {
    func didTapCancel() {
        self.listener?.exportWantToDismiss()
    }

    func didTapExport() {
        self.listener?.exportWantToShowExportResult(exportSession: self.viewModel.exportSession)
    }

    func estimatedStorage(videoResolution: VideoResolution?, fps: VideoFps?) {
        if let videoResolution = videoResolution {
            self.viewModel.config.resolution = videoResolution
        }

        if let fps = fps {
            self.viewModel.config.fps = fps
        }

        if let exportSession = configExportSession(resolution: self.viewModel.config.resolution, fps: Int(self.viewModel.config.fps.rawValue) ?? 30) {
            self.estimatedStorage(exportSession: exportSession) { estimatedSize in
                self.presenter.bind(estimatedSize: estimatedSize)
            }

            self.viewModel.exportSession = exportSession
            self.presenter.bind(viewModel: self.viewModel)
        }
    }
}
