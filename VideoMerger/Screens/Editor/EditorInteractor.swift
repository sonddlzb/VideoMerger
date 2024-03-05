//
//  EditorInteractor.swift
//  VideoMerger
//
//  Created by đào sơn on 04/01/2024.
//

import RIBs
import RxSwift
import Photos

protocol EditorRouting: ViewableRouting {
    func bind(listAddedAssets: [PHAsset])
    func showAdjustment(adjustmentType: AdjustmentType, value: Any)
    func dismissAdjustment()
    func showExport(avAsset: AVAsset)
    func dismissExport()
    func showAddAudio()
    func dismissAddAudio()
    func showExportResult(avAsset: AVAsset, config: ExportConfiguration)
    func dismissExportResult()
}

protocol EditorPresentable: Presentable {
    var listener: EditorPresentableListener? { get set }

    func bind(viewModel: EditorViewModel, isNeedToReload: Bool)
    func bind(viewModel: EditorViewModel, adjustmentType: AdjustmentType)
    func bind(currentTime: Double)
    func showExpandableView(isShow: Bool)
}

protocol EditorListener: AnyObject {
    func editorWantToDismiss()
    func editorWantToOpenMediaPicker(isSelectAudio: Bool)
    func editorWantToOpenPreview(avAsset: AVAsset)
    func editorWantToBackToHome()
}

final class EditorInteractor: PresentableInteractor<EditorPresentable> {

    weak var router: EditorRouting?
    weak var listener: EditorListener?
    var viewModel: EditorViewModel

    init(presenter: EditorPresentable, listAssets: [PHAsset]) {
        self.viewModel = EditorViewModel(listAssets: listAssets)
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        self.presenter.bind(viewModel: self.viewModel, isNeedToReload: true)
    }

    override func willResignActive() {
        super.willResignActive()
        self.viewModel.resetEditorFolder()
    }
}

// MARK: - EditorPresentableListener
extension EditorInteractor: EditorPresentableListener {
    func removeVideo(startTime: TimeInterval, endTime: TimeInterval) {
        let composition = AVMutableComposition()
        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
              let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            print("Error: Failed to create video or audio track.")
            return
        }

        var totalDuration: CMTime = .zero
        guard let viewModelAvAsset = self.viewModel.currentComposedAsset else {
            return
        }

        let start1 = CMTime(seconds: .zero, preferredTimescale: 1000)
        let end1 = CMTime(seconds: startTime, preferredTimescale: 1000)
        let start2 = CMTime(seconds: endTime, preferredTimescale: 1000)
        let end2 = CMTime(seconds: viewModelAvAsset.duration.seconds, preferredTimescale: 1000)
        let duration1 = CMTimeSubtract(end1, start1)
        let timeRange1 = CMTimeRange(start: start1, duration: duration1)
        let duration2 = CMTimeSubtract(end2, start2)
        let timeRange2 = CMTimeRange(start: start2, duration: duration2)
        do {
            try videoTrack.insertTimeRange(timeRange1, of: viewModelAvAsset.tracks(withMediaType: .video)[0], at: totalDuration)
            try audioTrack.insertTimeRange(timeRange1, of: viewModelAvAsset.tracks(withMediaType: .audio)[0], at: totalDuration)
            totalDuration = CMTimeAdd(totalDuration, duration1)
            try videoTrack.insertTimeRange(timeRange2, of: viewModelAvAsset.tracks(withMediaType: .video)[0], at: totalDuration)
            try audioTrack.insertTimeRange(timeRange2, of: viewModelAvAsset.tracks(withMediaType: .audio)[0], at: totalDuration)
        } catch {
            print("Error when remove video: \(error.localizedDescription)")
        }

