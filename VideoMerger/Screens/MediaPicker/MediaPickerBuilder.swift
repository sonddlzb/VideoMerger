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
    func build(withListener listener: MediaPickerListener) -> MediaPickerRouting
}

final class MediaPickerBuilder: Builder<MediaPickerDependency>, MediaPickerBuildable {

    override init(dependency: MediaPickerDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: MediaPickerListener) -> MediaPickerRouting {
        let component = MediaPickerComponent(dependency: dependency)
        let viewController = MediaPickerViewController()
        let interactor = MediaPickerInteractor(presenter: viewController)
        interactor.listener = listener
        let previewImageBuilder = DIContainer.resolve(PreviewImageBuildable.self, agrument: component)
        return MediaPickerRouter(interactor: interactor,
                                 viewController: viewController,
                                 previewImageBuilder: previewImageBuilder)
    }
}
