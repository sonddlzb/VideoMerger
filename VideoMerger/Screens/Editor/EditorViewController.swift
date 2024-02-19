//
//  EditorViewController.swift
//  VideoMerger
//
//  Created by đào sơn on 04/01/2024.
//

import RIBs
import RxSwift
import UIKit
import Photos

protocol EditorPresentableListener: AnyObject {
    func didTapBack()
    func updateCurrentVideoTime(currentTime: Double)
    func composeAsset()
    func didTapAddMore()
    func didTapPreview()
    func didTapEdit()
    func didTapExport()
}

final class EditorViewController: UIViewController, EditorViewControllable {
    // MARK: - Outlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var playView: PlayerView!
    @IBOutlet weak var playBarView: PlayBarView!
    @IBOutlet weak var frameScrollView: UIScrollView!
    @IBOutlet weak var timeStackView: UIStackView!
    @IBOutlet weak var timeScrollView: UIScrollView!
    @IBOutlet weak var frameStackView: UIStackView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var imgMute: UIImageView!
    @IBOutlet weak var imgSoundMute: UIImageView!
    @IBOutlet weak var imgTextHide: UIImageView!
    @IBOutlet weak var imgFilterHide: UIImageView!
    @IBOutlet weak var editMainTabBarView: EditMainTabBarView!
    @IBOutlet weak var expandableFrameView: ExpandableView!

    // MARK: - Variables
    weak var listener: EditorPresentableListener?
    var viewModel = EditorViewModel.makeEmpty()
    private var timeObserverToken: Any?
    var isPlayingBefore = false
    var isPlayingAtTheEnd = false
    var isRootSoundMuted = false {
        didSet {
            self.playView.isMuted = isRootSoundMuted
            self.imgMute.image = UIImage(named: isRootSoundMuted ? "ic_mute_disable" : "ic_mute_enable")
        }
    }

    var isSoundMuted = false {
        didSet {
            self.imgSoundMute.image = UIImage(named: isSoundMuted ? "ic_mute_disable" : "ic_mute_enable")
        }
    }

    var isTextHidden = false {
        didSet {
            self.imgTextHide.image = UIImage(named: isTextHidden ? "ic_eye_invisible" : "ic_eye_visible")
        }
    }

    var isFilterHidden = false {
        didSet {
            self.imgFilterHide.image = UIImage(named: isFilterHidden ? "ic_eye_invisible" : "ic_eye_visible")
        }
    }

