//
//  MediaPickerBuilder.swift
//  VideoMerger
//
//  Created by đào sơn on 27/11/2023.
//

import RIBs

protocol MediaPickerDependency: Dependency {

}

final class MediaPickerComponent: Component<MediaPickerDependency> {
}

// MARK: - Builder

protocol MediaPickerBuildable: Buildable {
    func build(withListener listener: MediaPickerListener, isAddMore: Bool, isSelectAudio: Bool) -> MediaPickerRouting
}

final class MediaPickerBuilder: Builder<MediaPickerDependency>, MediaPickerBuildable {

    override init(dependency: MediaPickerDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: MediaPickerListener, isAddMore: Bool, isSelectAudio: Bool) -> MediaPickerRouting {
        let component = MediaPickerComponent(dependency: dependency)
        let viewController = MediaPickerViewController()
        let interactor = MediaPickerInteractor(presenter: viewController, isAddMore: isAddMore, isSelectAudio: isSelectAudio)
        interactor.listener = listener
        return MediaPickerRouter(interactor: interactor,
                                 viewController: viewController)
    }
}
