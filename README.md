# IHProgressHUD

![Pod Version](https://img.shields.io/cocoapods/v/SVProgressHUD.svg?style=flat)
![Pod Platform](https://img.shields.io/cocoapods/p/SVProgressHUD.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/SVProgressHUD.svg?style=flat)


`IHProgressHUD` is a clean and easy-to-use HUD meant to display the progress of an ongoing task on iOS and tvOS. It is based on SVProgressHUD and converted to Swift using Swiftify.

![SVProgressHUD](http://f.cl.ly/items/2G1F1Z0M0k0h2U3V1p39/SVProgressHUD.gif)

IHProgressHUD is a clean and easy-to-use HUD meant to display the progress of an ongoing task on iOS and tvOS.

IHProgressHUD


Installation
From CocoaPods
CocoaPods is a dependency manager for Objective-C and Swift, which automates and simplifies the process of using 3rd-party libraries like IHProgressHUD in your projects. First, add the following line to your Podfile:

pod 'IHProgressHUD'

Second, install IHProgressHUD into your project:

pod install

Manually
Drag the IHProgressHUD/Classes folder into your project.
Take care that IHProgressHUD.bundle is added to Targets->Build Phases->Copy Bundle Resources.
Add the QuartzCore framework to your project.

Usage
(see sample Xcode project in /Demo)

IHProgressHUD is created as a singleton (i.e. it doesn't need to be explicitly allocated and instantiated; you directly call [SVProgressHUD method]).

Use IHProgressHUD wisely! Only use it if you absolutely need to perform a task before taking the user forward. Bad use case examples: pull to refresh, infinite scrolling, sending message.

Using IHProgressHUD in your app will usually look as simple as this (using Grand Central Dispatch):
IHProgressHUD can be accessed from Any thread this is one of the improvements over SVProgressHUD.

IHProgressHUD.show()
DispatchQueue.global(qos: .utility) {
// time consuming task
IHPreogressHUD.dismiss()
}

Showing the HUD
You can show the status of indeterminate tasks using one of the following:

class func show()
class func show(withStatus status: String?)

If you'd like the HUD to reflect the progress of a task, use one of these:

class func show(progress: CGFloat)
class func show(progress: CGFloat, status: String?) 
Dismissing the HUD
The HUD can be dismissed using:

class func dismiss()
class func dismissWithDelay(_ delay: TimeInterval)
class func dismissWithCompletion(_ completion: (() -> Void)?)
class func dismissWithDelay(_ delay: TimeInterval, completion: (() -> Void)?)

If you'd like to stack HUDs, you can balance out every show call using:

class func popActivity()
The HUD will get dismissed once the popActivity calls will match the number of show calls.

Or show a confirmation glyph before before getting dismissed a little bit later. The display time depends on minimumDismissTimeInterval and the length of the given string.

class func showInfowithStatus(_ status: String?)
class func showSuccesswithStatus(_ status: String?)
class func showError(withStatus status: String?)
class func showImage(_ image: UIImage, status: String?)

Customization
IHProgressHUD can be customized via the following methods:

class func set(defaultStyle style: IHProgressHUDStyle)                  // default is IHProgressHUDStyle.light
class func set(defaultMaskType maskType: IHProgressHUDMaskType)        // default is IHProgressHUDMaskType.none
class func set(defaultAnimationType type: IHProgressHUDAnimationType)   // default is IHProgressHUDAnimationType.flat
class func set(minimumSize: CGSize)                         // default is CGSizeZero, can be used to avoid resizing
class func set(ringThickness: CGFloat)                            // default is 2 pt
class func set(ringRadius : CGFloat)                              // default is 18 pt
class func setRing(noTextRingRadius radius: CGFloat)                        // default is 24 pt
class func set(cornerRadius: CGFloat)                      // default is 14 pt
class func set(borderColor color : UIColor)                     // default is nil
class func set(borderWidth width: CGFloat)                              // default is 0
class func set(font: UIFont)                                      // default is UIFont.preferredFont(forTextStyle: .subheadline)
class func set(foregroundColor color: UIColor)                         // default is [UIColor blackColor], only used for SVProgressHUDStyleCustom
+ (void)setBackgroundColor:(UIColor*)color;                         // default is [UIColor whiteColor], only used for SVProgressHUDStyleCustom
+ (void)setBackgroundLayerColor:(UIColor*)color;                    // default is [UIColor colorWithWhite:0 alpha:0.4], only used for SVProgressHUDMaskTypeCustom
+ (void)setImageViewSize:(CGSize)size;                              // default is 28x28 pt
+ (void)setShouldTintImages:(BOOL)shouldTintImages;                 // default is YES
+ (void)setInfoImage:(UIImage*)image;                               // default is the bundled info image provided by Freepik
+ (void)setSuccessImage:(UIImage*)image;                            // default is bundled success image from Freepik
+ (void)setErrorImage:(UIImage*)image;                              // default is bundled error image from Freepik
+ (void)setViewForExtension:(UIView*)view;                          // default is nil, only used if #define SV_APP_EXTENSIONS is set
+ (void)setGraceTimeInterval:(NSTimeInterval)interval;              // default is 0 seconds
+ (void)setMinimumDismissTimeInterval:(NSTimeInterval)interval;     // default is 5.0 seconds
+ (void)setMaximumDismissTimeInterval:(NSTimeInterval)interval;     // default is CGFLOAT_MAX
+ (void)setFadeInAnimationDuration:(NSTimeInterval)duration;        // default is 0.15 seconds
+ (void)setFadeOutAnimationDuration:(NSTimeInterval)duration;       // default is 0.15 seconds
+ (void)setMaxSupportedWindowLevel:(UIWindowLevel)windowLevel;      // default is UIWindowLevelNormal
+ (void)setHapticsEnabled:(BOOL)hapticsEnabled;                     // default is NO
Additionally SVProgressHUD supports the UIAppearance protocol for most of the above methods.

Hint
As standard SVProgressHUD offers two preconfigured styles:

SVProgressHUDStyleLight: White background with black spinner and text
SVProgressHUDStyleDark: Black background with white spinner and text
If you want to use custom colors use setForegroundColor and setBackgroundColor:. These implicitly set the HUD's style to SVProgressHUDStyleCustom.

Haptic Feedback
For users with newer devices (starting with the iPhone 7), SVProgressHUD can automatically trigger haptic feedback depending on which HUD is being displayed. The feedback maps as follows:

showSuccessWithStatus: <-> UINotificationFeedbackTypeSuccess
showInfoWithStatus: <-> UINotificationFeedbackTypeWarning
showErrorWithStatus: <-> UINotificationFeedbackTypeError
To enable this functionality, use setHapticsEnabled:.

Users with devices prior to iPhone 7 will have no change in functionality.

Notifications
SVProgressHUD posts four notifications via NSNotificationCenter in response to being shown/dismissed:

SVProgressHUDWillAppearNotification when the show animation starts
SVProgressHUDDidAppearNotification when the show animation completes
SVProgressHUDWillDisappearNotification when the dismiss animation starts
SVProgressHUDDidDisappearNotification when the dismiss animation completes
Each notification passes a userInfo dictionary holding the HUD's status string (if any), retrievable via SVProgressHUDStatusUserInfoKey.

SVProgressHUD also posts SVProgressHUDDidReceiveTouchEventNotification when users touch on the overall screen or SVProgressHUDDidTouchDownInsideNotification when a user touches on the HUD directly. For this notifications userInfo is not passed but the object parameter contains the UIEvent that related to the touch.

App Extensions
Call setViewForExtension: from your extensions view controller with self.view.
No need to set any flag now as it is handled automatically in code.

Contributing to this project
If you have feature requests or bug reports, feel free to help out by sending pull requests or by creating new issues. Please take a moment to review the guidelines written by Nicolas Gallagher:

Bug reports
Feature requests
Pull requests
License
IHProgressHUD is distributed under the terms and conditions of the MIT license. The success, error and info icons are made by Freepik from Flaticon and are licensed under Creative Commons BY 3.0.

Credits
IHProgressHUD is brough to you by Md Ibrahim Hassan based on SVProgressHUD SVProgressHUD built by Sam Vermette, Tobias Tiemerding and contributors to the project. If you're using IHProgressHUD in your project, attribution would be very appreciated.

© 2018
