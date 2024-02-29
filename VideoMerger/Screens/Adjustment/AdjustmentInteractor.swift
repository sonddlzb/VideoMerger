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
    func adjustmentWantToDone(speedType: SpeedType)
}

final class AdjustmentInteractor: PresentableInteractor<AdjustmentPresentable>, AdjustmentInteractable {

    weak var router: AdjustmentRouting?
    weak var listener: AdjustmentListener?

    var viewModel = AdjustmentViewModel(adjustmentType: .volume, speedType: .speedC)

    init(presenter: AdjustmentPresentable, type: AdjustmentType, speedType: SpeedType) {
        self.viewModel = AdjustmentViewModel(adjustmentType: type, speedType: speedType)
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

extension AdjustmentInteractor: AdjustmentPresentableListener {
    func didTapCancel() {
        self.listener?.adjusmentWantToDismiss()
    }

    func didTapDone(speedType: SpeedType) {
        self.listener?.adjustmentWantToDone(speedType: speedType)
    }
}
