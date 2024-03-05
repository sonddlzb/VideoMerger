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
    func bind(viewModel: EditorViewModel)
    func didTapBack()
    func updateCurrentVideoTime(currentTime: Double)
    func composeAsset()
    func didTapAddMore()
    func didTapPreview()
    func didTapExport()
    func didTapEdit(adjustmentViewModel: AdjustmentViewModel)
    func didTapAddMusic()
    func trimVideo(startTime: TimeInterval, endTime: TimeInterval)
    func changeVideoSpeed(speedType: SpeedType, startTime: Double, endTime: Double)
    func changeVideoVolume(volume: Float)
}

final class EditorViewController: UIViewController, EditorViewControllable {
    // MARK: - Outlets
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var playView: PlayerView!
    @IBOutlet private weak var playBarView: PlayBarView!
    @IBOutlet private weak var timeStackView: UIStackView!
    @IBOutlet private weak var timeScrollView: UIScrollView!
    @IBOutlet private weak var borderView: UIView!
    @IBOutlet private weak var imgMute: UIImageView!
    @IBOutlet private weak var imgSoundMute: UIImageView!
    @IBOutlet private weak var imgTextHide: UIImageView!
    @IBOutlet private weak var imgFilterHide: UIImageView!
    @IBOutlet private weak var editMainTabBarView: EditMainTabBarView!
    @IBOutlet private weak var frameCollectionView: UICollectionView!
    var expandableWidthConstraint: NSLayoutConstraint!
    var expandableHeightConstraint: NSLayoutConstraint!
    lazy private var expandableFrameView: ExpandableView = {
        let expandableView = ExpandableView()
        expandableView.translatesAutoresizingMaskIntoConstraints = false
        expandableView.isHidden = true
        return expandableView
    }()

    // MARK: - Variables
    weak var listener: EditorPresentableListener?
    var editCompositionBar: EditCompositionBarView?
    var editBarTopMainBarBottomConstraint: NSLayoutConstraint?
    var viewModel = EditorViewModel.makeEmpty()
    private var timeObserverToken: Any?
    var isPlayingBefore = false
    var isPlayingAtTheEnd = false
    var isSetConstraintExpandableView = false
    var listFrame: [ItemFrameViewModel] = []
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
        self.frameCollectionView.rx.observe(CGSize.self, "contentSize")
            .subscribe(onNext: { [weak self] size in
                DispatchQueue.main.async {
                    if let size = size, let self = self {
                        self.expandableWidthConstraint.constant = size.width
                        self.expandableWidthConstraint.isActive = true
                        self.expandableHeightConstraint.constant = size.height - 12
                        self.expandableHeightConstraint.isActive = true
                        self.view.layoutIfNeeded()
                    }
                }
            })
            .disposed(by: self.viewModel.disposeBag)

