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
    var keyboardTouchView : KeyboardTouchView
    
    @IBOutlet var pinkView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.keyboardTouchView = KeyboardTouchView(frame: CGRectZero)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.view.addSubview(self.keyboardTouchView)
        var key = SingleGlyphView(frame: CGRect(x: 100, y: 100, width: 50, height: 50), glyph: "A")
//        self.view.addSubview(key)
        self.keyboardTouchView.addSubview(key)
        
        var testView = SingleGlyphView(frame: CGRect(origin: CGPoint(x: 200, y: 200), size: CGSize(width: 100, height: 100)))
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
    
//    var activeMenuView = MenuView(frame: CGRectZero)
//    
//    func addMenuView(point: CGPoint, glyph: String) {
//        activeMenuView = MenuView(frame: CGRect(origin: point, size: CGSizeZero), glyphs: ["A", "B", "C"])
//    }
}


extension UIColor {
    class func random() -> UIColor! {
        let hue : CGFloat = CGFloat( Float(Int(rand()) % 256) / 256.0 );  //  0.0 to 1.0
        let saturation : CGFloat = CGFloat( Float(Int(rand()) % 128) / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        let brightness : CGFloat = CGFloat( Float(Int(rand()) % 128) / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
}
