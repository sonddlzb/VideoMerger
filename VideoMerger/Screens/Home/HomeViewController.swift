//
//  HomeViewController.swift
//  VideoMerger
//
//  Created by đào sơn on 24/11/2023.
//

import RIBs
import RxSwift
import UIKit

private struct Const {
    static let contentInset = UIEdgeInsets(top: 20.0, left: 17.0, bottom: 0.0, right: 17.0)
    static let cellSpacing = 24.0
    static let cellHeight = 120.0
}

protocol HomePresentableListener: AnyObject {
    func didSelectCreateNewProject()
}

final class HomeViewController: UIViewController, HomeViewControllable {
    // MARK: - Outlets
    @IBOutlet weak var containerProject: UIView!
    @IBOutlet weak var containerCollectionView: UIView!
    @IBOutlet weak var imgStatus: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var cancelView: TapableView!
    @IBOutlet weak var lblSelect: UILabel!

    // MARK: - Variables
    weak var listener: HomePresentableListener?
    var isSelectedMode = false {
        didSet {
            self.cancelView.isHidden = !isSelectedMode
            self.lblSelect.text = isSelectedMode ? "Delete(s)" : "Select(s)"
            self.lblSelect.textColor = isSelectedMode ? UIColor(rgb: 0xFF0000) : UIColor(rgb: 0x979797)
            self.collectionView.reloadData()
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }

    private func config() {
        self.configCollectionView()
    }

    private func configCollectionView() {
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.contentInset = Const.contentInset
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.registerCell(type: ProjectCell.self)
    }

    // MARK: - Action
    @IBAction func didTapSelectMode(_ sender: Any) {
        if self.isSelectedMode {
            onDeleteProjects()
            self.isSelectedMode = false
        } else {
            self.isSelectedMode = true
        }
    }

    @IBAction func didTapSetting(_ sender: Any) {
    }

    @IBAction func didTapCreateNewProject(_ sender: Any) {
        self.listener?.didSelectCreateNewProject()
    }
    @IBAction func didTapCancel(_ sender: Any) {
        self.isSelectedMode = false
    }

    // MARK: - Helpers
    func onDeleteProjects() {
        // handle later
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCell(type: ProjectCell.self, indexPath: indexPath) else {
            return UICollectionViewCell()
        }

        cell.bind(isSelectedMode: self.isSelectedMode)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.containerCollectionView.frame.width - Const.contentInset.left - Const.contentInset.right
        let height = Const.cellHeight
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Const.cellSpacing
    }
}

// MARK: - HomePresentable
extension HomeViewController: HomePresentable {
    func showOpenSettingDialog() {
        ConfirmDialog.show(message: "Video Merger want to access your photo library", confirmTitle: "Open Setting", iconImage: UIImage(named: "ic_setting"))
    }
}
