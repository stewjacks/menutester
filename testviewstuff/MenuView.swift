//
//  MenuView.swift
//  testviewstuff
//
//  Created by Stewart Jackson on 2014-08-25.
//  Copyright (c) 2014 Stewart Jackson. All rights reserved.
//

import Foundation
import UiKit

let glyphLabelHeight:CGFloat = 30
// this is just a basic UIView but it has special interaction properties. These can be handled in the VC

//I am a transparent view that contains a label at MY origin that spans my width as a subview.
class PeripheralMenuGlyphFrame : UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.drawRect(CGRectZero)
        self.userInteractionEnabled = true
        self.backgroundColor = UIColor.random()
        self.textAlignment = .Center
        self.textColor = UIColor.purpleColor()
        self.adjustsFontSizeToFitWidth = true
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {}
    
    override var highlighted: Bool {
        didSet {
            self.backgroundColor = highlighted ? UIColor.brownColor() : UIColor.blackColor()
        }
    }
    
    required init(coder aDecoder: NSCoder!) {
        fatalError("NO NSCODER")
    }
    
    func inspectView() {
//        println(self)
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
//        point = convertPoint(point, fromCoordinateSpace: UICoordinateSpace)
//        println("convert: \(self.frame) \(point))")
        return CGRectContainsPoint(self.frame, point)
//        return self.hitTest(point, withEvent: nil)!.isDescendantOfView(self)
//        println("POINT: \(point) FRAME: \(self.frame)")
        return super.pointInside(point, withEvent: event)

//        if super.pointInside(point, withEvent: event){
//            return true
//        }
//        return CGRectContainsPoint(self.frame, point)
    }
}


class MenuView: UIView {
    
    let GLYPH_WIDTH:CGFloat = 50
    let GLYPH_HEIGHT:CGFloat = 50
    
    var glyphs = [String]()
    var peripheralsInView = [PeripheralMenuGlyphFrame]()

    override func drawRect(rect: CGRect) {}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder!) {
        fatalError("does not conform to NSCoder")
    }
    
    convenience init(frame: CGRect, glyphs: [String]) {
        self.init(frame: frame)
        self.glyphs = glyphs
        createGlyphSubviews()
        self.frame = frameFromKeyFrame(frame)
        layoutSubviews()

    }
    
    convenience init(frame: CGRect, glyph: String) {
        self.init(frame: frame)
        self.glyphs.append(glyph)
        createGlyphSubviews()
        self.frame = frameFromKeyFrame(frame)
        layoutSubviews()
    }
    
    func createGlyphSubviews() {
        
        for glyph in glyphs {
            var peripheralMenuGlyphFrame = PeripheralMenuGlyphFrame(frame: CGRectZero)
            peripheralMenuGlyphFrame.text = glyph
            peripheralsInView.append(peripheralMenuGlyphFrame)
//            println("preripheral frame: \(convertPoint(peripheralMenuGlyphFrame.frame.origin, toView: self))")
            self.addSubview(peripheralMenuGlyphFrame)
        }
    }
    
    func frameFromKeyFrame(frame: CGRect) -> CGRect {
        var rect = CGRect(x: frame.origin.x, y: frame.origin.y - GLYPH_HEIGHT, width: GLYPH_WIDTH * CGFloat(peripheralsInView.count), height: frame.height + GLYPH_HEIGHT)
//        println("frameFromKeyFrame\(rect)")
        return rect
    }
    
    override func layoutSubviews() {
        var deltaX: CGFloat = 0
        for subview in peripheralsInView {
            subview.frame = CGRect(x: deltaX, y: 0, width: GLYPH_WIDTH, height: self.frame.height)
            deltaX += GLYPH_WIDTH //+padding
        }
    }
    
    func handleTouch(point: CGPoint) {
        
        println("handle touch with point \(point)")
        for view in peripheralsInView {
            var inBounds = CGRectContainsPoint(view.frame, point)
            
            var temp = hitTest(point, withEvent: nil)
            view.highlighted = view.pointInside(point, withEvent: nil) ? true : false
            view.inspectView()
        }
    }
    
//    override func sizeToFit() {
//        var sizingFrame = CGSize()
//        for peripheral in peripheralsInView {
//            sizingFrame.width += peripheral.frame.width
//            println("sizing frame width \(sizingFrame.width)")
//            
//            //TODO fix for multiple rows
//            sizingFrame.height = max(sizingFrame.height, peripheral.frame.height)
//        }
//        self.frame.size = sizingFrame
//    }
}

