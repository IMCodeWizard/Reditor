//
//  DrawView.swift
//  CustomControls
//
//  Created by Ninja on 15/10/2018.
//  Copyright © 2018 iOS Ninja. All rights reserved.
//

import UIKit

struct DrawPath{
    let path: UIBezierPath
    let color: UIColor
}

class CanvasView: UIView {
    
    var isDrawing = false
    var textDidChanged = false
    var drawColor = UIColor.black {
        didSet{
            if let textField = self.textField {
                textField.textColor = drawColor
                textField.updatePlaceholderColor(color: drawColor)
            }
        }
    }
    var lineWidth = CGFloat(3.0)
    var lastPanPoint: CGPoint?
    var points = [CGPoint]()
    var drawPaths = Stack<DrawPath>()
    
    var textField: UITextField?
    
    // MARK: - Life Cycle
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        self.backgroundColor = UIColor.clear
        self.isMultipleTouchEnabled = false
    }
    
}
