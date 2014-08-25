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
    var keyboardTouchView: KeyboardTouchView
    
    @IBOutlet var pinkView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//        self.keyboard = defaultKeyboard()
        self.keyboardTouchView = KeyboardTouchView(frame: CGRectZero)
//        self.layout = KeyboardLayout(model: self.keyboard, superview: self.forwardingView)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.view.addSubview(self.keyboardTouchView)
        var key = SingleGlyphView(frame: CGRect(x: 100, y: 100, width: 50, height: 50), glyph: "A")
//        self.view.addSubview(key)
        self.keyboardTouchView.addSubview(key)
        
        var testView = UIView(frame: CGRect(origin: CGPoint(x: 200, y: 200), size: CGSize(width: 100, height: 100)))
        testView.backgroundColor = UIColor.whiteColor()
        self.keyboardTouchView.addSubview(testView)
        self.keyboardTouchView.backgroundColor = UIColor.clearColor()
        
        self.view.backgroundColor = UIColor.grayColor()
    }
    
    convenience required init(coder: NSCoder) {
        self.init(nibName: nil, bundle: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.keyboardTouchView.frame = self.view.bounds
    }

}

//the view that holds all peripheralmenuglyphframes' for layout purposes
class PeripheralMenuFrame : UIView {
    
    var peripheralsInView = [PeripheralMenuGlyphFrame]()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
//    override func drawRect(rect: CGRect) {}

    convenience init(frame: CGRect, glyph: String) {
        self.init(frame: frame)
        var peripheralMenuGlyphFrame = PeripheralMenuGlyphFrame(frame: frame, glyph: glyph, isFirst: false)
        peripheralsInView.append(peripheralMenuGlyphFrame)
        self.addSubview(peripheralMenuGlyphFrame)
    }
    
    convenience init(frame: CGRect, peripherals: [String]) {
        self.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        println("new PeripheralMenuFrame with frame \(frame)")

        //TODO far right check for left or right addition plus a space calculator for total width and spacing requirements (closest to closest wall)
        //TODO padding
        var firstFlag = true
        var deltaX: CGFloat = 0
        for glyph in peripherals {
            println("frame width: \(frame.width)")
            var peripheralMenuGlyphFrame = PeripheralMenuGlyphFrame(frame: CGRect(x: deltaX, y: 0, width: frame.width, height: frame.height), glyph: glyph, isFirst: firstFlag)
            deltaX += frame.width
            firstFlag = false
            peripheralsInView.append(peripheralMenuGlyphFrame)
            self.addSubview(peripheralMenuGlyphFrame)
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
            println("sizing frame width \(sizingFrame.width)")

            //TODO fix for multiple rows
            sizingFrame.height = max(sizingFrame.height, peripheral.frame.height)
        }
        self.frame.size = sizingFrame
    }
}

// this is just a basic UIView but it has special interaction properties. These can be handled in the VC
class PeripheralMenuGlyphFrame : UIControl {
    var peripheralMenuGlyph = PeripheralMenuGlyph(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
//    override func drawRect(rect: CGRect) {}

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        return self
    }
    
    convenience init(frame: CGRect, glyph: String, backgroundColour: UIColor) { // can also be image - change later
        self.init(frame: frame)
    }
    
    convenience init(frame: CGRect, glyph: String, isFirst: Bool) {
        
        self.init(frame: frame)
        
        println("frame for peripheral \(CGRect(x: 0, y: 0, width: frame.width, height: menuFrameHeight))")
        var frameForPeripheral = CGRect(x: 0, y: 0, width: frame.width, height: menuFrameHeight)
        
        self.peripheralMenuGlyph = PeripheralMenuGlyph(frame: frameForPeripheral, glyph: glyph, highlight: false)
//        self.translatesAutoresizingMaskIntoConstraints = false
//        self.backgroundColor = UIColor.random()
        self.addSubview(peripheralMenuGlyph)
        self.addTarget(self, action: Selector("touchUp:event:"), forControlEvents: UIControlEvents.TouchUpInside | .TouchDragOutside)
        self.addTarget(self, action: Selector("touchMoved:event:"), forControlEvents: UIControlEvents.TouchDragInside)
        self.addTarget(self, action: Selector("highlight:event:"), forControlEvents: UIControlEvents.TouchDragEnter)
    }
    
