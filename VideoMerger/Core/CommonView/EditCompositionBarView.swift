//
//  EditCompositionBarView.swift
//  VideoMerger
//
//  Created by Hưng Hà Quang on 19/02/2024.
//

import UIKit

class EditCompositionBarView: UIView {
    // MARK: Variable
    var stackView: UIStackView!
    var listView: [TapableView] = [] {
        willSet {
            stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        }

        didSet {
            for item in listView {
                stackView.addArrangedSubview(item)
            }
        }
    }

    // MARK: Lifecycle methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        setUpSubViews()
    }

    private func setUpSubViews() {
        self.backgroundColor = .white
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        self.addSubview(stackView)
        self.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: stackView.topAnchor),
            self.leftAnchor.constraint(equalTo: stackView.leftAnchor),
            self.rightAnchor.constraint(equalTo: stackView.rightAnchor),
            self.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20.0)
        ])
    }
}
