//
//  KeyboardTouchView.swift
//  testviewstuff
//
//  Created by Stewart Jackson on 2014-08-24.
//  Copyright (c) 2014 Stewart Jackson. All rights reserved.
//  largely borrowed from Alexei Baboulevitch's TransliteratingKeyboard project

import UIKit

enum KeyboardTouchEventType : Printable {
    case Tap(CGPoint)
    case SwipeLeft
    case SwipeRight
    case NoEvent
    
    var description : String {
        get {
            switch self {
            case .Tap(let touch):
                return "tap \(touch)"
            case .SwipeLeft:
                return "swipeLeft"
            case .SwipeRight:
                return "swipeRight"
            case .NoEvent:
                return "noEvent"
            }
        }
    }
}

struct TouchPoint: Printable{
    var point: CGPoint
    var timeDelta: NSTimeInterval
    
    init(touch: UITouch){
        self.point = touch.locationInView(touch.view)
        self.timeDelta = touch.timestamp
    }
    
    var description: String {
        get {
            return "\(point), delta time: \(timeDelta)"
        }
    }
}

class TouchEvent {
    var points : [TouchPoint]
    let identifier: UITouch
    var activeView: UIView
    
    var count : Int{
        get {
            return points.count
        }
    }
    
    var first : TouchPoint {
        get {
            return points.first!
        }
    }
    
    var last : TouchPoint {
        get {
            return points.last!
        }
    }
    
    subscript(index: Int) -> TouchPoint {
        return points[index]
    }
    
    init(point: TouchPoint, identifier: UITouch, activeView: UIView) {
        self.points = [point]
        self.identifier = identifier
        self.activeView = activeView
    }
    
    init(touch: UITouch, activeView: UIView) {
        points = [TouchPoint(touch: touch)]
        identifier = touch
        self.activeView = activeView
    }
    
    func add(touch: UITouch) {
        points.append(TouchPoint(touch: touch))
    }
    
    func eventType(debug: Bool = false) -> KeyboardTouchEventType {
        if (self.count >= 2) {
            
            let deltaX = last.point.x - first.point.x
            let deltaY = last.point.y - first.point.y
            let deltaDistance = sqrt(deltaX * deltaX + deltaY * deltaY)
            
            let duration = last.timeDelta - first.timeDelta
            
            let xVelocity = Float(deltaX) / Float(duration)
            let yVelocity = Float(deltaY) / Float(duration)
            
            let velocity = Float(deltaDistance) / Float(duration)
            
            if debug {
                print(self)
                println("deltaX \(deltaX)\n deltaY: \(deltaY)")
                println("delta distance:", deltaDistance)
                println("duration", duration)
                println("xVelocity \(xVelocity)\n yVelocity: \(yVelocity)")
                println("total velocity:", velocity)
            }
            
            
            if _checkDiscriminant(fabs(xVelocity), displacement: Float(fabs(deltaX))) && fabs(deltaX) >= fabs(deltaY) {
                //                a swipe on the x axis && x displacement > y displacement
                if deltaX < 0 {
                    return .SwipeLeft
                }else {
                    return .SwipeRight
                }
                
            }else if _checkDiscriminant(fabs(yVelocity), displacement: Float(fabs(deltaY))) && fabs(deltaX) < fabs(deltaY) {
                //                TODO: we can handle vertical swipes here?
                return .NoEvent
            }else{
                return .Tap(last.point)
            }
        }
        return .NoEvent
    }
    
    // determines if an event falls within the arbitrary bounds we use to distinguish taps from swipes:
    private func _checkDiscriminant(
        speed:  Float,
        displacement: Float,
        threshholdVelocity:     Float = 1000,
        threshholdDisplacement: Float = 50) -> Bool {
            
            if (speed * threshholdDisplacement + threshholdVelocity * ( displacement - threshholdDisplacement ) > 0) {
                return true
            }
            return false
    }
}

extension TouchEvent: Printable {
    var description: String {
        get {
            var pointDescription = ""
            for point in self.points {
                pointDescription += "\(point)\n"
            }
            return "Touch event with \(self.count) touchPoints:\n \(pointDescription)"
        }
    }
}

extension TouchEvent: SequenceType {
    
    func generate() -> IndexingGenerator<Array<TouchPoint>> {
        return points.generate()
    }
}


class KeyboardTouchView: UIView, UIGestureRecognizerDelegate {
    
    var activeTouches = [UITouch: TouchEvent]()
    var preciseLongPressGestureRecognizer: UILongPressGestureRecognizer?
    var peripheralLongPressGestureRecognizer: UILongPressGestureRecognizer?
    var selectedView: UIView?
    
    var menuView: UIView?
    
    var peripheralLongPress:Bool = false {
        didSet {
            preciseLongPress = false
        }
    }
    var preciseLongPress: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentMode = UIViewContentMode.Redraw
        self.multipleTouchEnabled = true
        self.userInteractionEnabled = true
        self.opaque = false
        self.backgroundColor = UIColor.clearColor()
        
