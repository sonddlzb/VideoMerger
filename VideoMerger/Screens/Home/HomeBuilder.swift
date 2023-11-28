//
//  HomeBuilder.swift
//  VideoMerger
//
//  Created by đào sơn on 24/11/2023.
//

import RIBs

protocol HomeDependency: Dependency {

}

final class HomeComponent: Component<HomeDependency> {
}

// MARK: - Builder

protocol HomeBuildable: Buildable {
    func build(withListener listener: HomeListener) -> HomeRouting
}

final class HomeBuilder: Builder<HomeDependency>, HomeBuildable {

    override init(dependency: HomeDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: HomeListener) -> HomeRouting {
        let component = HomeComponent(dependency: dependency)
        let viewController = HomeViewController()
        let interactor = HomeInteractor(presenter: viewController)
        interactor.listener = listener
        let mediaPickerBuilder = DIContainer.resolve(MediaPickerBuildable.self, agrument: component)
        return HomeRouter(interactor: interactor,
                          viewController: viewController,
                          mediaPickerBuilder: mediaPickerBuilder)
    }
}
