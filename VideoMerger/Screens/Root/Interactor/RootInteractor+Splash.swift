//
//  RootInteractor+Splash.swift
//  VideoMerger
//
//  Created by đào sơn on 24/11/2023.
//

import Foundation

extension RootInteractor: SplashListener {
    func routeToHome() {
        self.router?.routeToHome()
    }
}
