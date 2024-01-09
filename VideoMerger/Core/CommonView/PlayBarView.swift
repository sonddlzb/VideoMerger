//
//  PlayBarView.swift
//  VideoMerger
//
//  Created by đào sơn on 24/11/2023.
//

protocol PlayBarViewDelegate: AnyObject {
    func playBarViewDidTapPlay(_ playBarView: PlayBarView, isPlaying: Bool)
    func playBarViewDidTapFullScreen(_ playBarView: PlayBarView)
    func playBarViewDidTapUndo(_ playBarView: PlayBarView)
    func playBarViewDidTapRedo(_ playBarView: PlayBarView)
}

import UIKit

class PlayBarView: UIView {
    // MARK: - Outlets
    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var imgPlay: UIImageView!

    // MARK: - Variables
    weak var delegate: PlayBarViewDelegate?
    var isPlaying = false {
        didSet {
            self.imgPlay.image = UIImage(named: isPlaying ? "ic_pause" : "ic_play")
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadView()
    }

    func loadView() {
        let playBar = Bundle.main.loadNibNamed("PlayBarView", owner: self, options: nil)?[0] as? UIView ?? UIView()
        playBar.fixInView(self)
    }

    // MARK: - Bind
    func bind(duration: String) {
        self.lblDuration.text = duration
    }

    func bind(currentTime: String) {
        self.lblCurrentTime.text = currentTime
    }

    // MARK: - Actions

    @IBAction func didTapPlay(_ sender: Any) {
        self.isPlaying = !self.isPlaying
        delegate?.playBarViewDidTapPlay(self, isPlaying: isPlaying)
    }

    @IBAction func didTapFullScreen(_ sender: Any) {
        delegate?.playBarViewDidTapFullScreen(self)
    }

    @IBAction func didTapUndo(_ sender: Any) {
        delegate?.playBarViewDidTapUndo(self)
    }

    @IBAction func didTapRedo(_ sender: Any) {
        delegate?.playBarViewDidTapRedo(self)
    }
}
