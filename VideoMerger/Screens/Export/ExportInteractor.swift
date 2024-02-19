//
//  ExportInteractor.swift
//  VideoMerger
//
//  Created by đào sơn on 23/01/2024.
//

import RIBs
import RxSwift

protocol ExportRouting: ViewableRouting {
}

protocol ExportPresentable: Presentable {
    var listener: ExportPresentableListener? { get set }
}

protocol ExportListener: AnyObject {
    func exportWantToDismiss()
}

final class ExportInteractor: PresentableInteractor<ExportPresentable>, ExportInteractable {

    weak var router: ExportRouting?
    weak var listener: ExportListener?

    override init(presenter: ExportPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
    }

    override func willResignActive() {
        super.willResignActive()
    }
}

// MARK: - ExportPresentableListener
extension ExportInteractor: ExportPresentableListener {
    func didTapCancel() {
        self.listener?.exportWantToDismiss()
    }
}
