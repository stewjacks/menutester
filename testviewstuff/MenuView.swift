//
//  MenuView.swift
//  Minuum
//
//  Created by Stewart Jackson on 2014-08-25.
//  Copyright (c) 2014 Stewart Jackson. All rights reserved.
//

import Foundation
import UiKit

let GLYPH_WIDTH:CGFloat = 50
let GLYPH_HEIGHT:CGFloat = 50
let GLYPH_FONT_SIZE: CGFloat = 30

//MARK: I am a transparent view that contains a label at my origin that spans my width as a subview. I am touchable in my transparent area, so to speak.
class PeripheralMenuGlyphFrame : UIControl {
    var peripheralLabel = UILabel(frame: CGRectZero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.drawRect(CGRectZero)
        self.userInteractionEnabled = true
        self.backgroundColor = UIColor.clearColor()
        self.setNeedsDisplay()
    }
    
    override var highlighted: Bool {
        didSet {
            //set the peripheralLabel stuff here if it's being highlighted
            self.backgroundColor = highlighted ? UIColor.brownColor() : UIColor.clearColor()
        }
    }
    
    required init(coder aDecoder: NSCoder!) {
        fatalError("NO NSCODER")
    }
    
    var glyphLabel: String = "" {
        didSet{
            peripheralLabel = UILabel(frame: CGRect(x: 0, y: 0, width: GLYPH_WIDTH, height: GLYPH_HEIGHT))
            peripheralLabel.text = self.glyphLabel
            peripheralLabel.textColor = UIColor.purpleColor()
            peripheralLabel.font = UIFont(name: peripheralLabel.font.familyName, size: GLYPH_FONT_SIZE)
            peripheralLabel.textAlignment = .Center
            peripheralLabel.adjustsFontSizeToFitWidth = true
            
            self.addSubview(peripheralLabel)
        }
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        //this is tender and caused a lot of grief. I check if the point in the superview's coordinate system is inside it's own frame. super.pointInside doesn't do this appropriately
        return CGRectContainsPoint(self.frame, point)
    }
}

// I am the overall container for the menu. I handle interaction with subviews and the superview. One day I might grow up to be a view controller.
class MenuView: UIView {
    
    var glyphs = [String]()
    var peripheralsInView = [PeripheralMenuGlyphFrame]()
    let keyFrame: CGRect
    var drawRight = true

    override func drawRect(rect: CGRect) {}
    
    override init(frame: CGRect) {
        keyFrame = frame
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder!) {
        fatalError("does not conform to NSCoder")
    }
    
    //This convenience is for drawing several peripherals at once on init (peripheral if there is no precise menu previously)
    convenience init(frame: CGRect, glyphs: [String], drawRight: Bool) {
        self.init(frame: frame)
        self.glyphs = glyphs
        self.drawRight = drawRight
        createGlyphSubviews()
        self.frame = frameFromKeyFrame(frame)
        layoutSubviews()
    }
    //This convenience is for drawing one peripheral on init (precise)
    convenience init(frame: CGRect, glyph: String, drawRight: Bool) {
        self.init(frame: frame)
        self.glyphs.append(glyph)
        self.drawRight = drawRight
        createGlyphSubviews()
        self.frame = frameFromKeyFrame(keyFrame)
//        layoutSubviews()
    }
    
    func updateCurrentMenu(glyphs: [String]) {
        for glyph in glyphs {
            self.glyphs.append(glyph)
        }
        createGlyphSubviews()
        self.frame = frameFromKeyFrame(keyFrame)
//        layoutSubviews()
    }
    
    func createGlyphSubviews() {
        for glyph in glyphs {
            if !containsGlyphInView(glyph) {
                var peripheralMenuGlyphFrame = PeripheralMenuGlyphFrame(frame: CGRectZero)
                peripheralsInView.append(peripheralMenuGlyphFrame)
                peripheralMenuGlyphFrame.glyphLabel = glyph
                self.addSubview(peripheralMenuGlyphFrame)
            }
        }
    }
    
    func frameFromKeyFrame(frame: CGRect) -> CGRect {
        let width = GLYPH_WIDTH * CGFloat(peripheralsInView.count)
        let height = frame.height + GLYPH_HEIGHT
        
        if drawRight {
            return CGRect(x: frame.origin.x, y: frame.origin.y - GLYPH_HEIGHT, width: width, height: height)
        }
        return CGRect(x: frame.origin.x - width + GLYPH_WIDTH, y: frame.origin.y - GLYPH_HEIGHT, width: width, height: height)
    }
    
    //This positions the glyphs in the superview and is automatically called when the frame is changed
    override func layoutSubviews() {
        var deltaX: CGFloat = 0
        if drawRight {
            for subview in peripheralsInView {
                subview.frame = CGRect(x: deltaX, y: 0, width: GLYPH_WIDTH, height: self.frame.height)
                deltaX += GLYPH_WIDTH
            }
        } else {
            for (var i = peripheralsInView.count - 1; i >= 0;--i) {
                let subview = peripheralsInView[i]
                subview.frame = CGRect(x: deltaX, y: 0, width: GLYPH_WIDTH, height: self.frame.height)
                deltaX += GLYPH_WIDTH
            }
        }
        peripheralsInView.first?.highlighted = true //highlight the first glyph
    }
    
    //This receives and highlights the appropriate peripheral
    func touchHandler(point: CGPoint) {
        for view in peripheralsInView {
            view.highlighted = view.pointInside(point, withEvent: nil) ? true : false
        }
    }
    
    func peripheralAtPoint(point: CGPoint) -> String? {
        for view in peripheralsInView {
            if view.pointInside(point, withEvent: nil) {
                return view.glyphLabel
            }
        }
        return nil
    }
    
    func containsGlyphInView(glyph: String) -> Bool {
        for view in peripheralsInView {
            if view.glyphLabel == glyph {
                return true
            }
        }
        return false
    }
}

