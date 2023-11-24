//
//  PlayBarView.swift
//  VideoMerger
//
//  Created by đào sơn on 24/11/2023.
//

protocol PlayBarViewDelegate: AnyObject {
    func playBarViewDidTapBackward(_ playBarView: PlayBarView)
    func playBarViewDidTapPlay(_ playBarView: PlayBarView, isPlaying: Bool)
    func playBarViewDidTapForward(_ playBarView: PlayBarView)
    func playBarViewDidTapFullScreen(_ playBarView: PlayBarView)
    func playBarViewDidTapUndo(_ playBarView: PlayBarView)
    func playBarViewDidTapRedo(_ playBarView: PlayBarView)
}

import UIKit

class PlayBarView: UIView {
    // MARK: - Outlets
    @IBOutlet weak var imgPlay: UIImageView!

    // MARK: - Variables
    weak var delegate: PlayBarViewDelegate?
    var isPlaying = false {
        didSet {
            self.imgPlay.image = UIImage(named: isPlaying ? "ic_pause" : "ic_play")
        }
    }

    // MARK: - Actions
    static func loadView() -> PlayBarView {
        return PlayBarView.loadView(fromNib: "PlayBarView")!
    }

    @IBAction func didTapBackward(_ sender: Any) {
        delegate?.playBarViewDidTapBackward(self)
    }

    @IBAction func didTapPlay(_ sender: Any) {
        self.isPlaying = !self.isPlaying
        delegate?.playBarViewDidTapPlay(self, isPlaying: isPlaying)
    }

    @IBAction func didTapForward(_ sender: Any) {
        delegate?.playBarViewDidTapForward(self)
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
