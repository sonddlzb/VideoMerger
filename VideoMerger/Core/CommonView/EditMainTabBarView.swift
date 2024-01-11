//
//  EditMainTabBarView.swift
//  VideoMerger
//
//  Created by Hưng Hà Quang on 11/01/2024.
//

import UIKit

protocol EditMainTabBarDelegate: AnyObject {
    func onTapEdit()
    func onTapMusic()
    func onTapText()
    func onTapSticker()
    func onTapExport()
}

class EditMainTabBarView: UIView {
    // MARK: Variable
    weak var delegate: EditMainTabBarDelegate?

    // MARK: Method
    func loadView() {
        let editMainTabBar = Bundle.main.loadNibNamed("EditMainTabBarView", owner: self, options: nil)?[0] as? UIView ?? UIView()
        editMainTabBar.fixInView(self)
    }

    // MARK: Override method
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }

    // MARK: Action
    @IBAction func onTapEditButton(_ sender: Any) {
        delegate?.onTapEdit()
    }

    @IBAction func onTapMusicButton(_ sender: Any) {
        delegate?.onTapMusic()
    }

    @IBAction func onTapTextButton(_ sender: Any) {
        delegate?.onTapText()
    }

    @IBAction func onTapStickerButton(_ sender: Any) {
        delegate?.onTapSticker()
    }

    @IBAction func onTapExportButton(_ sender: Any) {
        delegate?.onTapExport()
    }
}