        if !isSetConstraintExpandableView {
            let expandableEdgeWidth = self.expandableFrameView.contentView.leftEdgeView.frame.width
            self.expandableFrameView.setLimitLeadingConstrant(leading: -frameCollectionView.frame.size.width/2 + expandableEdgeWidth)
            self.expandableFrameView.setLimitTrailingConstrant(trailing: frameCollectionView.frame.size.width/2 - expandableEdgeWidth)
            isSetConstraintExpandableView = true
        }
    }

    private func config() {
        expandableFrameView.delegate = self
        playBarView.delegate = self
        editMainTabBarView.delegate = self
        frameCollectionView.register(UINib(nibName: "FrameCell", bundle: .main), forCellWithReuseIdentifier: "FrameCell")
        let longPressFrameStackGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressEditFrame(_:)))
        longPressFrameStackGesture.minimumPressDuration = 1.0
        frameCollectionView.addGestureRecognizer(longPressFrameStackGesture)
        editCompositionBar = EditCompositionBarView()
        var listView: [TapableView] = []
        self.frameCollectionView.addSubview(expandableFrameView)
        frameCollectionView.translatesAutoresizingMaskIntoConstraints = false
        frameCollectionView.addSubview(expandableFrameView)
        expandableWidthConstraint = expandableFrameView.widthAnchor.constraint(equalToConstant: frameCollectionView.contentSize.width)
        expandableHeightConstraint = expandableFrameView.heightAnchor.constraint(equalToConstant: frameCollectionView.contentSize.height - 12)

        NSLayoutConstraint.activate([
            frameCollectionView.leftAnchor.constraint(equalTo: expandableFrameView.leftAnchor),
            frameCollectionView.topAnchor.constraint(equalTo: expandableFrameView.topAnchor, constant: -12.0)
        ])

        AdjustmentType.allCases.forEach { type in
            let item = EditCompotionItem()
            item.initView(type: type)
            switch type {
            case .filter:
                item.onTap = { [weak self] () -> Void in
                    print("--- onTapFileter")
                }

            case .trim:
                item.onTap = { [weak self] () -> Void in
                    if let self = self, let viewModelDuration = self.playView.duration()?.toDouble() {
                        let startTimeEdit = self.viewModel.startTimeEdit
                        let endTimeEdit = self.viewModel.endTimeEdit
                        if startTimeEdit > 0.1 || endTimeEdit < viewModelDuration {
                            self.listener?.trimVideo(startTime: startTimeEdit, endTime: endTimeEdit)
                        }
                    }
                }

            case .volume:
                item.onTap = { [weak self] () -> Void in
                    if let self = self {
                        self.expandableFrameView.isHidden = true
                        self.listener?.didTapEdit(adjustmentViewModel: VolumeViewModel(value: self.viewModel.volume))
                    }
                }

            case .speed:
                item.onTap = { [weak self] () -> Void in
                    if let self = self {
                        self.listener?.didTapEdit(adjustmentViewModel: SpeedViewModel(value: self.viewModel.speedType))
                    }
                }

            case .remove:
                item.onTap = { [weak self] () -> Void in
                    //self?.listener?.didTapEdit(type: .remove)
                }
            }

            listView.append(item)
        }

        if let editCompositionBar = editCompositionBar {
            editCompositionBar.listView = listView
            self.view.addSubview(editCompositionBar)
            NSLayoutConstraint.activate([
                editCompositionBar.heightAnchor.constraint(equalTo: editMainTabBarView.heightAnchor),
                self.view.leftAnchor.constraint(equalTo: editCompositionBar.leftAnchor),
                self.view.rightAnchor.constraint(equalTo: editCompositionBar.rightAnchor)
            ])
            editBarTopMainBarBottomConstraint = self.editMainTabBarView.bottomAnchor.constraint(equalTo: editCompositionBar.topAnchor)
            editBarTopMainBarBottomConstraint?.isActive = true
            let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown(_:)))
            swipeDownGesture.direction = .down
            self.view.addGestureRecognizer(swipeDownGesture)
        }
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
                        asset.extractFrames(fps: 1) { [weak self] imageData, error, second, isFinish, scale in
                            guard error == nil else {
                                print("Error when extracting frames: \(error!.localizedDescription)")
                                return
                            }

                            DispatchQueue.main.async {
                                self?.insertFrames(imageData: imageData, second: second, isFinish: isFinish, scale: scale, index: index)
                            }
                        }
                    }
                }
            })
        } else if phAsset.mediaType == .image {
            DispatchQueue.main.async {
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

    func insertFrames(imageData: Data?, second: Int, isFinish: Bool, scale: Double, index: Int) {
        if let imageData = imageData {
            if self.scale < 0 {
                self.scale = scale
            }

            let fileName = "\(imageData.description)\(second)"
            guard let imageURL = self.viewModel.saveImageToCaches( fileName, data: imageData) else {
                return
            }

            self.listFrame.append(ItemFrameViewModel(url: imageURL, time: String(self.viewModel.secondAt(second, index: index)).formatVideoDuration(), scale: scale, isFrame: true))

            if isFinish {
                dispatchGroup.leave()
                dispatchGroup.notify(queue: .main) {
                    if index < self.viewModel.numberOfAsset() - 1 {
                        self.loadAssets(index: index+1)
                    } else {
                        self.listener?.composeAsset()
                    }

                    self.frameCollectionView.reloadData()
                }
            }
        }
    }

    func insertFrame(_ image: UIImage?, index: Int) {
        // MARK: - handle for image later
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

    private func showEditCompositionBar() {
        UIView.animate(withDuration: 0.5) {
            self.editBarTopMainBarBottomConstraint?.constant = self.editMainTabBarView.frame.height
            self.view.layoutIfNeeded()
        }
    }

    private func hiddenEditCompositionBar() {
        UIView.animate(withDuration: 0.5) {
            self.editBarTopMainBarBottomConstraint?.constant = -self.editMainTabBarView.frame.height
            self.view.layoutIfNeeded()
        }
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
    @objc private func handleSwipeDown(_ gesture: UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            self.hiddenEditCompositionBar()
            self.expandableFrameView.isHidden = true
        }
    }
    @objc private func onLongPressEditFrame(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            self.showEditCompositionBar()
            self.expandableFrameView.isHidden = false
        }
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
    func showExpandableView(isShow: Bool) {
        self.expandableFrameView.isHidden = !isShow
    }

    func bind(viewModel: EditorViewModel, adjustmentType: AdjustmentType) {
        self.viewModel = viewModel
        if let composedAsset = self.viewModel.currentComposedAsset {
            self.playView.replacePlayerItem(AVPlayerItem(asset: composedAsset))
            self.viewModel.currentTime = 0.0
            self.playBarView.bind(duration: self.viewModel.duration())
            var isReload = false

            if adjustmentType == .trim {
                let duration = composedAsset.duration
                self.viewModel.startTimeEdit = 0.0
                self.viewModel.endTimeEdit = CMTimeGetSeconds(duration)
                self.expandableFrameView.trailingConstraint.constant = self.frameCollectionView.frame.width / 2 - 15.0
                self.expandableFrameView.leadingConstraint.constant = -self.frameCollectionView.frame.width / 2 + 15.0
                isReload = true
            } else if adjustmentType == .speed {
                let oldSpeed = viewModel.oldSpeedType.rawValue
                let speed = viewModel.speedType.rawValue
                self.viewModel.startTimeEdit = self.viewModel.startTimeEdit * oldSpeed / speed
                self.viewModel.endTimeEdit = self.viewModel.endTimeEdit * oldSpeed / speed
                isReload = true
            } else if adjustmentType == .volume {
                self.playView.setVolume(volume: self.viewModel.volume)
                self.expandableFrameView.isHidden = false
            }

            self.listener?.bind(viewModel: viewModel)
            if isReload {
                listFrame.removeAll()
                dispatchGroup.enter()
                composedAsset.extractFrames(fps: 1) { [weak self] (imageData, error, second, isFinish, scale) in
                    guard error == nil else {
                        print("Error when extracting frames: \(error!.localizedDescription)")
                        return
                    }

                    DispatchQueue.main.async {
                        if let self = self, let imageData = imageData {
                            if self.scale < 0 {
                                self.scale = scale
                            }

                            let fileName = "\(imageData.description)\(second)"
                            guard let imageURL = self.viewModel.saveImageToCaches(fileName, data: imageData) else {
                                return
                            }

                            self.listFrame.append(ItemFrameViewModel(url: imageURL, time: String(second).formatVideoDuration(), scale: scale, isFrame: true))
                            if isFinish {
                                self.dispatchGroup.leave()
                                self.dispatchGroup.notify(queue: .main) {
                                    self.frameCollectionView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func bind(viewModel: EditorViewModel, isNeedToReload: Bool) {
        self.loadViewIfNeeded()
        self.viewModel = viewModel
        if !isNeedToReload {
            if let composedAsset = self.viewModel.currentComposedAsset {
                self.playView.replacePlayerItem(AVPlayerItem(asset: composedAsset))
                self.viewModel.currentTime = 0.0
                self.playBarView.bind(duration: self.viewModel.duration())
                self.viewModel.startTimeEdit = 0.0
                self.viewModel.endTimeEdit = composedAsset.duration.seconds
                self.listener?.bind(viewModel: self.viewModel)
            }
        } else {
            self.listFrame.removeAll()
            self.loadAssets(index: 0)
        }
    }

    func bind(currentTime: Double) {
        self.playBarView.bind(currentTime: String(Int(viewModel.currentTime)).formatVideoDuration())
        if self.playView.isPlaying(), let duration = self.playView.duration() {
            self.frameCollectionView.contentOffset.x = currentTime/CMTimeGetSeconds(duration)*Double(frameCollectionView.contentSize.width - frameCollectionView.frame.width)
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
        self.showEditCompositionBar()
        self.expandableFrameView.isHidden = false
    }

    func onTapMusic() {
        print("---onTapMusic")
        self.listener?.didTapAddMusic()
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
    func expandableViewDidChangeWidth(_ expandableFramView: ExpandableView, positionX: Double, edge: ExpandableEdges) {
        if let duration = self.playView.duration(), !self.playView.isPlaying() {
            let offset = positionX
            let contentWidth = Double(self.frameCollectionView.contentSize.width - self.frameCollectionView.frame.width)
            let progress = offset/contentWidth
            let currentTime = CMTimeGetSeconds(duration) * progress
            self.playView.seekTo(currentTime)
            self.isPlayingAtTheEnd = offset >= contentWidth
            if edge == .left {
                self.viewModel.startTimeEdit = currentTime.rounded(.up)
            } else if currentTime < (self.playView.duration()?.toDouble() ?? 0.0) {
                self.viewModel.endTimeEdit = currentTime.rounded(.down)
            }

            self.listener?.bind(viewModel: self.viewModel)
        }
    }

    func expandableDidScroll(_ expandableFramView: ExpandableView, translation: CGPoint, isContinueScroll: Bool, velocity: CGPoint) {
        if isContinueScroll {
            let scrollX = frameCollectionView.contentOffset.x - 0.3*velocity.x
            if scrollX >= 0.0 && scrollX <= frameCollectionView.contentSize.width - self.frameCollectionView.frame.width {
                let contentOffset = CGPoint(x: scrollX, y: frameCollectionView.contentOffset.y)
                frameCollectionView.setContentOffset(contentOffset, animated: true)
            }
        } else {
            let scrollX = frameCollectionView.contentOffset.x - translation.x
            if scrollX >= 0.0 && scrollX <= frameCollectionView.contentSize.width - self.frameCollectionView.frame.width {
                frameCollectionView.contentOffset.x = scrollX
            }
        }
    }
}

// MARK: CollectionViewDelegate
extension EditorViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listFrame.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FrameCell", for: indexPath) as? FrameCell {
            if indexPath.row == 0 || indexPath.row == self.listFrame.count {
                cell.bind(itemFrame: ItemFrameViewModel(url: nil, time: nil, scale: nil, isFrame: false))
            } else if indexPath.row < self.listFrame.count {
                cell.bind(itemFrame: self.listFrame[indexPath.row])
            }

            return cell
        }

        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 || indexPath.row == self.listFrame.count {
            return CGSize(width: self.frameCollectionView.frame.width / 2, height: self.frameCollectionView.frame.height)
        }

        return CGSize(width: self.frameCollectionView.frame.height*self.scale, height: self.frameCollectionView.frame.height)
    }
}
