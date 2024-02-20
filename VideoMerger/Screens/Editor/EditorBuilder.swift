//
//  EditorBuilder.swift
//  VideoMerger
//
//  Created by đào sơn on 04/01/2024.
//

import RIBs
import Photos

protocol EditorDependency: Dependency {

}

final class EditorComponent: Component<EditorDependency> {
}

// MARK: - Builder

protocol EditorBuildable: Buildable {
    func build(withListener listener: EditorListener, listAssets: [PHAsset]) -> EditorRouting
}

final class EditorBuilder: Builder<EditorDependency>, EditorBuildable {

    override init(dependency: EditorDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: EditorListener, listAssets: [PHAsset]) -> EditorRouting {
        let component = EditorComponent(dependency: dependency)
        let viewController = EditorViewController()
        let interactor = EditorInteractor(presenter: viewController, listAssets: listAssets)
        interactor.listener = listener
        let adjustmentBuilder = DIContainer.resolve(AdjustmentBuildable.self, agrument: component)
        let exportBuilder = DIContainer.resolve(ExportBuildable.self, agrument: component)
        let addAudioBuilder = DIContainer.resolve(AddAudioBuildable.self, agrument: component)
        return EditorRouter(interactor: interactor,
                            viewController: viewController,
                            adjustmentBuilder: adjustmentBuilder,
                            exportBuilder: exportBuilder,
                            addAudioBuilder: addAudioBuilder)
    }
}
