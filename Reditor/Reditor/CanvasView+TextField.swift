//
//  CanvasView+TextField.swift
//  Reditor
//
//  Created by Ninja on 23/10/2018.
//  Copyright © 2018 Ninja. All rights reserved.
//

import Foundation

extension CanvasView: UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    func placeText() {
        
        /** Init */
        let textField = UITextField()
        
        /** Text configs */
        textField.font = UIFont.systemFont(ofSize: 30)
        textField.placeholder = "Text"
        textField.updatePlaceholderColor(color: drawColor)
        textField.textColor = drawColor
        textField.textAlignment = .center
        textField.autocorrectionType = .no
        
        /** Shodow */
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        textField.layer.shadowOpacity = 0.2
        textField.layer.shadowRadius = 1.0
        textField.layer.backgroundColor = UIColor.clear.cgColor
        
        /** Size & Position */
        textField.sizeToFit()
        textField.center = self.center
        
        /** Keyboard Appearance */
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barStyle = .blackTranslucent
        toolbar.items = [UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil),
                         UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissAction))]
        textField.inputAccessoryView = toolbar
        textField.keyboardAppearance = .dark
        
        /** Others */
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        /** Gestures */
        addGestures(view: textField)
        
        /** Text Field View Handler */
        self.addSubview(textField)
        textField.becomeFirstResponder()
        self.textField = textField
        
        /** Undo Manager */
        undoManager?.registerUndo(withTarget: self, handler: { (target) in
            target.removetextField(textField: textField)
        })
        
    }
    
    
    func updatetextField(textField: UITextField, withText text: String) {
        textField.text = text
    }
    
    func removetextField(textField: UITextField) {
        
        undoManager?.registerUndo(withTarget: self, handler: { (target) in
            target.addtextField(textField: textField)
        })
        
        textField.removeFromSuperview()
    }
    
    
    func addtextField(textField: UITextField) {
        
        undoManager?.registerUndo(withTarget: self, handler: { (target) in
            target.removetextField(textField: textField)
        })
        
        self.addSubview(textField)
    }
    
    @objc func dismissAction(){
        self.textField?.resignFirstResponder()
        self.textField = nil
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        let size = textField.intrinsicContentSize
        textField.frame = CGRect(x: textField.frame.minX, y: textField.frame.minY, width: size.width, height: size.height)
        
    }
    
    // MARK: - Gestures Handler
    
    func addGestures(view: UIView) {
        view.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(_:)))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        if let view = recognizer.view {
            moveView(view: view, recognizer: recognizer)
        }
    }
    
    @objc func pinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            if view is UITextField {
                let textField = view as! UITextField
                var pinchScale = recognizer.scale
                pinchScale = round(pinchScale * 1000) / 1000.0
                if (pinchScale < 1) {
                    textField.font = UIFont.systemFont(ofSize: textField.font!.pointSize*pinchScale, weight: .regular)
                    pinchScale = recognizer.scale
                } else {
                    textField.font = UIFont.systemFont(ofSize: textField.font!.pointSize*pinchScale, weight: .regular)
                    pinchScale = recognizer.scale
                }
                textFieldDidChange(textField)
            }
            
            recognizer.scale = 1
        }
    }
    
    @objc func tapGesture(_ recognizer: UITapGestureRecognizer) {
        if let view = recognizer.view, view is UITextField {
            self.textField = view as? UITextField
            self.textField?.becomeFirstResponder()
            scaleEffect(view: view)
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    
    
    // MARK: - Gestues Behavior
    
    /** Moving Objects, Return back if it's out of the canvas */
    func moveView(view: UIView, recognizer: UIPanGestureRecognizer)  {
        
        view.superview?.bringSubview(toFront: view)
        
        let pointToSuperView = recognizer.location(in: self)
        
        view.center = CGPoint(x: view.center.x + recognizer.translation(in: self).x, y: view.center.y + recognizer.translation(in: self).y)
        
        recognizer.setTranslation(CGPoint.zero, in: self)
        
        lastPanPoint = pointToSuperView
        
        if recognizer.state == .ended {
            lastPanPoint = nil
            
            if !self.frame.contains(view.center) {
                UIView.animate(withDuration: 0.3, animations: {
                    view.center = self.center
                })
            }
        }
    }
    
    /** Scale Effect */
    func scaleEffect(view: UIView) {
        view.superview?.bringSubview(toFront: view)
        
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
        let previouTransform =  view.transform
        
        UIView.animate(withDuration: 0.2, animations: {
            view.transform = view.transform.scaledBy(x: 1.2, y: 1.2)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2) {
                view.transform  = previouTransform
            }
        })
    }
    
}