    var scale = -1.0
    let dispatchGroup = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }

    deinit {
        self.removePeriodicTimeObserver()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.headerView.layer.shadowOpacity = 0.1
        self.headerView.layer.shadowOffset = CGSize(width: -4, height: 4)
        self.headerView.layer.shadowRadius = 4
        self.headerView.layer.masksToBounds = false

        self.addGradientLayer()
        setConstraintExpandableView()
    }

    private func setConstraintExpandableView() {
        let expandableEdgeWidth = self.expandableFrameView.contentView.leftEdgeView.frame.width
        self.expandableFrameView.setTrailingConstrant(trailing: Double((self.frameStackView.arrangedSubviews.last?.frame.width) ?? 0.0) - expandableEdgeWidth)
        self.expandableFrameView.setLeadingConstrant(leading: -Double((self.frameStackView.arrangedSubviews.first?.frame.width) ?? 0.0) + expandableEdgeWidth)
    }

    private func config() {
        expandableFrameView.delegate = self
        playBarView.delegate = self
        frameScrollView.delegate = self
        frameScrollView.showsHorizontalScrollIndicator = false
        editMainTabBarView.delegate = self
    }

    func loadAssets(index: Int) {
        let phAsset = self.viewModel.asset(at: index)
        if phAsset.mediaType == .video {
            dispatchGroup.enter()
            self.viewModel.fetchAVAsset(asset: phAsset, completion: { [weak self] avAsset in
                guard let self = self else {
                    return
                }

                if let asset = avAsset {
                    DispatchQueue.main.async {
                        self.addLeftFramesPadding(isFirstFrame: index == 0)
                        asset.extractFrames(fps: 1) { image, error, second, isFinish, scale in
                            guard error == nil else {
                                print("Error when extracting frames: \(error!.localizedDescription)")
                                return
                            }

                            DispatchQueue.main.async {
                                self.insertFrames(image: image, second: second, isFinish: isFinish, scale: scale, index: index)
                            }
                        }
                    }
                }
            })
        } else if phAsset.mediaType == .image {
            DispatchQueue.main.async {
                self.addLeftFramesPadding(isFirstFrame: index == 0)
                self.insertFrame(phAsset.getImage(), index: index)
            }
        }

        addPeriodicTimeObserverForVideo()
        self.playView.setLayerVideoGravity(.resizeAspect)
        self.playView.loopEnable = false
        self.playView.delegate = self

        if self.playBarView.isPlaying {
            self.playView.play()
        } else {
            self.playView.pause()
        }
    }

    func insertFrames(image: UIImage?, second: Int, isFinish: Bool, scale: Double, index: Int) {
        if let image = image {
            if self.scale < 0 {
                self.scale = scale
            }

            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = image
            self.frameStackView.addArrangedSubview(imageView)
            imageView.widthAnchor.constraint(equalToConstant: self.frameScrollView.frame.height*self.scale).isActive = true

            let timeLabel = UILabel()
            timeLabel.textAlignment = .left
            timeLabel.textColor = UIColor(rgb: 0x9E9E9E)
            timeLabel.font = .systemFont(ofSize: 10, weight: .regular)
            timeLabel.text = String(self.viewModel.secondAt(second, index: index)).formatVideoDuration()
            timeLabel.translatesAutoresizingMaskIntoConstraints = false
            self.timeStackView.addArrangedSubview(timeLabel)
            timeLabel.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1).isActive = true

            if isFinish {
                dispatchGroup.leave()
                dispatchGroup.notify(queue: .main) {
                    if index < self.viewModel.numberOfAsset() - 1 {
                        self.loadAssets(index: index+1)
                    } else {
                        self.listener?.composeAsset()
                    }

                    if index == self.viewModel.numberOfAsset()-1 {
                        self.addRightFramesPadding()
                    }
                }
            }
        }
    }

    func insertFrame(_ image: UIImage?, index: Int) {
        // MARK: - handle for image later
    }

    func addLeftFramesPadding(isFirstFrame: Bool) {
        if isFirstFrame {
            self.frameStackView.arrangedSubviews.forEach {$0.removeFromSuperview()}
            self.timeStackView.arrangedSubviews.forEach {$0.removeFromSuperview()}

            let leftPaddingView = UIView()
            leftPaddingView.translatesAutoresizingMaskIntoConstraints = false
            self.frameStackView.addArrangedSubview(leftPaddingView)
            leftPaddingView.widthAnchor.constraint(equalTo: self.frameScrollView.widthAnchor, multiplier: 0.5).isActive = true
            let leftTimePaddingView = UIView()
            leftTimePaddingView.translatesAutoresizingMaskIntoConstraints = false
            self.timeStackView.addArrangedSubview(leftTimePaddingView)
            leftTimePaddingView.widthAnchor.constraint(equalTo: self.frameScrollView.widthAnchor, multiplier: 0.5).isActive = true
        } else {
            let leftPaddingView = UIView()
            leftPaddingView.translatesAutoresizingMaskIntoConstraints = false
            self.frameStackView.addArrangedSubview(leftPaddingView)
            leftPaddingView.widthAnchor.constraint(equalToConstant: 2.17).isActive = true
            let leftTimePaddingView = UIView()
            leftTimePaddingView.translatesAutoresizingMaskIntoConstraints = false
            self.timeStackView.addArrangedSubview(leftTimePaddingView)
            leftTimePaddingView.widthAnchor.constraint(equalToConstant: 2.17).isActive = true
        }
    }

    func addRightFramesPadding() {
        let rightPaddingView = UIView()
        rightPaddingView.translatesAutoresizingMaskIntoConstraints = false
        self.frameStackView.addArrangedSubview(rightPaddingView)
        rightPaddingView.widthAnchor.constraint(equalTo: self.frameScrollView.widthAnchor, multiplier: 0.5).isActive = true
        let rightTimePaddingView = UIView()
        rightTimePaddingView.translatesAutoresizingMaskIntoConstraints = false
        self.timeStackView.addArrangedSubview(rightTimePaddingView)
        rightTimePaddingView.widthAnchor.constraint(equalTo: self.timeStackView.widthAnchor, multiplier: 0.5).isActive = true
    }

    func addPeriodicTimeObserverForVideo() {
        removePeriodicTimeObserver()
        let time = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        self.timeObserverToken = self.playView.addTimeObserver(forInterval: time, queue: .main, using: {[weak self] time in
            self?.listener?.updateCurrentVideoTime(currentTime: time.seconds)
        })
    }

    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            self.playView.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }

    private func addGradientLayer() {
        self.gradientView.layer.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }

        self.view.layoutIfNeeded()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.gradientView.bounds
        let startColor = UIColor(rgb: 0xF2F2F2)
        let endColor = UIColor.white.withAlphaComponent(0)
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        self.gradientView.layer.addSublayer(gradientLayer)
    }
    // MARK: - Actions
    @IBAction func didTapBackButton(_ sender: Any) {
        self.listener?.didTapBack()
    }

    @IBAction func didTapMuteButton(_ sender: Any) {
        self.isRootSoundMuted = !self.isRootSoundMuted
    }

    @IBAction func didTapAddMoreButton(_ sender: Any) {
        self.listener?.didTapAddMore()
    }

    @IBAction func didTapMuteAudioButton(_ sender: Any) {
        self.isSoundMuted = !self.isSoundMuted
    }

    @IBAction func didTapHideTextButton(_ sender: Any) {
        self.isTextHidden = !self.isTextHidden
    }

    @IBAction func didTapHideFilterButton(_ sender: Any) {
        self.isFilterHidden = !self.isFilterHidden
    }
}

