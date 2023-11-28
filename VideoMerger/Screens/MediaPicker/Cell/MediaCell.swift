//
//  MediaCell.swift
//  VideoMerger
//
//  Created by đào sơn on 27/11/2023.
//

import UIKit

protocol MediaCellDelegate: AnyObject {
    func mediaCell(_ mediaCell: MediaCell, didSelect itemViewModel: MediaPickerItemViewModel, isSelected: Bool)
}

class MediaCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet weak var lblIndex: UILabel!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var imgThumbnail: UIImageView!

    // MARK: - Variables
    weak var delegate: MediaCellDelegate?
    var selectedIndex: Int? {
        didSet {
            if selectedIndex == nil {
                self.selectedView.borderColor = .white
                self.selectedView.borderWidth = 1.0
                self.lblIndex.text = ""
                self.lblIndex.backgroundColor = .clear
                self.blurView.isHidden = true
            } else {
                if let selectedIndex = selectedIndex {
                    self.lblIndex.text = String(selectedIndex+1)
                    self.lblIndex.backgroundColor = UIColor(named: "electric_blue")
                    self.selectedView.borderWidth = 0.0
                    self.blurView.isHidden = false
                }
            }
        }
    }

    var itemViewModel: MediaPickerItemViewModel?
    private let bottomGradient = CAGradientLayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addTopGradient()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imgThumbnail.image = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.bottomGradient.frame = gradientView.bounds
        self.lblDuration.layer.shadowColor = UIColor.gray.cgColor
        self.lblDuration.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.lblDuration.layer.shadowOpacity = 0.5
        self.lblDuration.layer.shadowRadius = 2.0
    }

    func bind(itemViewModel: MediaPickerItemViewModel) {
        self.itemViewModel = itemViewModel
        self.lblDuration.text = itemViewModel.duration()
        self.selectedIndex = itemViewModel.selectedIndex
        itemViewModel.fetchThumbnail(completion: { image in
             DispatchQueue.main.async {
                 self.imgThumbnail.image = image
             }
        })
    }

    func bindSelectedState(itemViewModel: MediaPickerItemViewModel) {
        self.itemViewModel = itemViewModel
        self.selectedIndex = itemViewModel.selectedIndex
    }

    func addTopGradient() {
        bottomGradient.frame = gradientView.bounds
        bottomGradient.colors = [UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.clear.cgColor]
        bottomGradient.locations = [0, 1.0]
        gradientView.layer.insertSublayer(bottomGradient, at: 0)
    }

    @IBAction func didTapSelect(_ sender: Any) {
        if let itemViewModel = self.itemViewModel {
            self.delegate?.mediaCell(self, didSelect: itemViewModel, isSelected: self.selectedIndex != nil)
        }
    }
}
