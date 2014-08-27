//
//  KeyView.swift
//  testviewstuff
//
//  Created by Stewart Jackson on 2014-08-25.
//  Copyright (c) 2014 Stewart Jackson. All rights reserved.
//

import Foundation
import UIKit

//this is the normal, plain-jane key
//SingleGlyphView is a UIView that contains a UILabel.
class SingleGlyphView: UIControl {

    var glyph : String = ""
    var imageView = UIImageView()
    var glyphLabel = UILabel()
    var hasPeripheralMenu = true
    
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
        glyphLabel.backgroundColor = highlighted ? UIColor.greenColor() : UIColor.blueColor()
        }
        
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
