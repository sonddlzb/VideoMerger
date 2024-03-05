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

    func bind(viewModel: AdjustmentViewModelType)
}

protocol AdjustmentListener: AnyObject {
    func adjusmentWantToDismiss()
    func adjustmentWantToDone(adjustmentViewModel: AdjustmentViewModelType)
}

final class AdjustmentInteractor: PresentableInteractor<AdjustmentPresentable>, AdjustmentInteractable {

    weak var router: AdjustmentRouting?
    weak var listener: AdjustmentListener?

    var adjustmentViewModelType: AdjustmentViewModelType?

    init(presenter: AdjustmentPresentable, adjustmentViewModelType: AdjustmentViewModelType) {
        super.init(presenter: presenter)
        self.adjustmentViewModelType = adjustmentViewModelType
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        if let viewModel = self.adjustmentViewModelType {
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

    func didTapDone(adjustmentViewModel: AdjustmentViewModelType) {
        self.listener?.adjustmentWantToDone(adjustmentViewModel: adjustmentViewModel)
    }
}
