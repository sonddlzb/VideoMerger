//
//  PreviewImageBuilder.swift
//  Zip
//
//  Created by đào sơn on 03/09/2022.
//

import RIBs
import Photos

protocol PreviewImageDependency: Dependency {

}

final class PreviewImageComponent: Component<PreviewImageDependency> {
}

// MARK: - Builder

protocol PreviewImageBuildable: Buildable {
    func build(withListener listener: PreviewImageListener, asset: PHAsset) -> PreviewImageRouting
}

final class PreviewImageBuilder: Builder<PreviewImageDependency>, PreviewImageBuildable {

    override init(dependency: PreviewImageDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: PreviewImageListener, asset: PHAsset) -> PreviewImageRouting {
        let viewController = PreviewImageViewController()
        viewController.modalTransitionStyle = .coverVertical
        viewController.modalPresentationStyle = .fullScreen
        let interactor = PreviewImageInteractor(presenter: viewController, asset: asset)
        interactor.listener = listener
        return PreviewImageRouter(interactor: interactor, viewController: viewController)
    }
}
