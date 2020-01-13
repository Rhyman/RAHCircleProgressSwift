//
//  RAHCircleProgressIndicator.swift
//  RAHCircleProgressSwift
//
//  Created by Richard Hyman on 10/17/19.
//  Copyright © 2019 Richard Hyman. All rights reserved.
//

/*
    RAHCircleProgressIndicator is a progress indicator that 'whirls'
 in a circular motion. It can be configured as
 1.  an indeterminate indicator that gives no indication when a task
 will be completed, and continues until stopAnimation is called.
 2.  a determinate indicator that displays progress as a value
 inclusively between the startValue and endValue. The coder increments
 the current value by calling 'increment'.
 3.  a countdown indicator that counts down in 1 second increments
 from the starting value. A callback function can be defined that is called
 when 0 is reached.
 
    See viewController.swift for examples of using this class, and the
 available functions and vars.
 
    The following is a quick reference to public functions and variables
 available for this class. More in-depth descriptions are available below.
 
 
        init functions:
 
    standard init with the frame for the indicator.
public override init(frame: CGRect)
  
    init allows indeterminate to be set along with the frame.
public init(frame: CGRect, indeterminate: Bool)
  
    init used to create a countdown indicator.
public init(frame: CGRect, countDownFrom: CGFloat, finalCallback: @escaping () -> Void, hideOnCompletion: Bool = true)
 
 
        configuration functions and vars:
 
    get or set the indeterminate nature of this indicator
public var indeterminate: Bool?
 
    get or set the width of the line used to draw the
    indeterminate 'whirling' line or the determinate progress line
public var lineWidth: CGFloat?
 
    get or set the fill color for the indicator; i.e. background color
public var fillColor: UIColor?
 
    get or set boolean that determines if the indicator is hidden or
    displayed when the indicator stops.
public var displayWhenStopped: Bool?
 
 
        for indeterminate indicators:

    get or set the color of the beginning portion of the 'whirling' line.
public var headColor: UIColor?
 
    get or set the color of the tail end of the 'whirling' line.
public var tailColor: UIColor?
 
    get or set the color array of UIColor's representing the 'whirling' line.
    Use this in lieu of setting headColor & tailColor for more than 2 colors.
public var gradientArray: Array<UIColor>
 
 
        for determinate indicators:
 
    return current value of progress for determinate indicators
public var doubleValue: Double
 
    set or get the start value for deterministic indicator.
public var startValue: Double
 
    set or get the end value for deterministic indicator.
public var endValue: Double

    set or get the incremental value for a deterministic indicator.
public var increment: Double
 
    show the number representing progress based on the startValue & endValue.
public func display(progressNumber: Bool, withPercent: Bool, orUseLabel: String)
 
    set/get the font used in label for deterministic or countdown indicators
public var labelFont: UIFont

 */

import UIKit

public class RAHCircleProgressIndicator: UIView {

    private var controlWidth:           CGFloat = 40.0    //  height = width
    //     Taken from the width of the rect used to init this view
    //  used as characteristic length for all layer sizing/drawing
    //     Based on the width of the defined box containing this
    //  control; the height is ignored, and a square box is constructed.
    private var theFrame:           CGRect = CGRect(x: 0, y: 0, width: 40, height: 40)
    private var theLineWidth:       CGFloat = 5.0
    private var isIndeterminate:    Bool = true
    private var isCountdownTimer:   Bool = false
    private var countdownCallback:  (() -> Void)? = nil
    private var willDisplayWhenStopped: Bool = true
    
    //  layers used to build this view
    private var gradLayer:          CAGradientLayer?
    // covers gradient, showing visible spinner
    private var frontLayer:         CALayer?
    
    private var centerLabel:        UILabel?
    private var theLabelFont:          UIFont = UIFont.systemFont(ofSize: 14)
    
