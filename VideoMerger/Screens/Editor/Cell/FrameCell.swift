//
//  FrameCell.swift
//  VideoMerger
//
//  Created by Hưng Hà Quang on 01/03/2024.
//

import UIKit

class FrameCell: UICollectionViewCell {
    @IBOutlet private weak var imageFrame: UIImageView!
    @IBOutlet private weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        self.imageFrame.image = nil
        self.timeLabel.text = ""
    }

    func bind(itemFrame: ItemFrameViewModel) {
        self.imageFrame.image = itemFrame.getImage()
        self.timeLabel.text = itemFrame.time
    }
}
