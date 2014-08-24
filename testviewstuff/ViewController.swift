//
//  ViewController.swift
//  testviewstuff
//
//  Created by Stewart Jackson on 2014-08-21.
//  Copyright (c) 2014 Stewart Jackson. All rights reserved.
//

import UIKit
let menuFrameHeight: CGFloat = 50

class ViewController: UIViewController {
    
//    var menuView = PeripheralMenuGlyphFrame(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    @IBOutlet var pinkView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var label = UILabel(frame: CGRect(x: 0, y: 200, width: 100, height: 100))
        label.text = "A"
        label.highlightedTextColor = UIColor.lightTextColor()
        label.backgroundColor = UIColor.blueColor()
        label.numberOfLines = 1
        label.font = UIFont(name: label.font.fontName, size: 30)
//        label.highlighted = true
        label.textAlignment = .Center
        label.adjustsFontSizeToFitWidth = true
//        label.sizeToFit()
//        self.view.addSubview(label)
        
        var key = SingleGlyphView(frame: CGRect(x: 0, y: 300, width: 50, height: 50), glyph: "A")
        self.view.addSubview(key)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func menuForGlyph(frame: CGRect) -> UIView {
        println(" frameForBoundingBox \(CGRect(x: (frame.origin.x), y: frame.origin.y - menuFrameHeight, width: frame.width, height: frame.height + menuFrameHeight))")
        let frameForBoundingBox = CGRect(x: frame.origin.x, y: frame.origin.y - menuFrameHeight, width: frame.width, height: frame.height + menuFrameHeight)
        var peripheralMenuFrame = PeripheralMenuFrame(frame: frameForBoundingBox, peripherals: ["A", "B", "C"])
        return peripheralMenuFrame
    }

//    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
//        println("touchesBegan")
//        for touch in touches {
//            //TODO: ENUM
//            if let touch = touch as? UITouch {
//                for subview in self.view.subviews {
////                    if let subview = subview as? HighlightView {
////                        if subview.pointInside(touch.locationInView(subview), withEvent: event) {
////                            subview.shouldHighlight()
////                        } else {
////                            subview.shouldNotHighlight()
////                        }
////                    }
//                if let subview = subview as? SingleGlyphView {
//                        if subview.pointInside(touch.locationInView(subview), withEvent: event) {
//                            println("SingleGlyphView frame \(subview.frame)")
//                            self.view.addSubview(menuForGlyph(subview.frame))
//                            println("touched in sgv")
//                        }
//                    }
//                }
//
//            }
//        }
//    }
//
//    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
//        for touch in touches {
//            if let touch = touch as? UITouch {
//                for subview in self.view.subviews {
//                    if let subview = subview as? PeripheralMenuFrame {
//                        if !subview.pointInside(touch.locationInView(subview), withEvent: event) {
//                            subview.removeFromSuperview()
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
//        for touch in touches {
//            if let touch = touch as? UITouch {
//                for subview in self.view.subviews {
////                    if let subview = subview as? HighlightView {
////                        subview.shouldNotHighlight()
////                    }
//                    if let subview = subview as? UILabel {
//                        subview.highlighted = false
//                    } else if let subview = subview as? PeripheralMenuFrame {
//                        subview.removeFromSuperview()
//                    }
//                }
//            }
//        }
//    }
}

//class HighlightView : UIView {
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        println("frame: \(frame)")
//    }
//    required init(coder aDecoder: NSCoder!) {
//        fatalError("NO NSCODER")
//    }
//    
//    func shouldHighlight() {
//        println("shouldHighlight")
//        if self.subviews.isEmpty {
//            var overlayView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
//            overlayView.backgroundColor = UIColor.yellowColor()
//            overlayView.alpha = 0.5
//            self.addSubview(overlayView)
//        }
//    }
//    
//    func shouldNotHighlight() {
//        if self.subviews != nil {
//            for subview in self.subviews {
//                subview.removeFromSuperview()
//            }
//        }
//    }
//}

//the view that holds all peripheralmenuglyphframes' for layout purposes
class PeripheralMenuFrame : UIView {
    
