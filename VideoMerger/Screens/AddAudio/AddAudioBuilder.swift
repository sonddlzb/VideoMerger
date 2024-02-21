//
//  AddAudioBuilder.swift
//  VideoMerger
//
//  Created by đào sơn on 20/02/2024.
//

import RIBs

protocol AddAudioDependency: Dependency {

}

final class AddAudioComponent: Component<AddAudioDependency> {
}

// MARK: - Builder

protocol AddAudioBuildable: Buildable {
    func build(withListener listener: AddAudioListener) -> AddAudioRouting
}

final class AddAudioBuilder: Builder<AddAudioDependency>, AddAudioBuildable {

    override init(dependency: AddAudioDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: AddAudioListener) -> AddAudioRouting {
        let component = AddAudioComponent(dependency: dependency)
        let viewController = AddAudioViewController()
        let interactor = AddAudioInteractor(presenter: viewController)
        interactor.listener = listener
        return AddAudioRouter(interactor: interactor, viewController: viewController)
    }
}
