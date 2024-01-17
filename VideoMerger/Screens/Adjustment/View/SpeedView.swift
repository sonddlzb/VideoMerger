//
//  SpeedView.swift
//  VideoMerger
//
//  Created by đào sơn on 17/01/2024.
//

import UIKit

enum SpeedType: Double {
    case speedA = 0.4
    case speedB = 0.8
    case speedC = 1.0
    case speedD = 2.0
    case speedE = 3.0
    case speedF = 4.0
    case speedG = 5.0
}

class SpeedView: UIView {
    // MARK: - Outlets
    @IBOutlet weak var containerSpeedA: UIView!
    @IBOutlet weak var containerSpeedB: UIView!
    @IBOutlet weak var containerSpeedC: UIView!
    @IBOutlet weak var containerSpeedD: UIView!
    @IBOutlet weak var containerSpeedE: UIView!
    @IBOutlet weak var containerSpeedF: UIView!
    @IBOutlet weak var containerSpeedG: UIView!

    // MARK: - Variables
    var currentSpeed: SpeedType = .speedC {
        didSet {
            self.updateSpeedData()
        }
    }

    var listContainerSpeeds: [UIView] = []

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadView()
        self.config()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadView()
        self.config()
    }

    func config() {
        listContainerSpeeds.append(containerSpeedA)
        listContainerSpeeds.append(containerSpeedB)
        listContainerSpeeds.append(containerSpeedC)
        listContainerSpeeds.append(containerSpeedD)
        listContainerSpeeds.append(containerSpeedE)
        listContainerSpeeds.append(containerSpeedF)
        listContainerSpeeds.append(containerSpeedG)
    }

    func loadView() {
        let playBar = Bundle.main.loadNibNamed("SpeedView", owner: self, options: nil)?[0] as? UIView ?? UIView()
        playBar.fixInView(self)
    }

    func updateSpeedData() {
        listContainerSpeeds.forEach {
            $0.backgroundColor = UIColor(rgb: 0xE0E0E0)
        }

        switch self.currentSpeed {
        case .speedA: self.containerSpeedA.backgroundColor = UIColor(rgb: 0x536DFE)
        case .speedB: self.containerSpeedB.backgroundColor = UIColor(rgb: 0x536DFE)
        case .speedC: self.containerSpeedC.backgroundColor = UIColor(rgb: 0x536DFE)
        case .speedD: self.containerSpeedD.backgroundColor = UIColor(rgb: 0x536DFE)
        case .speedE: self.containerSpeedE.backgroundColor = UIColor(rgb: 0x536DFE)
        case .speedF: self.containerSpeedF.backgroundColor = UIColor(rgb: 0x536DFE)
        case .speedG: self.containerSpeedG.backgroundColor = UIColor(rgb: 0x536DFE)
        }
    }

    @IBAction func didTapSpeedA(_ sender: Any) {
        self.currentSpeed = .speedA
    }

    @IBAction func didTapSpeedB(_ sender: Any) {
        self.currentSpeed = .speedB
    }

    @IBAction func didTapSpeedC(_ sender: Any) {
        self.currentSpeed = .speedC
    }

    @IBAction func didTapSpeedD(_ sender: Any) {
        self.currentSpeed = .speedD
    }

    @IBAction func didTapSpeedE(_ sender: Any) {
        self.currentSpeed = .speedE
    }

    @IBAction func didTapSpeedF(_ sender: Any) {
        self.currentSpeed = .speedF
    }

    @IBAction func didTapSpeedG(_ sender: Any) {
        self.currentSpeed = .speedG
    }
}
