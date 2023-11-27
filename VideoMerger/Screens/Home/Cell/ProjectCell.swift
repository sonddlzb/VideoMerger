//
//  ProjectCell.swift
//  VideoMerger
//
//  Created by đào sơn on 26/11/2023.
//

import UIKit

protocol ProjectCellDelegate: AnyObject {
    func projectCell(_ projectCell: ProjectCell, didSelectAt index: Int, isSelect: Bool)
}

class ProjectCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet weak var containerSelect: TapableView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var lblCreated: UILabel!
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var imgSelected: UIImageView!

    // MARK: - Variables
    weak var delegate: ProjectCellDelegate?
    var isProjectSelected = false {
        didSet {
            if isSelectedMode {
                self.imgSelected.image = UIImage(named: "ic_project_" + (isProjectSelected ? "selected" : "not_selected"))
            }
        }
    }

    var isSelectedMode = false {
        didSet {
            self.containerSelect.isHidden = !isSelectedMode
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func bind(isSelectedMode: Bool) {
        self.isSelectedMode = isSelectedMode
    }

    // MARK: - Actions
    @IBAction func didTapSelect(_ sender: Any) {
        self.isProjectSelected = !self.isProjectSelected
    }
}
