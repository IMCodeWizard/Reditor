//
//  ColorPickerControl.swift
//  CustomControls
//
//  Created by Ninja on 04/10/2018.
//  Copyright © 2018 iOS Ninja. All rights reserved.
//

import UIKit

enum ColorSet: Int {
    
    case white
    case black
    case red
    case yellow
    case blue
    case turqouise
    
    var color: UIColor {
        switch self {
        case .white:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .black:
            return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case .red:
            return #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
        case .yellow:
            return #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 1)
        case .blue:
            return #colorLiteral(red: 0.1921568627, green: 0.3176470588, blue: 0.7176470588, alpha: 1)
        case .turqouise:
            return #colorLiteral(red: 0, green: 0.8028612733, blue: 0.6834338307, alpha: 1)
        }
    }
    
    static let mapper: [ColorSet: String] = [
        .white: "white",
        .black: "black",
        .red: "red",
        .yellow: "yellow",
        .blue: "blue",
        .turqouise: "turqouise"
    ]
    
    var string: String {
        return ColorSet.mapper[self]!
    }
}

protocol ColorPickerControlDelegate {
    func selectedColor(color: UIColor)
}

@IBDesignable class ColorPickerControl: UIView {

    //MARK: Properties
    
    var delegate: ColorPickerControlDelegate?

    let stackView = UIStackView()
    var colors: [ColorSet] = [.white, .black, .red, .yellow, .blue, .turqouise]
    var defaultColor: ColorSet = .turqouise
    var selectedColor: ColorSet!
    
    
    //MARK: Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        setupStackConfigs()
        setupButtons()
    }

    //MARK: - UI Configs

    func setupStackConfigs() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.height / 2
        
        self.addSubview(stackView)
        let offset: CGFloat = 4.0
        var stackFrame = self.bounds
        stackFrame.origin.y = stackFrame.origin.y + offset
        stackFrame.size.height = stackFrame.size.height - offset
        
        
        stackView.frame = stackFrame
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
    }

    func setupButtons() {

        // Reset views
        for subview in self.stackView.subviews {
            stackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        let bundle = Bundle(for: type(of: self))

        for index in 0..<colors.count {

            let button = UIButton(type: .custom)
            button.tag = index
            let img1 = UIImage(named: "BTN_normal_\(colors[index].string)", in: bundle, compatibleWith: self.traitCollection)
            let img2 = UIImage(named: "BTN_selected_\(colors[index].string)", in: bundle, compatibleWith: self.traitCollection)
            button.setImage(img1, for: .normal)
            button.setImage(img2, for: .selected)
            button.imageView?.contentMode = .scaleAspectFit
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: self.bounds.width / (CGFloat(colors.count)) ).isActive = true
            button.addTarget(self, action: #selector(colorButtonTapped(button:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        selectedColor = defaultColor
        hightlightedColor(color: defaultColor)
    }

    @objc func colorButtonTapped(button: UIButton) {
        
        let color = colors[button.tag]
        
        guard selectedColor != color else {
            print("Already selected \(color.string) color")
            return
        }
        
        normalColor(color: selectedColor)
        hightlightedColor(color: color)
        selectedColor = color
        self.delegate?.selectedColor(color: color.color)
    }
    
    
    func hightlightedColor(color: ColorSet) {
        
        let button = stackView.subviews[color.rawValue] as! UIButton
        button.isSelected = true
    }
    
    func normalColor(color: ColorSet) {
        let button = stackView.subviews[color.rawValue] as! UIButton
        button.isSelected = false
    }
}
