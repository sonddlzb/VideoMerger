//
//  AdjustmentRouter.swift
//  VideoMerger
//
//  Created by đào sơn on 15/01/2024.
//

import RIBs

protocol AdjustmentInteractable: Interactable {
    var router: AdjustmentRouting? { get set }
    var listener: AdjustmentListener? { get set }
}

protocol AdjustmentViewControllable: ViewControllable {
}

final class AdjustmentRouter: ViewableRouter<AdjustmentInteractable, AdjustmentViewControllable>, AdjustmentRouting {

    override init(interactor: AdjustmentInteractable, viewController: AdjustmentViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
