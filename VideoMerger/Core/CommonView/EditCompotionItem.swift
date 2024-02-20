//
//  EditCompotionItem.swift
//  VideoMerger
//
//  Created by Hưng Hà Quang on 19/02/2024.
//

import UIKit

class EditCompotionItem: TapableView {
    // MARK: Variable
    private var stackView: UIStackView!
    var imageName: String!
    var title: String!
    var onTap: (() -> Void)?

    func initView(type: AdjustmentType) {
        self.imageName = type.imageAsset()
        self.title = type.name()
        setUpSubViews()
    }

    // MARK: Lifecycle methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        config()
    }

    private func setUpSubViews() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.fixInView(self)
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit
        let title = UILabel()
        title.text = self.title
        title.textColor = UIColor(named: "spanish_gray")
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(title)
    }

    private func config() {
        self.addTarget(self, action: #selector(handleTap(_ :)), for: .touchUpInside)
    }

    // MARK: Action
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        if let onTap = self.onTap {
            onTap()
        }
    }
}
