//
//  VolumeView.swift
//  VideoMerger
//
//  Created by đào sơn on 16/01/2024.
//

import UIKit

class VolumeView: UIView {

    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lblVolumeMinValue: UILabel!
    @IBOutlet weak var lblVolumeMaxValue: UILabel!
    @IBOutlet weak var seekBar: SeekBarView!

    // MARK: - Variables
    var minVolume = 0
    var maxVolume = 300
    var currentVolume = 150

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadView()
    }

    func loadView() {
        let view = Bundle.main.loadNibNamed("VolumeView", owner: self, options: nil)?[0] as? UIView ?? UIView()
        view.fixInView(self)
        seekBar.filledColor = UIColor(rgb: 0x536DFE)
        seekBar.notFilledColor = UIColor(rgb: 0xE0E0E0)
        seekBar.delegate = self
        self.lblVolumeMinValue.text = String(minVolume)
        self.lblVolumeMaxValue.text = String(maxVolume)
    }
}

// MARK: - SeekBarViewDelegate
extension VolumeView: SeekBarViewDelegate {
    func seekBarViewDidBeganSeek(_ view: SeekBarView) {
    }

    func seekBarViewDidEndedSeek(_ view: SeekBarView) {
    }

    func seekBarView(_ view: SeekBarView, seekTimeProgress progress: Double) {
        self.currentVolume = Int(self.seekBar.frame.width*progress)
    }
}
