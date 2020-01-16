# RAHCircleProgressIndicator

A swift class for indeterminate, determinate or countdown progress indicator

Project/Folder Name: &nbsp;&nbsp;&nbsp;&nbsp;RAHCircleProgressSwift

## About

RAHCircleProgressIndicator is a view class that provides a single instance of a progress or wait indicator. There are 3 types of indicators that can be created with this class:  
1. an indeterminate indicator that spins, telling the user to wait, without an indiction how long they must wait.  
2. a determinate indicator that shows descrete progress around the 360 degree circle.  
3. a countdown timer that counts down to zero from a programmitcally set initial value in 1 second increments.

Class Name: &nbsp;&nbsp;&nbsp;&nbsp;RAHCircleProgressIndicator  
Subclass of: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;UIView  
Platform: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;iOS 8 or later  
Language: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Swift


## Features

Each instance of RAHCircleProgressIndicator creates one progress indicator. Each instance is a subclass of UIView. User interaction is not provided.

The RAHCircleProgressIndicator class is standalone. There are no dependancies with other classes other than Apple's UIKit. To use in your own project, just copy the RAHCircleProgressIndicator class.  

All three types of indicators are square in appearance. So, when creating an indicator in code or in the IB, the defined width will be used for both the width and height.  

An indeterminate version of the indicator can be modified in appearance by changing its size, the color of the fill/background, the arc line, and the width of the arc line. The arc line can be given a single color, two colors or a series of colors.

A determinate indicator cn be changed in appearance using the same modifications as an indeterminate indicator. In addition, it can have progress displayed as text in the center of the circle. The size and font of the text can be changed. The text can be for the actual value being displayed by the indicator or a percentage representing that value. The text can have a percent sign appended or a label of the programmers choosing.  

The value being displayed starts at the top of the indicator and goes around 360 degrees, clockwise. The start value can be negative or positive. The end value can be positive or negative. The start value can be less than or greater than the end value.  

The countdown timer works like the discrete indicator, except that it always counts down from the initial value to 0. The initial value is displayed at the top, and the indicator proceeds counter-clockwise. A callback function can be called when 0 is reached. Like the other indicator types, fill color, arc line width and color can all be defined.


## Use

In the example project, four instances of RAHCircleProgressIndicator have been created in the ViewController. Three instances were created in code, and the top right instance using the Interface Builder. This project should compile in Xcode and run in the simulator as is; use it to play with the examples.

If using a version of Swift older than 4.2, the compile will fail.  

To use RAHCircleProgressIndicator, copy the RAHCircleProgressIndicator class to your project.

Create an indicator in code in one of your view controllers, and be sure to add the checkbox to the your view controller's view:

self.indicator = RAHCircleProgressIndicator.init(frame: CGRect(x: 70, y: 170, width: 44, height: 33), indeterminate: true)  
  &nbsp;&nbsp;&nbsp;&nbsp;  // this indicator will be 44 x 44  
self.view.addSubview(self.indicator!)  

The parameter 'indeterminate' in the init call determines if the indicator is determinate or indeterminate. To create a countdown timer, use this init function:  
self.countDown = RAHCircleProgressIndicator.init(frame: CGRect(x: 240, y: 300, width: 40, height: 30), countDownFrom: 10.0, finalCallback: self.theCallback)  

self.theCallback is the callback function that will be executed when the countdown reaches 0. If no callback is needed, set that parameter to '{}'

To create an indicator using the Interface Builder, create a small UIView object in the IB. Then, in the identity Inspector, change the class to 'RAHCheckbox'. Create an IBOutlet of type RAHCircleProgressIndicator in the header of one of your view controllers, and link to it from the Interface Builder.

Look in the header of the RAHCircleProgressIndicator to see comments describing the available settings for the various tpes of indicators. Look in the code for ViewController for the four included examples, including modifications of their appearance.

The size of the indicator is determined when initialized, although size can be modified in your parent viewController's "updateConstraints" method. The indicator is circular, defined within a square view of the same size as the circle. If your defined rectangle for the view is not square, it is made a square by using the defined width for both width and height.

This image shows examples of the indicators.  

The top-left indicator is a very simple example with default colors and line width. The top-right example was created using a UIView in the IB with modifications in code for silly colors.   

The bottom-left indicator is a determinate type with start and end values defined in code. It shows values in the center. The bottom-right indicator is a countdown timer, that calls a function when it reaches 0; this functons displays an alert showing the value from the bottom-left indicator.

## Attribution

If you use this class, give attribution in your project or app's copyright notices. You must include "portions ©R.A.Hyman 2020. All rights reserved" along with each instance of your own copyright notice. You may not modify this code or use it as a pattern for your own class to avoid these attributions.

## Documentation

Documentation comprises this ReadMe and the notes found in the class. For further notes on setting up and using this class, look in the ViewController object for specific examples.

## Contributing

Please send any ideas, suggestions, bugs, questions to the author.

## Author

Richard Hyman
I am a freelance iOS and Mac app developer.

The code is ©2019 R.A.Hyman. All rights reserved. Portions ©2019-2020

## License

RAHCircleProgressIndicator is released under the MIT license. See LICENSE file for details.