        DispatchQueue.main.async {
            self.viewModel.currentComposedAsset = composition
            self.presenter.bind(viewModel: self.viewModel, adjustmentType: .remove)
        }
    }

    func changeVideoVolume(volume: Float) {
        DispatchQueue.main.async {
            self.viewModel.volume = volume
            self.presenter.bind(viewModel: self.viewModel, adjustmentType: .volume)
        }
    }

    func bind(viewModel: EditorViewModel) {
        self.viewModel = viewModel
    }

    func changeVideoSpeed(speedType: SpeedType, startTime: Double, endTime: Double) {
        let composition = AVMutableComposition()
        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
              let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            print("Error: Failed to create video or audio track.")
            return
        }

        let totalDuration: CMTime = .zero
        guard let viewModelAvAsset = self.viewModel.currentComposedAsset else {
            return
        }

        self.viewModel.speedType = speedType
        let oldSpeed = viewModel.oldSpeedType.rawValue
        let speed = viewModel.speedType.rawValue

        let start = CMTime(seconds: startTime, preferredTimescale: 1000)
        let end = CMTime(seconds: endTime, preferredTimescale: 1000)
        let duration = CMTimeSubtract(end, start)
        do {
            try videoTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: viewModelAvAsset.duration), of: viewModelAvAsset.tracks(withMediaType: .video)[0], at: totalDuration)
            try audioTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: viewModelAvAsset.duration), of: viewModelAvAsset.tracks(withMediaType: .audio)[0], at: totalDuration)
            if duration.seconds > 0 {
                let scaledTimeRange = CMTimeRange(start: start, duration: duration)
                let scaledDuration = CMTimeMultiplyByFloat64(duration, multiplier: 1.0 * oldSpeed / speed)
                videoTrack.scaleTimeRange(scaledTimeRange, toDuration: scaledDuration)
                audioTrack.scaleTimeRange(scaledTimeRange, toDuration: scaledDuration)
            }
        } catch {
            print("Error when trimming video: \(error.localizedDescription)")
        }

        DispatchQueue.main.async {
            self.viewModel.currentComposedAsset = composition
            self.presenter.bind(viewModel: self.viewModel, adjustmentType: .speed)
        }
    }

    func didTapExport() {
        if let avAsset = self.viewModel.currentComposedAsset {
            self.router?.showExport(avAsset: avAsset)
        }
    }

    func didTapBack() {
        self.listener?.editorWantToDismiss()
    }

    func updateCurrentVideoTime(currentTime: Double) {
        viewModel.currentTime = currentTime
        self.presenter.bind(currentTime: currentTime)
    }

    func composeAsset() {
        let composition = AVMutableComposition()
        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            return
        }

        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)

        var currentTime = CMTime.zero
        for index in 0..<self.viewModel.numberOfAsset() {
            let asset = self.viewModel.listAssets[index]
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true

            PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { aVAsset, _, _ in
                if let aVAsset = aVAsset as? AVURLAsset {
                    do {
                        try videoTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVAsset.duration), of: aVAsset.tracks(withMediaType: .video)[0], at: currentTime)
                        try audioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVAsset.duration),
                                                         of: aVAsset.tracks(withMediaType: .audio)[0],
                                                         at: currentTime)

                        currentTime = CMTimeAdd(currentTime, aVAsset.duration)
                        if asset == self.viewModel.listAssets.last {
                            self.viewModel.currentComposedAsset = composition
                            DispatchQueue.main.async {
                                self.presenter.bind(viewModel: self.viewModel, isNeedToReload: false)
                            }
                        }
                    } catch {
                        print("Error when composing asset \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    func trimVideo(startTime: TimeInterval, endTime: TimeInterval) {
        let composition = AVMutableComposition()
        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
              let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            print("Error: Failed to create video or audio track.")
            return
        }

        let totalDuration: CMTime = .zero
        guard let viewModelAvAsset = self.viewModel.currentComposedAsset else {
            return
        }

        let start = CMTime(seconds: startTime, preferredTimescale: 1000)
        let end = CMTime(seconds: endTime, preferredTimescale: 1000)
        let duration = CMTimeSubtract(end, start)
        let timeRange = CMTimeRange(start: start, duration: duration)
        do {
            try videoTrack.insertTimeRange(timeRange, of: viewModelAvAsset.tracks(withMediaType: .video)[0], at: totalDuration)
            try audioTrack.insertTimeRange(timeRange, of: viewModelAvAsset.tracks(withMediaType: .audio)[0], at: totalDuration)
        } catch {
            print("Error when trimming video: \(error.localizedDescription)")
        }

        DispatchQueue.main.async {
            self.viewModel.currentComposedAsset = composition
            self.presenter.bind(viewModel: self.viewModel, adjustmentType: .trim)
        }
    }

    func didTapAddMore() {
        self.listener?.editorWantToOpenMediaPicker(isSelectAudio: false)
    }
}

// MARK: - EditorInteractable
extension EditorInteractor: EditorInteractable {
    func bind(listAddedAssets: [PHAsset]) {
        self.viewModel.addMoreAssets(listAddedAssets)
        self.presenter.bind(viewModel: self.viewModel, isNeedToReload: true)
    }

    func didTapPreview() {
        if let avAsset = self.viewModel.currentComposedAsset {
            self.listener?.editorWantToOpenPreview(avAsset: avAsset)
        }
    }

    func didTapEdit(adjustmentType: AdjustmentType, value: Any) {
        self.router?.showAdjustment(adjustmentType: adjustmentType, value: value)
    }

    func didTapAddMusic() {
        self.router?.showAddAudio()
    }
}
