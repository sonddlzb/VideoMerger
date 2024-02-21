//
//  AddAudioRouter.swift
//  VideoMerger
//
//  Created by đào sơn on 20/02/2024.
//

import RIBs

protocol AddAudioInteractable: Interactable {
    var router: AddAudioRouting? { get set }
    var listener: AddAudioListener? { get set }
}

protocol AddAudioViewControllable: ViewControllable {
}

final class AddAudioRouter: ViewableRouter<AddAudioInteractable, AddAudioViewControllable>, AddAudioRouting {
    
    override init(interactor: AddAudioInteractable, viewController: AddAudioViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
