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
    func bind(currentTime: String)
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
        self.presenter.bind(currentTime: String(Int(viewModel.currentTime)).formatVideoDuration())
    }
}
