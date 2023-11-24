//
//  SplashViewController.swift
//  VideoMerger
//
//  Created by đào sơn on 24/11/2023.
//

import RIBs
import RxSwift
import UIKit

protocol SplashPresentableListener: AnyObject {
}

final class SplashViewController: UIViewController, SplashPresentable, SplashViewControllable {
    weak var listener: SplashPresentableListener?
}
