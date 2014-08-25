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


class KeyboardTouchView: UIView {
    
    var activeTouches = [UITouch: TouchEvent]()
    var longTouchTimer = NSTimer()
    var longPressed = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentMode = UIViewContentMode.Redraw
        self.multipleTouchEnabled = true
        self.userInteractionEnabled = true
        self.opaque = false
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
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
    
    func longPress() {
        println("longPress")
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        
        // this will find the first-touch view and prep it for highlighting. 
        //TODO: make this handle multitouch situations appropriately (long press menu on multiple keys?)
        
        //this is touch stuff for keyviews
        for touch in touches {
            if let touch = touch as? UITouch {
                var view = findNearestView(touch.locationInView(self))
                self.handleControl(view, controlEvent: .TouchDown) //This will highlight the view
                println("touchesBegan")
                    longTouchTimer.invalidate()
                    // setup for firing a long touch trigger
                    longTouchTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("longPress"), userInfo: nil, repeats: false)
                
                // this is the touch handling for the disambiguator
                activeTouches[touch] = TouchEvent(touch: touch, activeView: view!) //TODO unwrap properly or fix implementation
                
                //if the state is longPressed, we want to cancel the long press here
                
            }
        }
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
        
        // this is the touch handling for the disambiguator
        for touch in touches {
            if let touch = touch as? UITouch {
                
                let touchEvent = activeTouches[touch]!
                touchEvent.add(touch)
                
                //this is touch stuff for keyviews
                var view = findNearestView(touch.locationInView(self))
                
                if view != touchEvent.activeView {
                    //reset the timer with the new view
                    //TODO pass views
                    if longTouchTimer.valid {
                        longTouchTimer.invalidate()
                    }
                    longTouchTimer = longPressed ? NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("longPress"), userInfo: nil, repeats: false) : NSTimer() //empty nstimer

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
        
        if longTouchTimer.valid {
            longTouchTimer.invalidate()
        }
        // this is the touch handling for the disambiguator
        for touch in touches {
            if let touch = touch as? UITouch {
                
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
//
//        NSLog("Called handleTapEvent A x %f y %f", point.x, point.y)
//        
//        var bounds = keyboardView.bounds
//        NSLog("Called handleTapEvent B origin: %f", bounds.origin.x)
//        
//        let normalizedX : Double = (Double(point.x)  - Double(bounds.origin.x)) / Double(bounds.size.width)
//        let normalizedY : Double = (Double(point.y)  - Double(bounds.origin.y)) / Double(bounds.size.height)
//        NSLog("Called handleTapGesture C ")
//        switch mode {
//        case .Mode1d:
//            receiver?.keyboardReceivedTap(atLocation: normalizedX)
//        case .Mode2d:
//            receiver?.keyboardReceivedTap(atLocation: (normalizedX, normalizedY))
//        }
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
}
