//
//  MediaPickerRouter.swift
//  VideoMerger
//
//  Created by đào sơn on 27/11/2023.
//

import RIBs
import Photos

protocol MediaPickerInteractable: Interactable {
    var router: MediaPickerRouting? { get set }
    var listener: MediaPickerListener? { get set }
}

protocol MediaPickerViewControllable: ViewControllable {
}

final class MediaPickerRouter: ViewableRouter<MediaPickerInteractable, MediaPickerViewControllable> {

    override init(interactor: MediaPickerInteractable,
                  viewController: MediaPickerViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}

// MARK: - MediaPickerRouting
extension MediaPickerRouter: MediaPickerRouting {
}