    func touchMoved(control: UIControl, event: UIEvent) {
        println("touchMoved \(event.touchesForView(self))")
    }
    
    func touchDown(control: UIControl, event: UIEvent) {
        println("touchDown")
    }
    
    func touchUp(control: UIControl, event: UIEvent) {
        for subview in self.subviews {
            if let subview = subview as? PeripheralMenuFrame {
                subview.removeFromSuperview()
            }
        }
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
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
                println(point)
            return super.pointInside(point, withEvent: event)
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
    var menu: UIView?
    
    required init(coder aDecoder: NSCoder!) {
        fatalError("NSCoding not supported")
    }
    
    convenience init(frame aRect: CGRect, glyph: String, hPadding: CGFloat, vPadding: CGFloat) {
        self.init(frame: aRect)
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
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
        glyphLabel.userInteractionEnabled = false
        self.addSubview(glyphLabel)
        
        //background image
        imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: self.frame.size))
        imageView.image = UIImage(named: "key.png")
        imageView.userInteractionEnabled = false
        self.addSubview(imageView)
        self.sendSubviewToBack(imageView)
        let showOptions: UIControlEvents = .TouchDown | .TouchDragInside | .TouchDragEnter
        let hideOptions: UIControlEvents = .TouchUpInside | .TouchUpOutside | .TouchDragOutside
        self.addTarget(self, action: Selector("touchDown:event:"), forControlEvents: showOptions)
        self.addTarget(self, action: Selector("touchUp:event:"), forControlEvents: hideOptions)
//        self.addTarget(self, action: Selector("touchMoved:event:"), forControlEvents: UIControlEvents.TouchDragInside)
        
    }
    
    func touchMoved(control: UIControl, event: UIEvent) {
        println("touchMoved \(event.touchesForView(self))")
        println("single glyph frame \(self.frame)")
    }
    
    func touchDown(control: UIControl, event: UIEvent) {
        if self.menu == nil {
            self.menu = menuForGlyph(self.frame)
            self.addSubview(self.menu!)
        }
    }
    
    func touchUp(control: UIControl, event: UIEvent) {
        for subview in self.subviews {
            if let subview = subview as? PeripheralMenuFrame {
                subview.removeFromSuperview()
                self.menu = nil
            }
        }
    }
    
    func menuForGlyph(frame: CGRect) -> UIView {
        println(" frameForBoundingBox \(CGRect(x: (frame.origin.x), y: frame.origin.y - menuFrameHeight, width: frame.width, height: frame.height + menuFrameHeight))")
        let frameForBoundingBox = CGRect(x: 0, y: 0 - menuFrameHeight, width: frame.width, height: frame.height + menuFrameHeight)
        var peripheralMenuFrame = PeripheralMenuFrame(frame: frameForBoundingBox, peripherals: ["A", "B", "C"])
//        peripheralMenuFrame.backgroundColor = UIColor.blackColor()
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
    
    override var highlighted: Bool {
        didSet {
            shouldHighlight()
        }
    }
    
    func shouldHighlight() {
        NSLog("SingleGlyphView shouldHighlight %@ %@", self.glyph, highlighted.description)
        glyphLabel.backgroundColor = highlighted ? UIColor.greenColor() : UIColor.blueColor()
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
        let hue : CGFloat = CGFloat( Float(Int(rand()) % 256) / 256.0 );  //  0.0 to 1.0
        let saturation : CGFloat = CGFloat( Float(Int(rand()) % 128) / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        let brightness : CGFloat = CGFloat( Float(Int(rand()) % 128) / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
}
