//
//  AdjustmentInteractor.swift
//  VideoMerger
//
//  Created by đào sơn on 15/01/2024.
//

import RIBs
import RxSwift

protocol AdjustmentRouting: ViewableRouting {
}

protocol AdjustmentPresentable: Presentable {
    var listener: AdjustmentPresentableListener? { get set }

    func bind(viewModel: AdjustmentViewModel)
}

protocol AdjustmentListener: AnyObject {
    func adjusmentWantToDismiss()
    func adjustmentWantToDone(adjustmentViewModel: AdjustmentViewModel)
}

final class AdjustmentInteractor: PresentableInteractor<AdjustmentPresentable>, AdjustmentInteractable {

    weak var router: AdjustmentRouting?
    weak var listener: AdjustmentListener?

    var adjustmentViewModel: AdjustmentViewModel?

    init(presenter: AdjustmentPresentable, adjustmentViewModel: AdjustmentViewModel) {
        super.init(presenter: presenter)
        self.adjustmentViewModel = adjustmentViewModel
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        if let viewModel = self.adjustmentViewModel {
            self.presenter.bind(viewModel: viewModel)
        }
    }

    override func willResignActive() {
        super.willResignActive()
    }
}

extension AdjustmentInteractor: AdjustmentPresentableListener {
    func didTapCancel() {
        self.listener?.adjusmentWantToDismiss()
    }

    func didTapDone(adjustmentViewModel: AdjustmentViewModel) {
        self.listener?.adjustmentWantToDone(adjustmentViewModel: adjustmentViewModel)
    }
}
