//
//  ExpandableContentView.swift
//  VideoMerger
//
//  Created by Hưng Hà Quang on 17/01/2024.
//

import UIKit

class ExpandableContentView: UIView {
    // MARK: Variable
    @IBOutlet weak var leftEdgeView: UIImageView!
    @IBOutlet weak var rightEdgeView: UIImageView!

    // MARK: function
    func loadView() {
        let expandableContentView = Bundle.main.loadNibNamed("ExpandableContentView", owner: self, options: nil)?[0] as? UIView ?? UIView()
        expandableContentView.fixInView(self)
    }

    // MARK: lifeCycle
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
}
