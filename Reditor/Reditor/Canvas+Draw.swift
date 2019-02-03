//
//  Canvas+Draw.swift
//  Reditor
//
//  Created by Ninja on 23/10/2018.
//  Copyright © 2018 Ninja. All rights reserved.
//

import Foundation


extension CanvasView {
    
    //MARK: - Rendering path on view
    override func draw(_ rect: CGRect) {
        
        // Draw each path
        for drawPath in self.drawPaths.rawArray() {
            drawPath.path.lineCapStyle = .round
            drawPath.color.setStroke()
            drawPath.path.stroke()
        }
    }
    
    // MARK: - Path Handler
    func newPath() -> DrawPath? {
        let path = UIBezierPath()
        path.lineWidth = self.lineWidth
        
        let drawPath = DrawPath(path: path, color: drawColor)
        drawPaths.push(drawPath)
        undoManager?.registerUndo(withTarget: self, handler: { (target) in
            target.undo()
        })
        
        return drawPath
    }
    
    func currentPath() -> DrawPath? {
        return self.drawPaths.top
    }
    
    // MARK: - Undo Handler
    func undo() {
        
        if let drawPath = self.drawPaths.pop() {
            
            undoManager?.registerUndo(withTarget: self, handler: { (target) in
                target.redo(drawPath: drawPath)
            })
            
            var refreshRect = self.bounds
            
            // Add lineWidth to the rect to include edges of the path
            refreshRect = drawPath.path.bounds.insetBy(dx: -self.lineWidth, dy: -self.lineWidth)
            
            // Refresh the rect of the screen where the last path was
            setNeedsDisplay(refreshRect)
        }
    }
    
    func redo(drawPath: DrawPath) {
        
        undoManager?.registerUndo(withTarget: self, handler: { (target) in
            target.undo()
        })
        
        self.drawPaths.push(drawPath)
        
        var refreshRect = self.bounds
        
        // Add lineWidth to the rect to include edges of the path
        refreshRect = drawPath.path.bounds.insetBy(dx: -self.lineWidth, dy: -self.lineWidth)
        
        // Refresh the rect of the screen where the last path was
        setNeedsDisplay(refreshRect)
        
    }
    
    func clearCanvas() {
        // Reset Undo Manager
        self.undoManager?.removeAllActions()
        // Remove all paths
        self.drawPaths.clear()
        // Refresh the entire display
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        setNeedsDisplay()
    }
    
    
    // MARK: - Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first, isDrawing else { return }
        
        let point = touch.location(in: self)
        self.newPath()?.path.move(to: point)
        self.currentPath()?.path.lineWidth = self.lineWidth
        
        self.points.removeAll()
        self.points.append(point)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first, isDrawing else { return }
        
        let point = touch.location(in: self)
        self.points.append(point)
        
        if self.points.count == 4 {
            let middlePoint = CGPoint(x: (self.points[1].x + self.points[3].x) / 2.0, y: (self.points[1].y + self.points[3].y) / 2.0)
            
            currentPath()?.path.move(to: self.points[0])
            currentPath()?.path.addQuadCurve(to: middlePoint, controlPoint: self.points[1])
            
            // replace points and get ready to handle the next segment
            let lastPoint = self.points[3]
            self.points.removeAll()
            self.points.append(middlePoint)
            self.points.append(lastPoint)
            
            // Refresh only a potion of screen
            let refreshRect = currentPath()?.path.bounds.insetBy(dx: -self.lineWidth, dy: -self.lineWidth) ?? self.bounds
            setNeedsDisplay(refreshRect)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard touches.first != nil, isDrawing else { return }
        
        // Draw remaining points
        if self.points.count == 1 {
            
            currentPath()?.path.lineWidth = self.lineWidth / 2.0
            currentPath()?.path.addArc(withCenter: self.points[0], radius: lineWidth / 4.0, startAngle: 0, endAngle: .pi * 2.0, clockwise: true)
            setNeedsDisplay(CGRect(x: self.points[0].x - self.lineWidth,
                                   y: self.points[0].y - self.lineWidth,
                                   width: self.lineWidth * 2.0,
                                   height: self.lineWidth * 2.0))
        } else if self.points.count == 2 {
            currentPath()?.path.move(to: self.points[0])
            currentPath()?.path.addLine(to: self.points[1])
            setNeedsDisplay(CGRect(p1: self.points[0], p2: self.points[1]).insetBy(dx: -self.lineWidth, dy: -self.lineWidth))
            
        } else if self.points.count == 3 {
            currentPath()?.path.move(to: self.points[0])
            currentPath()?.path.addQuadCurve(to: self.points[2], controlPoint: self.points[1])
            setNeedsDisplay(CGRect(p1: self.points[0], p2: self.points[2]).insetBy(dx: -self.lineWidth, dy: -self.lineWidth))
        }
        
        self.points.removeAll()
    }
    
}
