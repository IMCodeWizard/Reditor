//
//  DrawViewController.swift
//  CustomControls
//
//  Created by Ninja on 04/10/2018.
//  Copyright © 2018 iOS Ninja. All rights reserved.
//

import UIKit
import AVFoundation

class DrawViewController: UIViewController, ColorPickerControlDelegate {
    
    enum DrawMode: Int {
        case pencil
        case text
    }
    
    var delegate: ReditorProtocol?
    var imageSource: UIImage?
    
    // Controls container
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var buttonTextAction: UIButton!
    @IBOutlet weak var buttonPencilAction: UIButton!
    @IBOutlet weak var colorPicker: ColorPickerControl!
    
    @IBOutlet weak var constraintHeightCanvasContainerView: NSLayoutConstraint!
    @IBOutlet weak var constraintWidthCanvasContainerView: NSLayoutConstraint!
    @IBOutlet weak var canvasContainerView: UIView!
    @IBOutlet weak var originImageView: UIImageView!
    @IBOutlet weak var canvasView: CanvasView!
    
    
    @IBOutlet weak var buttonUndo: UIButton!
    @IBOutlet weak var buttonRedo: UIButton!

    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Undo Handler Listener
        NotificationCenter.default.addObserver(self, selector: #selector(undoHandler), name: NSNotification.Name.NSUndoManagerDidUndoChange, object: undoManager)
        NotificationCenter.default.addObserver(self, selector: #selector(undoHandler), name: NSNotification.Name.NSUndoManagerDidRedoChange, object: undoManager)
        NotificationCenter.default.addObserver(self, selector: #selector(undoHandler), name: NSNotification.Name.NSUndoManagerCheckpoint, object: undoManager)
        
        //Color
        colorPicker.delegate = self
        
        if let img = imageSource {
            self.originImageView.image = img
        }
    }
    
    override func viewDidLayoutSubviews() {
        setupOringinRect()
    }
    
    // MARK: - Actions
    @IBAction func buttonBackAction(_ sender: UIButton) {
        
        
        if sender.tag == 0 {
            //TODO: - Close drawer
            self.delegate?.reditorDidCanceledDrawing()
//            self.dismiss(animated: true, completion: nil)
        }else{
            // 1. Change back button behavior
            sender.tag = 0
            buttonBack.isSelected = false
            // 2. Reset apprance
            UIView.animate(withDuration: 0.33, animations: {
                self.colorPicker.alpha = 0.0
            }) { (done) in
                self.buttonPencilAction.isHidden = false
                self.buttonTextAction.isHidden = false
                self.canvasView.isDrawing = false
            }
        }
    }
    
    @IBAction func buttonSendAction(_ sender: UIButton) {
        //TODO: - 1. Create func that combine draw layer with source image and send it back. 2. close editor 3. tranfer image via deelegate
        
        let image = self.canvasContainerView.toImage()
        self.delegate?.reditorDidFinishedDrawing(image: image)
//        self.dismiss(animated: true, completion: nil)
    
    }
    
    @IBAction func selectedModeAction(_ sender: UIButton) {
        
        let mode = DrawMode(rawValue: sender.tag)!
        
        switch mode {
        case .pencil:
            showPencilMode()
        case .text:
            showTextMode()
        }
    }
    
    @IBAction func undoAction(_ sender: UIButton) {
        self.undoManager?.undo()
    }
    
    @IBAction func redoAction(_ sender: UIButton) {
        self.undoManager?.redo()
    }
    
    @IBAction func clearAction(_ sender: UIButton) {
        self.canvasView.clearCanvas()
        undoHandler()
    }
    
    
    // MARK: - UI Appearance
    func setupOringinRect() {
        
        var canvasRect = controlsContainer.frame
        canvasRect.size.width -= 40
        
        let topPadding = (colorPicker.frame.origin.y + colorPicker.frame.size.height)
        let bottomPadding = (controlsContainer.frame.size.height - buttonUndo.superview!.frame.origin.y)
        let sumPadding = topPadding + bottomPadding
        canvasRect.size.height -= (sumPadding + 40)
        let calculatedRect = AVMakeRect(aspectRatio: originImageView.image!.size, insideRect: canvasRect)
        constraintHeightCanvasContainerView.constant = calculatedRect.size.height
        constraintWidthCanvasContainerView.constant = calculatedRect.size.width
        self.view.layoutIfNeeded()
        
    }
    
    func showPencilMode() {
        
        canvasView.isDrawing = true
        canvasView.drawColor = colorPicker.selectedColor.color
        
        // 1. Hide text mode
        buttonTextAction.isHidden = true
        
        // 2. Show Color Bar
        UIView.animate(withDuration: 0.33, delay: 0.22, options: [.curveEaseInOut], animations: {
            self.colorPicker.alpha = 1.0
        })
        
        // 3. Change back button behavior
        buttonBack.tag = 1
        buttonBack.isSelected = true
        
    }
    
    func showTextMode() {
        
        // 1. Hide pencil mode
        buttonPencilAction.isHidden = true
        
        // 2. Show Color Bar
        UIView.animate(withDuration: 0.33, delay: 0.22, options: [.curveEaseInOut], animations: {
            self.colorPicker.alpha = 1.0
        })
        
        // 3. Change back button behavior
        buttonBack.tag = 1
        buttonBack.isSelected = true
        
        canvasView.drawColor = colorPicker.selectedColor.color
        self.canvasView.placeText()
    }
    
    
    func selectedColor(color: UIColor) {
        canvasView.drawColor = color
    }
    
    @objc func undoHandler(){
        
        if let canUndo = undoManager?.canUndo {
            self.buttonUndo.isEnabled = canUndo
        }
        
        if let canRedo = undoManager?.canRedo {
            self.buttonRedo.isEnabled = canRedo
        }
    }
}