    var peripheralsInView = [PeripheralMenuGlyphFrame]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, glyph: String) {
        self.init(frame: frame)
        var peripheralMenuGlyphFrame = PeripheralMenuGlyphFrame(frame: frame, glyph: glyph, isFirst: false)
        peripheralsInView.append(peripheralMenuGlyphFrame)
        self.addSubview(peripheralMenuGlyphFrame)
        
        println(self.frame.size)
        self.sizeToFit()
        println(self.frame.size)
    }
    
    convenience init(frame: CGRect, peripherals: [String]) {
        self.init(frame: frame)
        
        //TODO far right check for left or right addition plus a space calculator for total width and spacing requirements (closest to closest wall)
        //TODO padding
        var firstFlag = true
        var deltaX: CGFloat = 0
        for glyph in peripherals {
            println("frame width: \(frame.width)")
            var peripheralMenuGlyphFrame = PeripheralMenuGlyphFrame(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), glyph: glyph, isFirst: firstFlag)
            peripheralMenuGlyphFrame.setTranslatesAutoresizingMaskIntoConstraints(false)
//            peripheralMenuGlyphFrame.autoresizesSubviews = false
//            deltaX += frame.width
//            println("delta x \(deltaX)")
            firstFlag = false
            peripheralsInView.append(peripheralMenuGlyphFrame)
            self.addSubview(peripheralMenuGlyphFrame)
        }
        
        for var index = 0; index < peripheralsInView.count; ++index {
            
            self.addConstraint(NSLayoutConstraint(item: peripheralsInView[index], attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
            
            if index == 0 {
            self.addConstraint(NSLayoutConstraint(item: peripheralsInView[index], attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.LeftMargin, multiplier: 1, constant: 0))
            }
            if index > 0 {
                var multiplier: CGFloat = CGFloat(2 * index + 2) / CGFloat(peripheralsInView.count + 1)
//            var multiplier: CGFloat = 1

            self.addConstraint(NSLayoutConstraint(item: peripheralsInView[index], attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: peripheralsInView[index-1], attribute: NSLayoutAttribute.Right, multiplier: multiplier, constant: 0))
//            self.addConstraint(NSLayoutConstraint(item: peripheralsInView[index], attribute: <#NSLayoutAttribute#>, relatedBy: <#NSLayoutRelation#>, toItem: <#AnyObject!#>, attribute: <#NSLayoutAttribute#>, multiplier: <#CGFloat#>, constant: <#CGFloat#>))
//        self.addConstraint(NSLayoutConstraint(item: peripheralsInView[1], attribute: NSLayoutConstraint.)
            }
        }
        self.sizeToFit()

    }
    
    required init(coder aDecoder: NSCoder!) {
        fatalError("NO NSCODER")
    }
    
    override func sizeToFit() {
        var sizingFrame = CGSize()
        for peripheral in peripheralsInView {
            sizingFrame.width += peripheral.frame.width
            //TODO fix for multiple rows
            sizingFrame.height = max(sizingFrame.height, peripheral.frame.height)
        }
        
        println("PeripheralMenuFrame origin \(self.frame.origin)")
        
        self.frame.size = sizingFrame
    }
    
    func rowLayoutConstraints(arrayOfSubviews: [UIView], framePadding: Int, viewPadding: Int) -> String {
        var formatString = ""
        for var index = 0; index < arrayOfSubviews.count; ++index {
            if index == 0 {
//                formatString += String("|-%d-[%@]",framePadding.description, "")
            }
        }
        return ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        var deltaX: CGFloat = 0
////        var origin = CGPoint()
//        println("count \(peripheralsInView.count)")
//        for peripheral in peripheralsInView {
//            println("peripheral.frame.origin.x \(peripheral.frame.origin.x)")
//            peripheral.frame.origin.x += deltaX
//            deltaX += 50
//            println("delta x \(deltaX) peripheral.frame.origin.x \(peripheral.frame.origin.x)")
//            deltaX += peripheral.frame.width //TODO padding!
//        }
        println("after size \(self.frame.size)")

    }
}

// this is just a basic UIView but it has special interaction properties. These can be handled in the VC
class PeripheralMenuGlyphFrame : UIControl {
    var peripheralMenuGlyph = PeripheralMenuGlyph(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, glyph: String, backgroundColour: UIColor) { // can also be image - change later
        self.init(frame: frame)
    }
    
    convenience init(frame: CGRect, glyph: String, isFirst: Bool) {
        
        self.init(frame: frame)
        
        
        var frameForPeripheral = CGRect(x: 0, y: 0, width: frame.width, height: menuFrameHeight)
        
        self.peripheralMenuGlyph = PeripheralMenuGlyph(frame: frameForPeripheral, glyph: glyph, highlight: false)
//        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.random()
        self.addSubview(peripheralMenuGlyph)
        self.addTarget(self, action: Selector("highlight:event:"), forControlEvents: UIControlEvents.TouchDragEnter)
    }
    
    func highlight(control: UIControl, event: UIEvent) {
        println("touchdown")
    }
    
    required init(coder aDecoder: NSCoder!) {
        fatalError("NO NSCODER")
    }
}

class PeripheralMenuGlyph : UIControl {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, glyph: String, highlight: Bool) {
        println("frame: \(frame)")
        self.init(frame: frame)
        var label = UILabel(frame: frame)
        label.text = glyph
        label.highlighted = false
//        label.backgroundColor = UIColor.grayColor()
//        self.addTarget(self, action: Selector("touchDown:event:"), forControlEvents: UIControlEvents.TouchDown)
        self.addSubview(label)
    }
    
    func touchDown(control: UIControl, event: UIEvent) {
        println("touchdown")
    }
    
    required init(coder aDecoder: NSCoder!) {
        fatalError("NO NSCODER")
    }
    
    func shouldHighlight() {
        NSLog("PeripheralMenuGlyph shouldHighlight %@")
    }
    
    func shouldNotHighlight() {
        NSLog("PeripheralMenuGlyph shouldNotHighlight %@")
    }
    
    func calloutClicked() {
        NSLog("PeripheralMenuGlyph calloutClicked %@")
    }
    
    func hideBackground() {
    }
    
    func showBackground() {
    }
}