        //Gesture recognizers for two long touch states
        self.preciseLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("preciseLongPress:"))
        preciseLongPressGestureRecognizer?.minimumPressDuration = 0.2
        preciseLongPressGestureRecognizer?.delegate = self
        self.addGestureRecognizer(preciseLongPressGestureRecognizer!)
        
        self.peripheralLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("peripheralLongPress:"))
        peripheralLongPressGestureRecognizer?.minimumPressDuration = 0.5
        peripheralLongPressGestureRecognizer?.delegate = self
        self.addGestureRecognizer(peripheralLongPressGestureRecognizer!)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }
    
    //MARK: this is the long press gesture recognizer stuff for handling the display and navigation of menus
    func longPress(recognizer: UIGestureRecognizer) {
        println("longPress  \(recognizer.locationInView(recognizer.view))")
    }

    //MARK: PreciseLongPress State stuff
    func preciseLongPress(recognizer: UIGestureRecognizer) {
        let touchPoint: CGPoint = recognizer.locationInView(recognizer.view)
        var view = findNearestView(recognizer.locationInView(self))
        if view == nil {
            return
        }
        if peripheralLongPress {return}
        println("preciseLongPress")

        if let view = view as? UIControl {
            
            switch recognizer.state {
            case .Began:
                view.highlighted = false
                selectedView = view
                menuView = MenuView(frame: selectedView!.frame, glyph: "A")
//                showPreciseMenu(selectedView)
            case .Changed:
                if let menuView = menuView as? MenuView {
                    if menuView.pointInside(touchPoint, withEvent: nil) {
                    menuView.handleTouch(touchPoint)
                    }
                } else {
                    menuView?.removeFromSuperview()
                }
                
                if view != selectedView {
                    //Now we've moved into a different view so break out of this mode
//                    hidePreciseMenu(selectedView)
                    //TODO hide view!
                    break
                }
            case .Ended:
                if view == selectedView {
                    handleTapEvent(recognizer.locationInView(recognizer.view)) //send the tap event for this press
                }
//                hidePreciseMenu(selectedView)
            default:
//                hidePreciseMenu(selectedView)
                break
            }
        }
    }
    
    //MARK: PeripheralLongPress State stuff
    func peripheralLongPress(recognizer: UIGestureRecognizer) {
        let touchPoint: CGPoint = recognizer.locationInView(recognizer.view)
        var view = findNearestView(recognizer.locationInView(self))
        if view == nil {
            return
        }
        
        println("peripheralLongPress")

        self.peripheralLongPress = true

//        if let view = view as? UIControl {view.highlighted = false }
            switch recognizer.state {
            case .Began:
                selectedView = view
//                superview?.addSubview(MenuView(frame: view.frame, glyphs: ["A", "B", "C"]))
                menuView = MenuView(frame: selectedView!.frame, glyphs: ["D", "D", "D"])
                self.addSubview(menuView!)
            case .Ended:
                menuView?.removeFromSuperview()
                peripheralLongPress = false
            case .Changed:
                
                if let menuView = menuView as? MenuView {

                    let convertedPoint = convertPoint(touchPoint, toView: menuView)
                    if menuView.pointInside(convertedPoint, withEvent: nil) {
                        println("handle")
                        
                        menuView.handleTouch(convertedPoint)
                    }
                    else {
                        println("Remove")
                        menuView.removeFromSuperview()
                    }
                }
                
                
                println("views equal")
            default:
                println("peripheralLongPress default")
            }
//        }
    }
    
    // Why have this useless drawRect? Well, if we just set the backgroundColor to clearColor,
    // then some weird optimization happens on UIKit's side where tapping down on a transparent pixel will
    // not actually recognize the touch. Having a manual drawRect fixes this behavior, even though it doesn't
    // actually do anything.
    override func drawRect(rect: CGRect) {}
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent!) -> UIView! {
        return self
    }

    var activeView: UIView?
    
    // TODO: drag up control centre from bottom == stuck
    func handleControl(view: UIView?, controlEvent: UIControlEvents) {
        if view == nil {
            return
        }
        
        if !(view is UIControl) {
            return
        }
        
//        if let control = view as? PeripheralMenuGlyphFrame {
//            println("peripheral menu glyph frame")
//            // these are the special menu glyphs and should be checked for FIRST so we can skip lower keys
//        }
        
        let control = view! as UIControl
        
        switch controlEvent {
        case
        UIControlEvents.TouchDown,
        UIControlEvents.TouchDragEnter:
            control.highlighted = true
        case
        UIControlEvents.TouchDragExit,
        UIControlEvents.TouchUpInside,
        UIControlEvents.TouchUpOutside,
        UIControlEvents.TouchCancel:
            control.highlighted = false
        default:
            break
        }
        
        let targets = control.allTargets()
        if targets {
            for target in targets.allObjects { // TODO: Xcode crashes
                var actions = control.actionsForTarget(target, forControlEvent: controlEvent)
                if actions {
                    for action in actions {
                        let selector = Selector(action as String)
                        control.sendAction(selector, to: target, forEvent: nil)
                    }
                }
            }
        }
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        
        // this will find the first-touch view and prep it for highlighting.
        //this is touch stuff for keyviews
        for touch in touches {
            if let touch = touch as? UITouch {
                var view = findNearestView(touch.locationInView(self))
                
                self.handleControl(view, controlEvent: .TouchDown) //This will highlight the view
                
                // this is the touch handling for the disambiguator
                if let view = view? {
                activeTouches[touch] = TouchEvent(touch: touch, activeView: view) //TODO unwrap properly or fix implementation. This assumes there's a view
                } else {
                    fatalError("there is no view in superview")
                }
            }
        }
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {

        for touch in touches {
            if let touch = touch as? UITouch {
                
                //TODO: add flags for this instead of state
//                if keyboardTouchMenuState != .Normal {
//                    activeTouches.removeValueForKey(touch)
//                    return
//                }
            
                let touchEvent = activeTouches[touch]!
                touchEvent.add(touch)

                //this is touch stuff for keyviews
                var view = findNearestView(touch.locationInView(self))
                
                if view != touchEvent.activeView {
                    self.handleControl(touchEvent.activeView, controlEvent: .TouchUpOutside)
                    touchEvent.activeView = view!
                    self.handleControl(touchEvent.activeView, controlEvent: .TouchDown)
                }
                else {
                    self.handleControl(touchEvent.activeView, controlEvent: .TouchDragInside)
                }
            }
        }
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!)  {
        
        // this is the touch handling for the disambiguator
        for touch in touches {
            if let touch = touch as? UITouch {
                
                //TODO: add flags for this instead of state
                //                if keyboardTouchMenuState != .Normal {
                //                    activeTouches.removeValueForKey(touch)
                //                    return
                //                }
                
                var view = findNearestView(touch.locationInView(self))
                self.handleControl(view, controlEvent: .TouchUpInside)
                
                let touchEvent = activeTouches[touch]!
                touchEvent.add(touch)
                handleKeyboardTouchEvent(touchEvent.eventType())
                activeTouches.removeValueForKey(touch)

            }
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        self.handleControl(self.activeView, controlEvent: .TouchCancel)
        
        for touch in touches {
            if let touch = touch as? UITouch {
                activeTouches.removeValueForKey(touch)
            }
        }
    }
    
    //MARK: extracting events from touches
    func handleKeyboardTouchEvent(keyboardTouchEventType: KeyboardTouchEventType) {
        switch keyboardTouchEventType {
        case .Tap(let point):
            handleTapEvent(point)
        case .SwipeLeft:
            handleSwipeLeftEvent()
        case .SwipeRight:
            handleSwipeRightEvent()
        case .NoEvent:
            println("received noEvent")
        default:
            break
        }
    }
    
    func handleTapEvent(point: CGPoint) {
        NSLog("Called handleTapEvent")
    }
    
    func handleSwipeLeftEvent() {
        NSLog("Called handleSwipeLeftEvent")
//        receiver?.keyboardReceivedWordDelete()
    }
    
    func handleSwipeRightEvent() {
        NSLog("Called handleSwipeRightEvent")
//        receiver?.keyboardReceivedSpace()
    }
    
    //MARK: extracting subviews from touches
    // TODO: there's a bit of "stickiness" to Apple's implementation
    func findNearestView(position: CGPoint) -> UIView? {
        var closest: (UIView, CGFloat)? = nil
        
        for anyView in self.subviews {
            let view = anyView as UIView
            
            if view.hidden {
                continue
            }
            
            view.alpha = 1
            
            let distance = distanceBetween(view.frame, point: position)
            
            if closest != nil {
                if distance < closest!.1 {
                    closest = (view, distance)
                }
            }
            else {
                closest = (view, distance)
            }
        }
        
        if closest != nil {
            return closest!.0
        }
        else {
            return nil
        }
    }
    // http://stackoverflow.com/questions/3552108/finding-closest-object-to-cgpoint
    func distanceBetween(rect: CGRect, point: CGPoint) -> CGFloat {
        if CGRectContainsPoint(rect, point) {
            return 0
        }
        
        var closest = rect.origin
        
        if (rect.origin.x + rect.size.width < point.x) {
            closest.x += rect.size.width
        }
        else if (point.x > rect.origin.x) {
            closest.x = point.x
        }
        if (rect.origin.y + rect.size.height < point.y) {
            closest.y += rect.size.height
        }
        else if (point.y > rect.origin.y) {
            closest.y = point.y
        }
        
        let a = pow(Double(closest.y - point.y), 2)
        let b = pow(Double(closest.x - point.x), 2)
        return CGFloat(sqrt(a + b));
    }
    
    func addPreciseMenu(view: UIView) -> UIView {
        return MenuView(frame: CGRectZero)
    }
    
    func addPeripheralMenu(view: UIView) -> UIView? {
        if let view = view as? SingleGlyphView  {
            if view.hasPeripheralMenu {
                return MenuView(frame: CGRectZero)
            }
        }
        return nil
    }
}