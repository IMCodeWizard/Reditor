//
//  Protocol.swift
//  Reditor
//
//  Created by Ninja on 18/10/2018.
//  Copyright © 2018 Ninja. All rights reserved.
//

import Foundation

public protocol ReditorProtocol {
    
    func reditorDidFinishedDrawing(image: UIImage)
    
    func reditorDidCanceledDrawing()
}

open class Reditor: NSObject {
    
    public class func setupRedior(withImage image: UIImage, listener: UIViewController) -> UIViewController? {
    
        let bundle = Bundle(for: Reditor.self)
        
        let drawVC = UIStoryboard(name: "Main", bundle: bundle).instantiateViewController(withIdentifier: "DRAW") as! DrawViewController
        drawVC.imageSource = image
        drawVC.delegate = listener as? ReditorProtocol
        return drawVC
    }
}