//this is the normal, plain-jane key
//SingleGlyphView is a UIView that contains a UILabel.
class SingleGlyphView: UIControl {
    var glyph : String = ""
    var imageView = UIImageView()
    var glyphLabel = UILabel()
    
    required init(coder aDecoder: NSCoder!) {
        fatalError("NSCoding not supported")
    }
    
    convenience init(frame aRect: CGRect, glyph: String, hPadding: CGFloat, vPadding: CGFloat) {
        self.init(frame: aRect)
        // now do things with padding characters if required
    }
    
    convenience init(frame aRect: CGRect, glyph: String) {
        self.init(frame: aRect)
        self.glyph = glyph
        self.autoresizesSubviews = true
        //        self.userInteractionEnabled = false
        
        //glyph label
        glyphLabel.text = glyph
        glyphLabel.font = UIFont(name: glyphLabel.font.fontName, size: 30)
        glyphLabel.sizeToFit()
        glyphLabel.textAlignment = .Center
        glyphLabel.adjustsFontSizeToFitWidth = true
        glyphLabel.backgroundColor = UIColor.blueColor()
        self.addSubview(glyphLabel)
        
        //background image
        imageView = UIImageView(frame: aRect)
        imageView.image = UIImage(named: "key.png")
        self.addSubview(imageView)
        self.sendSubviewToBack(imageView)
        
        self.addTarget(self, action: Selector("touchDown:event:"), forControlEvents: UIControlEvents.TouchDown)
        self.addTarget(self, action: Selector("touchUp:event:"), forControlEvents: UIControlEvents.TouchUpInside | .TouchDragOutside)
        self.addTarget(self, action: Selector("touchMoved:event:"), forControlEvents: UIControlEvents.TouchDragInside)
        
    }
    
    func touchMoved(control: UIControl, event: UIEvent) {
        println("touchMoved")
    }
    
    func touchDown(control: UIControl, event: UIEvent) {
        println("touchDown")
        self.addSubview(menuForGlyph(self.frame))
    }
    
    func touchUp(control: UIControl, event: UIEvent) {
        for subview in self.subviews {
            if let subview = subview as? PeripheralMenuFrame {
                subview.removeFromSuperview()
            }
        }
    }
    
    func menuForGlyph(frame: CGRect) -> UIView {
        println(" frameForBoundingBox \(CGRect(x: (frame.origin.x), y: frame.origin.y - menuFrameHeight, width: frame.width, height: frame.height + menuFrameHeight))")
        let frameForBoundingBox = CGRect(x: 0, y: 0 - menuFrameHeight, width: frame.width, height: frame.height + menuFrameHeight)
        var peripheralMenuFrame = PeripheralMenuFrame(frame: frameForBoundingBox, peripherals: ["A", "B", "C"])
        return peripheralMenuFrame
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
    }
    
    override func layoutSubviews() {
        for view in self.subviews {
            if let view = view as? UIView {
                view.frame.size = self.frame.size
            }
            if let view = view as? UILabel {
                
            }
        }
    }
    
    func shouldHighlight() {
        NSLog("SingleGlyphView shouldHighlight %@", self.glyph)
    }
    
    func shouldNotHighlight() {
        NSLog("SingleGlyphView shouldNotHighlight %@", self.glyph)
    }
    
    func calloutClicked() {
        NSLog("SingleGlyphView calloutClicked %@", self.glyph)
    }
    
    func hideBackground() {
        imageView.alpha = 0
    }
    
    func showBackground() {
        imageView.alpha = 1
    }
}

extension CGRect {
    
    var bottomLeft: CGPoint {
        get {
            return CGPoint(x: self.origin.x, y: self.origin.y + self.height)
        }
    }
    
    var bottomRight: CGPoint {
        get {
            return CGPoint(x: self.origin.x + self.width, y: self.origin.y + self.height)
        }
    }
    
    var topRight:CGPoint {
        get {
            return CGPoint(x: self.origin.x + self.width, y: self.origin.y)
        }
    }
}

extension UIColor {
    class func random() -> UIColor! {
        println("random \(Int(rand())) \(Float(Int(rand()) % 256) / 256.0)")
        let hue : CGFloat = CGFloat( Float(Int(rand()) % 256) / 256.0 );  //  0.0 to 1.0
        let saturation : CGFloat = CGFloat( Float(Int(rand()) % 128) / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        let brightness : CGFloat = CGFloat( Float(Int(rand()) % 128) / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        println("\(hue) \(saturation) \(brightness)")
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
}
