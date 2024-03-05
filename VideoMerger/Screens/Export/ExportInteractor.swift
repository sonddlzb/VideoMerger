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
}

protocol ExportListener: AnyObject {
    func exportWantToDismiss()
    func exportWantToShowExportResult(config: ExportConfiguration)
}

final class ExportInteractor: PresentableInteractor<ExportPresentable>, ExportInteractable {

    weak var router: ExportRouting?
    weak var listener: ExportListener?

    private var viewModel: ExportViewModel

    init(presenter: ExportPresentable, avAsset: AVAsset) {
        self.viewModel = ExportViewModel(config: ExportConfiguration(resolution: .p1080, fps: .fps30))
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

// MARK: - ExportPresentableListener
extension ExportInteractor: ExportPresentableListener {
    func didTapCancel() {
        self.listener?.exportWantToDismiss()
    }

    func didTapExport() {
        self.listener?.exportWantToShowExportResult(config: self.viewModel.config)
    }
}