    //  colors
    private var theFillColor = UIColor.white.cgColor
    private let AppleBlue = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1).cgColor    //  Apple blue
    
    //  color array that creates the gradient
    private var theGradientArray: Array<AnyObject>?
    // init the head and tail colors of the indicator
    private var theHeadColor = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1).cgColor    //  Apple blue
    private var theTailColor = UIColor.white.cgColor
    
    //  current position of the indicator in 360 deg arc for animated, indeterminate
    private var currentArrowArcRadians: CGFloat = 0.0

    //      for determinate indicator
    //  start and end values, and increment for changing them
    private var theStartValue:          CGFloat = 0.0
    private var theEndValue:            CGFloat = 100.0
    private var theIncrement:           CGFloat = 0.0
    private var currentValue:  CGFloat = 0.0 //  startVal <= current <= endVal
    
    private var showProgressNumber:     Bool = false
    private var showNumberWithPercent:  Bool = false
    private var showLabel:              String = ""

    
    
    //      Public Faces
    
    //    public face of self.isIndeterminate
    //    get or set the indeterminate nature of this indicator
    //    An indeterminate indicator is a wait indicator that continually
    //  spins. A determinate indicator is one that shows progress based
    //  on the start and end values. Determinate indicators can show
    //  the value of progress using the public func 'display'
    //    default is indeterminate==true
    public var indeterminate: Bool? {
        get {
            return self.isIndeterminate
        }
        set(_indeterminate) {
            self.isIndeterminate = _indeterminate ?? false
            self.reset()
        }
    }
    
    //    public face of self.theLineWidth
    //    get or set the width of the line used to draw the
    //  indeterminate 'whirling' line or the determinate progress line
    //    default is 5 points
    public var lineWidth: CGFloat? {
        get {
            return self.theLineWidth
        }
        set(_lineWidth) {
            self.theLineWidth = _lineWidth ?? 5.0
        }
    }
    
    //    public face of self.theFillColor
    //    this func will get or set the fill color for the indicator
    //  It is essentially the background color. For indeterminate
    //  indicators that have a 'whirling' line that fades into the
    //  background, set the fillColor = tailColor
    //    tailColor is automatically set to the fillColor when this
    //  func is called. So, if a different tailColor is desired, set the
    //  tailColor after setting the fillColor
    //    The fillColor default is white
    public var fillColor: UIColor? {
        get {
            return UIColor(cgColor: self.theFillColor)
        }
        set(_fillColor) {
            self.theFillColor = _fillColor?.cgColor ?? UIColor.white.cgColor
            self.theTailColor = self.theFillColor
            self.reset()
        }
    }
    
    //    public face of self.theHeadColor
    //    for indeterminate indicators, get or set the color of the beginning
    //  portion of the 'whirling' line. This color will blend into the
    //  tailColor.
    //    The default color is Apple blue.
    public var headColor: UIColor? {
        get {
            return UIColor(cgColor: self.theHeadColor)
        }
        set(_headColor) {
            self.theHeadColor = _headColor?.cgColor ?? self.AppleBlue
            let gradientCount = self.theGradientArray?.count ?? 0
            self.theGradientArray![gradientCount-1] = self.theHeadColor
            self.reset()
        }
    }
    
    //    public face of self.theTailColor
    //    for indeterminate indicators, get or set the color of the tail end
    //  of the 'whirling' line. This color blends into the headColor.
    //    Set this color after setting the fillColor.
    //    The default for theTailColor is white
    public var tailColor: UIColor? {
        get {
            return UIColor(cgColor: self.theTailColor)
        }
        set(_tailColor) {
            self.theTailColor = _tailColor?.cgColor ?? UIColor.white.cgColor
            self.theGradientArray![0] = self.theTailColor
            self.reset()
        }
    }
    
    //    public face of self.theGradientArray
    //    get or set the color array of UIColor's representing the
    //  'whirling' line. Use this in lieu of the headColor and tailColor
    //  functions, when you want more than 2 colors.
    //    The first color in the array should be the tailColor, while
    //  the last color in the array should be the headColor.
    public var gradientArray: Array<UIColor> {
        get {
            var theColorArray = [UIColor]()
            for aColor in self.theGradientArray! {
                theColorArray.append(aColor as! UIColor)
            }
            return theColorArray
        }
        set(gradientArray) {
            var newArray = [AnyObject]()
            //let inputArray: Array<UIColor> = gradientArray
            for aColor in gradientArray {
                newArray.append(aColor.cgColor as AnyObject)
            }
            self.theGradientArray = newArray
            self.reset()
        }
    }
    
    //    public face of self.willDisplayWhenStopped
    //    get or set the boolean that determines if the indicator
    //  is hidden or displayed when the indicator stops. For determinate
    //  and countdown timers, this value is used when stopAnimation
    //  or when the countdown timer completes.
    //    The default is true, so the indicator continues to be visible
    //  except...  the default for countdown timers is false; hide it when
    //  it reaches 0
    public var displayWhenStopped: Bool? {
        get {
            return self.willDisplayWhenStopped
        }
        set(_displayWhenStopped) {
            self.willDisplayWhenStopped = _displayWhenStopped ?? false
        }
    }
    
    
    //    public face of self.currentArrowArcRadians
    //    return current value of progress for determinate indicator
    public var doubleValue: Double {
        get {
            let currentDelta = self.currentValue
            return Double(currentDelta)
        }
    }
    
    //    public face of self.theMinValue
    //    set or get the start value for deterministic indicator.
    //  Most often, this will be the minimum value
    public var startValue: Double {
        get {
            return Double(self.theStartValue)
        }
        set(_startValue) {
            self.theStartValue = CGFloat(_startValue)
            if self.theStartValue < self.theEndValue {
                self.currentValue = CGFloat(self.theStartValue)
            }
        }
    }
    
    //    public face of self.theMaxValue
    //    set or get the end value for deterministic indicator.
    //  Most often, this will be the maximum value
    public var endValue: Double {
        get {
            return Double(self.theEndValue)
        }
        set(_endValue) {
            self.theEndValue = CGFloat(_endValue)
            if self.theStartValue >= self.theEndValue {
                self.currentValue = CGFloat(self.theEndValue)
            }
        }
    }
    
    //    public face of self.theIncrement
    //    set or get the incremental value for a deterministic indicator.
    //  Positive or negative, this value determines the next value that will
    //  be displayed. For example, if the startValue is set to 0 and the
    //  endValue is set to 50, the initial display of the deterministic
    //  indicator will be 0. Then call increment set to 10, and the
    //  indicator will display 10, call increment again set to 5, and the
    //  indicator will display 15.
    //    This increment is saved in the self.theIncrement property, so
    //  the previous increment can be fetched as a reference.
    public var increment: Double {
        get {
            return Double(self.theIncrement)
        }
        set(_increment) {
            self.theIncrement = CGFloat(_increment)
            self.currentValue = self.currentValue + self.theIncrement
            self.reset()
            self.showLabelText()
        }
    }
    
    //    public face of showProgressNumber and showNumberWithPercent
    //    for discriminate indicators, show the number representing progress
    //  based on the startValue and endValue.
    //    Show percent of progress with percent sign appended if
    //  withPercent==true.  Or show the number representing progress based
    //  on the startValue and endValue with 'orUseLabel' string appended.
    public func display(progressNumber: Bool, withPercent: Bool, orUseLabel: String) {
        self.showProgressNumber = progressNumber
        self.showNumberWithPercent = withPercent
        self.showLabel = orUseLabel
    }
    
    //    public face of self.theLabelFont
    //    set or get the font used in the label for deterministic or
    //  countdown indicators
    public var labelFont: UIFont {
        get {
            return self.theLabelFont
        }
        set(_labelFont) {
            self.theLabelFont = _labelFont
            self.reset()
        }
    }
    
    
    
    
    // MARK: __________ Init views and defaults
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupIn(theRect: self.frame)
    }
    
    //    standard init with the frame for the indicator. Unless
    //  overridden with the public var 'indeterminate', the indicator
    //  created will be indeterminate.
    //    The frame is set up as a square; both the height and width
    //  are taken from the width in the input frame
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.theFrame = frame
        self.setupIn(theRect: frame)
    }
    
    //    this init allows indeterminate to be set along with the frame.
    //    The frame is set up as a square; both the height and width
    //  are taken from the width in the input frame
    public init(frame: CGRect, indeterminate: Bool) {
        super.init(frame: frame)
        self.theFrame = frame
        self.isIndeterminate = indeterminate
        self.setupIn(theRect: frame)  //self.frame
    }
    
    //    this init is used to create a countdown indicator.
    //    frame is the frame that will contain the indicator
    //    countDownFrom is the staring value for the countdown indicator; it
    //  counts down to 0
    //    finalCallback can be set with a func that will be called when the
    //  countdown reaches 0;  if no callback funcion is needed, define
    //  finalCallBack as'{}', rather than using nil
    //    hideOnCompletion determines if the indicator is hidden or not when
    //  the coundown reaches 0.
    //    The frame is set up as a square; both the height and width
    //  are taken from the width in the input frame
    public init(frame: CGRect, countDownFrom: CGFloat, finalCallback: @escaping () -> Void, hideOnCompletion: Bool = true) {
        super.init(frame: frame)
        self.theFrame = frame
        self.isIndeterminate = false
        self.isCountdownTimer = true
        self.countdownCallback = finalCallback
        self.willDisplayWhenStopped = !hideOnCompletion
        self.setupCountdown(theRect: frame, startTime: countDownFrom)
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setupIn(theRect: self.frame)
    }
    
    
    private func reset() {
        //  create gradient layer for determinate or indeterminate indicator
        self.createGradientLayer()
        
        //    create the front layer that covers the gradient layer, and
        //  then creates 'holes' through which the gradient layer is seen
        //  in the shape of the spinning cursor
        self.createFrontLayer()
        
        self.createCenterLabel()
    }
    
    
    private func showLabelText() {
        if self.showProgressNumber && !self.isIndeterminate {
            self.centerLabel?.isHidden = false
            var theLabel = ""
            var theAmount: CGFloat = 0.0
            let extraLabel = self.showLabel.trimmingCharacters(in: CharacterSet.whitespaces)
            if !extraLabel.isEmpty {
                theLabel = self.showLabel
                theAmount = round(self.currentValue * 100.0)/100.0
                self.centerLabel!.text = "\(theAmount)" + theLabel
            } else {
                if self.showNumberWithPercent {
                    theLabel = "%"
                        //  round to the nearest percent
                    theAmount = self.currentValue / CGFloat(self.theEndValue - self.theStartValue) * 100.0
                    let theInt = Int(round(theAmount))
                    self.centerLabel!.text = "\(theInt)" + theLabel
                } else {
                    //  show an unlabeled number
                    let totalDelta = abs(self.theEndValue - self.theStartValue)
                    if self.theEndValue < self.theStartValue {
                        theAmount = totalDelta + self.currentValue
                    } else {
                        theAmount = self.currentValue
                    }
                    if self.isCountdownTimer {
                        let theInt = Int(round(theAmount))
                        self.centerLabel!.text = "\(theInt)" + theLabel
                    } else {
                        //  show 2 decimals
                        theAmount = round(theAmount * 100.0)/100.0
                        self.centerLabel!.text = "\(theAmount)" + theLabel
                    }
                }
            }
          }
    }
    
    
    private func setupIn(theRect: CGRect) {
        self.backgroundColor = UIColor.clear
        self.centerLabel?.isHidden = true  //  starting condition each update
        
        //  set up the gradient, so it isn't nil
        self.theGradientArray = [self.theTailColor as AnyObject, self.theHeadColor as AnyObject]

        //    we will set up the view as a square, even if user input a rect
        self.controlWidth = theRect.size.width
        self.theFrame = CGRect(x:theRect.origin.x , y:theRect.origin.y, width:self.controlWidth, height:self.controlWidth)
        self.frame = self.theFrame

        self.reset()
        self.showLabelText()
    }
    
    
    private func setupCountdown(theRect: CGRect, startTime: CGFloat) {
        self.backgroundColor = UIColor.clear
        self.centerLabel?.isHidden = false  //  starting condition each update
        
        //  set up the gradient, so it isn't nil
        self.theGradientArray = [self.theTailColor as AnyObject, self.theHeadColor as AnyObject]

        //    we will set up the view as a square, even if user input a rect
        self.controlWidth = theRect.size.width
        self.theFrame = CGRect(x:theRect.origin.x , y:theRect.origin.y, width:self.controlWidth, height:self.controlWidth)
        self.frame = self.theFrame
        
        self.theStartValue = startTime
        self.theEndValue = 0.0
        self.currentValue = CGFloat(self.theEndValue)
        self.display(progressNumber: true, withPercent: false, orUseLabel: "")

        self.reset()
    }
    
    
    //  keep height = width; view always be square based on init'ed width
    override public func updateConstraints() {
        super.updateConstraints()
        
        //  the rect is defined in the InterfaceBuilder
        //  make sure the height is equal to the width
        var heightConstraint: NSLayoutConstraint?
        for constraint: NSLayoutConstraint in self.constraints {
            if constraint.firstAttribute == .height {
                heightConstraint = constraint
                break
            }
        }
        if heightConstraint != nil {
            heightConstraint?.constant = self.frame.size.width
        }
    }
    
    
    
    // MARK: __________ Set up functions
    
    private func createGradientLayer() {
        self.gradLayer?.removeFromSuperlayer()

        // https://stackoverflow.com/questions/27931076/swift-gradient-along-a-bezier-path-using-calayers
        let theWidth: CGFloat = self.controlWidth
        var radius: CGFloat = self.controlWidth / 2.0
        if !self.isIndeterminate {
            //  adjustment needed to keep thin ring from showing around edge
            radius += 0//2.5
        }

        self.gradLayer = CAGradientLayer()
        gradLayer!.frame = CGRect(x: 0, y: 0, width: theWidth, height: theWidth)
        gradLayer!.cornerRadius = radius
        if self.isIndeterminate {
            if self.theGradientArray!.count <= 2 {
                self.theGradientArray = [self.theTailColor as AnyObject, self.theHeadColor as AnyObject]
            }
        } else {
            self.theGradientArray = [self.theHeadColor as AnyObject, self.theHeadColor as AnyObject]
        }
        self.gradLayer!.colors = self.theGradientArray
        
        if self.isIndeterminate {
            var arrowArcSize = CGFloat(10.0) // percentage of circle
            //  crazy adjustments to radius to make it all work
            //radius = theWidth * 1.1 / 2.0
            radius = theWidth + theLineWidth / 2.0
            arrowArcSize = CGFloat(0.64)
            self.currentArrowArcRadians = arrowArcSize * 2.0 * .pi
            let rotAngle = (15.0 / 180.0 * .pi)-self.currentArrowArcRadians
            gradLayer!.transform = CATransform3DMakeRotation(rotAngle, 0.0, 0.0, 1.0)
        }
        
        self.layer.addSublayer(self.gradLayer!)
    }
    
    
    private func createFrontLayer() {
        self.frontLayer?.removeFromSuperlayer()

        //    delta margin needed to get rid of a very thin ring around the
        //  outside showing gradLayer thru.
        let theWidth = self.controlWidth
        let delta: CGFloat = 2.0  //  make sure gradient is covered
        let maskWidth = self.controlWidth + delta

        let theRect = CGRect(x:-delta/2.0, y:-delta/2.0, width:maskWidth, height:maskWidth)
        let radius: CGFloat = theWidth / 2.0
        
        var im: UIImage?
        
        var theStartAngle: CGFloat = 0.0
        var theEndAngle: CGFloat = 0.0
        var isClockwise: Bool   = false
        
        if self.indeterminate! {
            theStartAngle = -.pi/2.0-self.currentArrowArcRadians
            theEndAngle = -.pi/2.0
            
        } else {
            let theTotalDelta = abs(self.theEndValue - self.theStartValue)
            //var newIncrementValue = self.currentValue// + self.theIncrement
                //  calc incrementVal from the 12 o'clock position
            var newIncrementValue: CGFloat = self.currentValue - self.theStartValue
                //  don't go past the end value
            if newIncrementValue >= self.theEndValue {
                newIncrementValue = newIncrementValue - self.theEndValue
            }
            let circleFraction = newIncrementValue / theTotalDelta
            theStartAngle = -.pi/2.0
            theEndAngle = -.pi/2.0 + (circleFraction * 2 * .pi)
                //  allow for weirdness in UIGraphics context
            if circleFraction > 0.5 {
                isClockwise = false
            } else {
                isClockwise = false
            }
        }
        
        UIGraphicsBeginImageContextWithOptions(theRect.size, false, 0)
        let theContext = UIGraphicsGetCurrentContext()
        
        theContext!.setLineWidth(self.theLineWidth)
        let centerPoint = CGPoint(x: maskWidth/2.0, y: maskWidth/2.0)
        
        theContext!.setFillColor(self.theFillColor)
        //theContext!.setFillColor(UIColor.clear.cgColor)
        theContext!.fill(CGRect(origin: CGPoint(), size: theRect.size))
        theContext!.setLineWidth(self.theLineWidth)
        theContext!.setLineCap(.round)
        theContext!.setBlendMode(.clear)
        //  this arc is the rotating arrow or for determinate, arc segment
        theContext!.addArc(center: centerPoint, radius: radius-self.theLineWidth/2.0, startAngle: theStartAngle, endAngle: theEndAngle, clockwise: isClockwise)

        theContext!.strokePath()
        im = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.frontLayer = CALayer()
        self.frontLayer!.frame = theRect
        self.frontLayer!.cornerRadius = maskWidth/2.0
        self.frontLayer!.contents = im!.roundedImage.cgImage
        
        self.layer.addSublayer(self.frontLayer!)
    }
    
    
    private func createCenterLabel() {
        self.centerLabel?.removeFromSuperview()

        var labelLineCount: CGFloat = 0
        self.showLabel.enumerateLines { (str, _) in
            labelLineCount += 1
        }
        if labelLineCount == 0 {labelLineCount = 1}
        let labelHeight = self.theLabelFont.pointSize * labelLineCount * 1.2
        //  self.controlWidth is also the height
        let x = self.lineWidth! / 2.0
        let y = (self.controlWidth - labelHeight) * 0.5
        let width = self.controlWidth - self.lineWidth!
        
        self.centerLabel = UILabel(frame: CGRect(x: x, y: y, width: width, height: labelHeight))
        self.centerLabel?.numberOfLines = 2
        self.centerLabel?.font = self.theLabelFont
        self.centerLabel?.backgroundColor = UIColor.clear
        self.centerLabel?.textAlignment = .center
        self.centerLabel?.adjustsFontSizeToFitWidth = true
        self.addSubview(self.centerLabel!)
    }
    
    
    // MARK: __________ Animation functions

    private let kkRotationAnimationKey = "rotationanimationkey"
    
    public func startAnimation(duration: CGFloat = 1.0) {
        self.isHidden = false
        if !isIndeterminate {
            return
        }
        if self.layer.animation(forKey: kkRotationAnimationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float.pi * 2.0
            rotationAnimation.duration = CFTimeInterval(duration)
            rotationAnimation.repeatCount = Float.infinity
            
            self.layer.add(rotationAnimation, forKey: kkRotationAnimationKey)
        }
    }
    
    public func stopAnimation() {
        if layer.animation(forKey: kkRotationAnimationKey) != nil {
            layer.removeAnimation(forKey: kkRotationAnimationKey)
        }
        if self.willDisplayWhenStopped {
            self.isHidden = false
        } else {
            self.isHidden = true
        }
    }
    
    //    used for countdown timer, this func repeatedly calls itself
    //  at 1 second intervals and the text for the ountdown is updated
    @objc public func startCountdownAnimation() {
        let increment = -1.0
        
        let totalDelta = abs(self.theEndValue - self.theStartValue)
        let theAmount = totalDelta + self.currentValue
        self.showLabelText()
        
        if theAmount > 0 {
            self.increment = increment
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.startCountdownAnimation), userInfo: nil, repeats: false)
        } else {
            if !self.willDisplayWhenStopped {
                self.isHidden = true
            }
            self.countdownCallback!()
        }
    }

}    // end class RAHCircleProgressIndicator()


//  https://stackoverflow.com/questions/262156/uiimage-rounded-corners
//    takes the UIImage and turns it into a circle instead of a rect
extension UIImage {
    var roundedImage: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: self.size.height
            ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}

