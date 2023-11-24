//
//  AppDelegate.swift
//  VideoMerger
//
//  Created by đào sơn on 24/11/2023.
//

import UIKit
import SVProgressHUD

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow!
    var rootRouter: RootRouting?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        DIConnector.registerAllDeps()
        self.configLoading()
        self.configAppearance()
        self.configWindow()
        return true
    }

    private func configLoading() {
        SVProgressHUD.setDefaultMaskType(.black)
    }

    private func configAppearance() {
        UIView.appearance().isExclusiveTouch = true
        UIView.appearance().isMultipleTouchEnabled = false

        if #available(iOS 13.0, *) {
             UIView.appearance().overrideUserInterfaceStyle = .light
         }
    }

    private func configWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        let component = AppComponent(window: window)
        let rootBuilder = DIContainer.resolve(RootBuildable.self, agrument: component)
        rootRouter = rootBuilder.build()
        rootRouter?.interactable.activate()
    }
}