// MARK: - PlayBarViewDelegate
extension EditorViewController: PlayBarViewDelegate {
    func playBarViewDidTapPlay(_ playBarView: PlayBarView, isPlaying: Bool) {
        if !self.isPlayingAtTheEnd {
            if self.playView.isPlaying() {
                self.playView.pause()
            } else {
                self.playView.play()
            }
        } else {
            self.playView.seekTo(0)
            self.playView.play()
        }
    }

    func playBarViewDidTapFullScreen(_ playBarView: PlayBarView) {
        self.listener?.didTapPreview()
    }

    func playBarViewDidTapUndo(_ playBarView: PlayBarView) {
        
    }

    func playBarViewDidTapRedo(_ playBarView: PlayBarView) {

    }
}

// MARK: - EditorPresentable
extension EditorViewController: EditorPresentable {
    func bind(viewModel: EditorViewModel, isNeedToReload: Bool) {
        self.loadViewIfNeeded()
        self.viewModel = viewModel
        if !isNeedToReload {
            if let composedAsset = self.viewModel.currentComposedAsset {
                self.playView.replacePlayerItem(AVPlayerItem(asset: composedAsset))
                self.playBarView.bind(duration: self.viewModel.duration())
            }
        } else {
            self.loadAssets(index: 0)
        }
    }

    func bind(currentTime: Double) {
        self.playBarView.bind(currentTime: String(Int(viewModel.currentTime)).formatVideoDuration())
        if self.playView.isPlaying(), let duration = self.playView.duration() {
            self.frameScrollView.contentOffset.x = currentTime/CMTimeGetSeconds(duration)*Double(frameScrollView.contentSize.width - frameScrollView.frame.width)
            self.timeScrollView.contentOffset.x = self.frameScrollView.contentOffset.x
        }
    }
}

// MARK: PlayerViewDelegate
extension EditorViewController: PlayerViewDelegate {
    func playerViewBeganInterruptAudioSession(_ view: PlayerView) {
        
    }

    func playerViewUpdatePlayingState(_ view: PlayerView, isPlaying: Bool) {
        if isPlaying {
            self.isPlayingAtTheEnd = false
        }
    }

    func playerViewDidPlayToEnd(_ view: PlayerView) {
        self.playBarView.isPlaying = false
        self.isPlayingAtTheEnd = true
    }
}

// MARK: - UIScrollViewDelegate
extension EditorViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let duration = self.playView.duration(), !self.playView.isPlaying() {
            let offset = scrollView.contentOffset.x
            let contentWidth = Double(scrollView.contentSize.width - scrollView.frame.width)
            let progress = offset/contentWidth
            let currentTime = CMTimeGetSeconds(duration) * progress
            self.playView.seekTo(currentTime)
            self.timeScrollView.contentOffset.x = scrollView.contentOffset.x
            self.isPlayingAtTheEnd = offset >= contentWidth
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if self.playView.isPlaying() {
            self.playView.pause()
            self.playBarView.isPlaying = false
            self.isPlayingBefore = true
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if isPlayingBefore {
            isPlayingBefore = false
            self.playView.play()
            self.playBarView.isPlaying = true
        }
    }
}

// MARK: EditMainTabBarDelegate
extension EditorViewController: EditMainTabBarDelegate {
    func onTapEdit() {
        print("---onTapEdit")
        self.listener?.didTapEdit()
    }

    func onTapMusic() {
        print("---onTapMusic")
    }

    func onTapText() {
        print("---onTapText")
    }

    func onTapSticker() {
        print("---onTapSticker")
    }

    func onTapExport() {
        print("---onTapExport")
        self.listener?.didTapExport()
    }
}

// MARK: ExpandableFrameDelegate
extension EditorViewController: ExpandableFrameDelegate {
    func expandableViewDidChangeWidth(_ expandableFramView: ExpandableView, positionX: Double) {
        if let duration = self.playView.duration(), !self.playView.isPlaying() {
            let offset = positionX
            let contentWidth = Double(self.frameScrollView.contentSize.width - self.frameScrollView.frame.width)
            let progress = offset/contentWidth
            let currentTime = CMTimeGetSeconds(duration) * progress
            self.playView.seekTo(currentTime)
            self.isPlayingAtTheEnd = offset >= contentWidth
        }
    }

    func expandableDidScroll(_ expandableFramView: ExpandableView, translation: CGPoint, isContinueScroll: Bool, velocity: CGPoint) {
        if isContinueScroll {
            let scrollX = frameScrollView.contentOffset.x - 0.3*velocity.x
            if scrollX >= 0.0 && scrollX <= frameScrollView.contentSize.width - self.frameScrollView.frame.width {
                let contentOffset = CGPoint(x: scrollX, y: frameScrollView.contentOffset.y)
                frameScrollView.setContentOffset(contentOffset, animated: true)
            }
        } else {
            let scrollX = frameScrollView.contentOffset.x - translation.x
            if scrollX >= 0.0 && scrollX <= frameScrollView.contentSize.width - self.frameScrollView.frame.width {
                frameScrollView.contentOffset.x = scrollX
            }
        }
    }
}
