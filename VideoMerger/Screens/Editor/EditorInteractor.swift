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
    func showAdjustment(type: AdjustmentType)
    func dismissAdjustment()
    func showExport()
    func dismissExport()
    func showAddAudio()
    func dismissAddAudio()
}

protocol EditorPresentable: Presentable {
    var listener: EditorPresentableListener? { get set }

    func bind(viewModel: EditorViewModel, isNeedToReload: Bool)
    func bind(viewModel: EditorViewModel, isCutFromStart: Bool, isCutFromEnd: Bool)
    func bind(currentTime: Double)
}

protocol EditorListener: AnyObject {
    func editorWantToDismiss()
    func editorWantToOpenMediaPicker()
    func editorWantToOpenPreview(avAsset: AVAsset)
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
    }
}

// MARK: - EditorPresentableListener
extension EditorInteractor: EditorPresentableListener {
    func didTapExport() {
        self.router?.showExport()
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
        for asset in self.viewModel.listAssets {
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

        var totalDuration: CMTime = .zero
        var totalSeconds = 0.0
        var isCutEndTime = false

        for index in 0..<self.viewModel.numberOfAsset() {
            let asset = self.viewModel.listAssets[index]
            let assetDuration = self.viewModel.listCurrenAssetDuration[index]
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true

            var start = CMTime(seconds: 0, preferredTimescale: 1000)
            if startTime > totalSeconds {
                start = CMTime(seconds: startTime - totalSeconds, preferredTimescale: 1000)
            }

            var end = CMTime(seconds: startTime, preferredTimescale: 1000)
            totalSeconds += assetDuration
            if endTime > totalSeconds {
                if !isCutEndTime {
                    end = CMTime(seconds: assetDuration, preferredTimescale: 1000)
                }
            } else {
                totalSeconds -= assetDuration
                if !isCutEndTime {
                    end = CMTime(seconds: endTime - totalSeconds, preferredTimescale: 1000)
                    isCutEndTime = true
                }
            }

            let duration = CMTimeSubtract(end, start)
            self.viewModel.listCurrenAssetDuration[index] = duration.seconds
            let timeRange = CMTimeRange(start: start, duration: duration)
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
                guard let avAsset = avAsset as? AVURLAsset else { return }
                if duration.seconds > 0 {
                    do {
                        try videoTrack.insertTimeRange(timeRange, of: avAsset.tracks(withMediaType: .video)[0], at: totalDuration)
                        try audioTrack.insertTimeRange(timeRange, of: avAsset.tracks(withMediaType: .audio)[0], at: totalDuration)
                    } catch {
                        print("Error when trimming video: \(error.localizedDescription)")
                    }

                    totalDuration = CMTimeAdd(totalDuration, duration)
                }

                if asset == self.viewModel.listAssets.last {
                    DispatchQueue.main.async {
                        let isCutFromStart = startTime > 0.1
                        let isCutFromEnd = endTime < (self.viewModel.currentComposedAsset?.duration.toDouble() ?? 0.0)
                        self.viewModel.currentComposedAsset = composition
                        self.presenter.bind(viewModel: self.viewModel, isCutFromStart: isCutFromStart, isCutFromEnd: isCutFromEnd)
                    }
                }
            }
        }
    }

    func didTapAddMore() {
        self.listener?.editorWantToOpenMediaPicker()
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

    func didTapEdit(type: AdjustmentType) {
        self.router?.showAdjustment(type: type)
    }

    func didTapAddMusic() {
        self.router?.showAddAudio()
    }
}
