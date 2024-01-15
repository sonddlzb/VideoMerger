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
}

protocol EditorPresentable: Presentable {
    var listener: EditorPresentableListener? { get set }

    func bind(viewModel: EditorViewModel)
    func bind(currentTime: Double)
}

protocol EditorListener: AnyObject {
    func editorWantToDismiss()
}

final class EditorInteractor: PresentableInteractor<EditorPresentable>, EditorInteractable {

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
        self.presenter.bind(viewModel: self.viewModel)
    }

    override func willResignActive() {
        super.willResignActive()
    }
}

// MARK: - EditorPresentableListener
extension EditorInteractor: EditorPresentableListener {
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
                                self.presenter.bind(viewModel: self.viewModel)
                            }
                        }
                    } catch {
                        print("Error when composing asset \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
