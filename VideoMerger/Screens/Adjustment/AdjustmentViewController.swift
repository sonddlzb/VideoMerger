//
//  AdjustmentViewController.swift
//  VideoMerger
//
//  Created by đào sơn on 15/01/2024.
//

import RIBs
import RxSwift
import UIKit

enum AdjustmentType {
    case filter
    case trim
    case volume
    case speed
    case remove
    func imageAsset() -> String {
        switch self {
        case .filter:
            return "ic_filter"
        case .trim:
            return "ic_trim"
        case .volume:
            return "ic_volume"
        case .speed:
            return "ic_speed"
        case .remove:
            return "ic_remove"
        }
    }

    func name() -> String {
        switch self {
        case .filter:
            return "Filter"
        case .trim:
            return "Trim"
        case .volume:
            return "Volume"
        case .speed:
            return "Speed"
        case .remove:
            return "Remove"
        }
    }
}

protocol AdjustmentPresentableListener: AnyObject {
    func didTapCancel()
    func didTapDone()
}

final class AdjustmentViewController: UIViewController, AdjustmentViewControllable {
    // MARK: - Outlets
    @IBOutlet weak var imgAll: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var contentView: UIView!
    private var speedView: SpeedView?
    private var volumeView: VolumeView?

    // MARK: - Variables
    weak var listener: AdjustmentPresentableListener?
    var isSelectedForAll = false {
        didSet {
            self.imgAll.image = UIImage(named: isSelectedForAll ? "ic_adjustment_selected" : "ic_adjustment_unselected")
        }
    }

    var viewModel = AdjustmentViewModel(adjustmentType: .volume)

    // MARK: - Lifecycle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.containerView.layer.shadowColor = UIColor.gray.cgColor
        self.containerView.layer.shadowOpacity = 0.25
        self.containerView.layer.shadowOffset = CGSize(width: 0, height: -4)
        self.containerView.layer.shadowRadius = 4
    }

    func loadContentView() {
        self.contentView.subviews.forEach {$0.removeFromSuperview()}
        switch self.viewModel.adjustmentType {
        case .speed:
            speedView = SpeedView()
            speedView!.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(speedView!)
            speedView!.fitSuperviewConstraint()
        case .volume:
            volumeView = VolumeView()
            volumeView!.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(volumeView!)
            volumeView!.fitSuperviewConstraint()
        case .filter:
            break
        case .trim:
            break
        case .remove:
            break
        }
    }

    // MARK: - Action
    @IBAction func didTapCancel(_ sender: Any) {
        self.listener?.didTapCancel()
    }

    @IBAction func didTapDone(_ sender: Any) {
    }

    @IBAction func didTapSelectForAll(_ sender: Any) {
        self.isSelectedForAll = !self.isSelectedForAll
    }
}

// MARK: - AdjustmentPresentable
extension AdjustmentViewController: AdjustmentPresentable {
    func bind(viewModel: AdjustmentViewModel) {
        self.loadViewIfNeeded()
        self.viewModel = viewModel
        self.loadContentView()
    }
}
