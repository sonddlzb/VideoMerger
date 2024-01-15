//
//  EditorRouter.swift
//  VideoMerger
//
//  Created by đào sơn on 04/01/2024.
//

import RIBs
import Photos

protocol EditorInteractable: Interactable {
    var router: EditorRouting? { get set }
    var listener: EditorListener? { get set }

    func bind(listAddedAssets: [PHAsset])
}

protocol EditorViewControllable: ViewControllable {
}

final class EditorRouter: ViewableRouter<EditorInteractable, EditorViewControllable> {
    
    override init(interactor: EditorInteractable, viewController: EditorViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}

// MARK: - EditorRouting
extension EditorRouter: EditorRouting {
    func bind(listAddedAssets: [PHAsset]) {
        self.interactor.bind(listAddedAssets: listAddedAssets)
    }
}

