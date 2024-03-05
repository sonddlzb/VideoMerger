//
//  ExportResultRouter.swift
//  VideoMerger
//
//  Created by đào sơn on 05/03/2024.
//

import RIBs

protocol ExportResultInteractable: Interactable {
    var router: ExportResultRouting? { get set }
    var listener: ExportResultListener? { get set }
}

protocol ExportResultViewControllable: ViewControllable {
}

final class ExportResultRouter: ViewableRouter<ExportResultInteractable, ExportResultViewControllable>, ExportResultRouting {
    
    override init(interactor: ExportResultInteractable, viewController: ExportResultViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
