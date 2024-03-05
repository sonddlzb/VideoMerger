//
//  ExportResultViewController.swift
//  VideoMerger
//
//  Created by đào sơn on 05/03/2024.
//

import RIBs
import RxSwift
import UIKit

protocol ExportResultPresentableListener: AnyObject {
    func didTapBack()
    func didTapHome()
}

final class ExportResultViewController: UIViewController, ExportResultPresentable, ExportResultViewControllable {

    // MARK: - Outlets

    // MARK: - Variables
    weak var listener: ExportResultPresentableListener?

    // MARK: - Actions
    @IBAction func didTapBack(_ sender: Any) {
        self.listener?.didTapBack()
    }

    @IBAction func didTapHome(_ sender: Any) {
        self.listener?.didTapHome()
    }
}
