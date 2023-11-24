//
//  SplashViewController.swift
//  VideoMerger
//
//  Created by đào sơn on 24/11/2023.
//

import RIBs
import RxSwift
import UIKit
import Lottie

protocol SplashPresentableListener: AnyObject {
    func openHome()
}

final class SplashViewController: UIViewController, SplashPresentable, SplashViewControllable {
    // MARK: - Outlets
    @IBOutlet weak var splashAnimationView: LottieAnimationView!

    // MARK: - Variables
    weak var listener: SplashPresentableListener?

    override func viewDidLoad() {
        super.viewDidLoad()
        splashAnimationView.contentMode = .scaleAspectFit
        splashAnimationView.animation = LottieAnimation.named("SplashAnimation")
        splashAnimationView.loopMode = .playOnce
        splashAnimationView.play { _ in
            DispatchQueue.main.async { [weak self] in
                self?.listener?.openHome()
            }
        }
    }
}
