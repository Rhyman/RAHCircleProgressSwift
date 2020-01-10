//
//
//  ViewController.swift
//  for SpinCircleProgressSwift
//
//  Created by Richard Hyman on 10/16/19.
//  Copyright © 2019 Richard Hyman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //  the standard Apple blue
    let AppleBlue = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1)
    
    var topLeft:                RAHCircleProgressIndicator?
    
    @IBOutlet var topRight:     RAHCircleProgressIndicator?

    var bottomLeft:             RAHCircleProgressIndicator?
    
    var bottomRight:            RAHCircleProgressIndicator?

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //          topLeft        --  simple example
        //    Simple example of indeterminate, spinning indicator;
        //  Default Apple Blue indicator with white background
        //  The most simple code based spinner;    44 by 44 points
        //  Note that the height of the rect is ignored; height=width
        self.topLeft = RAHCircleProgressIndicator.init(frame: CGRect(x: 70, y: 170, width: 44, height: 33), indeterminate: true)
        self.view.addSubview(self.topLeft!)
        self.topLeft?.startAnimation()
        
        
        
        //          topRight        --  strange colors
        //    This spinning indicator is defined in the storyboard
        //  as a simple UIView defined to be a RAHCircleProgressIndicator.
        //  The width of the UIView defines both width & height. Fill color
        //  in the storyboard is ignored.
        //  The fill color is purple.
        //  A 3 color indicator is used; Apple Blue at the front, then orange, and a yellow tail
        self.topRight?.startAnimation()
        self.topRight?.fillColor = UIColor.purple
        self.topRight?.gradientArray = [UIColor.yellow, UIColor.orange, AppleBlue]

        
        
        //          bottomLeft      --  determinate displays values
        //    bottomLeft is a determinate indicator, displaying
        //  specific values. It has a light green fill (i.e. background).
        //  It has a red indicator arc.    80 by 80 pixels
        //  Start end end values are defined, and current value is
        //  displayed in the middle.
        //    This demonstrates that startValues can be negative. If
        //  desired, the startValue can be greater than the endValue.
        //  In that case, increments must be negative.
        //
        //    DispatchQueue is called a number of times, so that
        //  the indicator value can be increased every 2 secs. This
        //  is equivalent to updating the indicator with specific values
        //  as events occur.
        self.bottomLeft = RAHCircleProgressIndicator.init(frame: CGRect(x: 70, y: 300, width: 80, height: 40), indeterminate: false)
        self.bottomLeft!.startValue = -8.333
        self.bottomLeft!.endValue = 75
            //  this call causes the value to be displayed in the center
        self.bottomLeft!.display(progressNumber: true, withPercent: false, orUseLabel: "")
            //    defining headColor causes entire indicator to be 1 color
        self.bottomLeft!.headColor = UIColor.red
            //  background is pale green
        self.bottomLeft!.fillColor = UIColor(red: 0.95, green: 1.0, blue: 0.95, alpha: 1.0)
        self.bottomLeft!.labelFont = UIFont.systemFont(ofSize: 18)
        
        self.view.addSubview(self.bottomLeft!)
        
            //    this initial setting of 'increment' causes the
            //  defined startValue to be displayed
        self.bottomLeft!.increment = 0
        
        //    mimic sending the indicator incremental updates
        //  The values sent to the indicator come from whatever class
        //  you have that has values needing display for the user.
            //      nesting calls to the DispatchQueue that mimic updates
            //  Updates come every 2 seconds, each increment is +10
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `1.0` to the desired number of seconds.
            self.bottomLeft!.increment = 10
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.bottomLeft!.increment = 10
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.bottomLeft!.increment = 10
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.bottomLeft!.increment = 10
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.bottomLeft!.increment = 10
                        }
                    }
                }
            }
        }

        
        
        
        //          bottomRight     --  countdown indicator
        //     An example of the countdown timer
        //  The fill color is very light red. The indicator arc is thin & red
        //  When the countdown reaches 0, theCallBack func below is executed
        
            //  if no callback, use 'finalCallback: {}'
        self.bottomRight = RAHCircleProgressIndicator.init(frame: CGRect(x: 240, y: 300, width: 40, height: 30), countDownFrom: 10.0, finalCallback: self.theCallback)
        self.bottomRight!.fillColor = UIColor(red: 1.0, green: 0.95, blue: 0.95, alpha: 1.0)
        self.bottomRight!.lineWidth = 1.0
        self.bottomRight!.headColor = UIColor.red
            //  default for countdown indicator is to hide it when it hits 0
        self.bottomRight!.displayWhenStopped = true
        self.view.addSubview(self.bottomRight!)
        self.bottomRight!.startCountdownAnimation()
    }
    
    

    //    used by the countdown indicator (bottomRight), this callback grabs
    //  current value of bottomLeft indicator, displaying it in an alert
    func theCallback() {
        let currentValue = self.bottomLeft!.doubleValue
        
        let alertController = UIAlertController(title: "My Alert::\(currentValue)", message: "A Message", preferredStyle: UIAlertController.Style.alert)
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction) -> Void in
                // Do something based on the user tapping the action button
            })
        alertController.addAction(OKAction)

        self.present(alertController, animated: true, completion: nil)
    }
        
}




