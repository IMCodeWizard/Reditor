# Reditor 
- Reditor allow to annotate image by drawing & place text
[![CocoaPods](https://img.shields.io/cocoapods/p/CodeEditorView.svg)]()
[![CocoaPods](https://img.shields.io/cocoapods/l/CodeEditorView.svg)]()

![Screenshot](https://github.com/iOS-Ninja/Reditor/blob/master/IMG_01.PNG)
![Screenshot](https://github.com/iOS-Ninja/Reditor/blob/master/IMG_02.PNG)

# Getting Started

## Installation with CocoaPods

CocoaPods is a dependency manager for Swift and Objective-C Cocoa projects. It has over 54 thousand libraries and is used in over 3 million apps. CocoaPods can help you scale your projects elegantly.


1. Using the default Ruby install can require you to use sudo when installing gems.
```
$ sudo gem install cocoapods
```

2. CocoaPods provides a pod init command to create a Podfile with smart defaults. You should use it.
```
$ cd <#Your project path#>
```
```
$ pod init
```

3. Then add Reditor to pod file
```
platform :ios, '10.0'
use_frameworks!

target 'MyApp' do
    pod 'Reditor'
end
```

4. Run pod install command
```
$ pod install
```

# Usage

## Init & setup
- NOTE: To handle better appearance effect it recommended to pre-define view container that will hold the reditor view

1. Create a UIView in storyboard and connect it to "@IBOutlet" in your own controller.
- (You also can do this in code. Create a UIView with frame size of "self.bounds" and add to subview with alpha zero).
2. Reditor initiation return UIViewController that should be added as child view controller to your own controller.
3. Then give frame size to reditorVC's view of a predefined container.
4. Add reditorVC's view to predefined container subview.
5. Add alpha animation to the predefined container to get a fade in effect.
6. Finally, add protocol & methods.

```
class ViewController: UIViewController, ReditorProtocol {


    @IBOutlet weak var reditorContainerView: UIView!


    func presentReditorVC(image: UIImage) {
    
        if let reditorVC = Reditor.setupRedior(withImage: image, listener: self) {
    
            self.addChildViewController(reditorVC)
    
            /** Container */
            reditorContainerView.alpha = 0.0
    
            /** Reditor config */
            reditorVC.view.frame = self.reditorContainerView.bounds
            reditorContainerView.addSubview(reditorVC.view)
    
            /** Appearance */
            UIView.animate(withDuration: 0.33) {
                self.reditorContainerView.alpha = 1.0
            }
        }else{
            print("Ooops!\nSomething went wrong")
        }
    }


    func reditorDidFinishedDrawing(image: UIImage) {
        UIView.animate(withDuration: 0.33, animations: {
            self.reditorContainerView.alpha = 0.0
        }, completion: { _ in
            for subview in self.reditorContainerView.subviews {
                subview.removeFromSuperview()
            }
        })
    }

    func reditorDidCanceledDrawing() {
        UIView.animate(withDuration: 0.33, animations: {
            self.reditorContainerView.alpha = 0.0
        }, completion: { _ in
            for subview in self.reditorContainerView.subviews {
                subview.removeFromSuperview()
            }
        })
    }

}
```
