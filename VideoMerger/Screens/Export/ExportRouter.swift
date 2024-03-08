//
//  ExportRouter.swift
//  VideoMerger
//
//  Created by đào sơn on 23/01/2024.
//

import RIBs

protocol ExportInteractable: Interactable {
    var router: ExportRouting? { get set }
    var listener: ExportListener? { get set }
}

protocol ExportViewControllable: ViewControllable {
}

final class ExportRouter: ViewableRouter<ExportInteractable, ExportViewControllable>, ExportRouting {

    override init(interactor: ExportInteractable, viewController: ExportViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
