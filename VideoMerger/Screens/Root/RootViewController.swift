//
//  RootViewController.swift
//  VideoMerger
//
//  Created by đào sơn on 24/11/2023.
//

import RIBs
import RxSwift
import UIKit

protocol RootPresentableListener: AnyObject {
}

final class RootViewController: UIViewController, RootPresentable, RootViewControllable {
    weak var listener: RootPresentableListener?
}
