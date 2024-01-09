//
//  EditorRouter.swift
//  VideoMerger
//
//  Created by đào sơn on 04/01/2024.
//

import RIBs

protocol EditorInteractable: Interactable {
    var router: EditorRouting? { get set }
    var listener: EditorListener? { get set }
}

protocol EditorViewControllable: ViewControllable {
}

final class EditorRouter: ViewableRouter<EditorInteractable, EditorViewControllable>, EditorRouting {
    
    override init(interactor: EditorInteractable, viewController: EditorViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
