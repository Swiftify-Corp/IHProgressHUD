# IHProgressHUD

![Pod Version](https://img.shields.io/cocoapods/v/IHProgressHUD.svg?style=flat)
![Pod Platform](https://img.shields.io/cocoapods/p/IHProgressHUD.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/IHProgressHUD.svg?style=flat)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-green.svg?style=flat)](https://cocoapods.org)

`IHProgressHUD` is a clean and easy-to-use HUD meant to display the progress of an ongoing task on iOS and tvOS. `IHProgressHUD` is based on [SVProgressHUD](https://github.com/SVProgressHUD/SVProgressHUD) and ported to Swift with the [help of Swiftify](https://medium.com/swiftify/converting-svprogresshud-to-swift-using-swiftify-27be1817b7f6),
with improvements like added thread safety and not using complier flag for use in iOS App Extension. 


![IHProgressHUD](http://f.cl.ly/items/2G1F1Z0M0k0h2U3V1p39/SVProgressHUD.gif)

## Demo        

Try `IHProgressHUD` on [Appetize.io](https://appetize.io/app/hn358rg7zc8uyethqayub23h2c).


## Installation

### From CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C and Swift, which automates and simplifies the process of using 3rd-party libraries like `IHProgressHUD` in your projects. First, add the following line to your [Podfile](http://guides.cocoapods.org/using/using-cocoapods.html):

```ruby
pod 'IHProgressHUD'
```

If you want to use the latest features of `IHProgressHUD` use normal external source dependencies.

```ruby
pod 'IHProgressHUD', :git => 'https://github.com/Swiftify-Corp/IHProgressHUD.git'
```

This pulls from the `master` branch directly.

Second, install `IHProgressHUD` into your project:

```ruby
pod install
```

### Carthage

Currently not available but would be available shortly.

### Manually

* Drag the `IHProgressHUD/IHProgressHUD` folder into your project.
* Take care that `IHProgressHUD.bundle` is added to `Targets->Build Phases->Copy Bundle Resources`.
* Add the **QuartzCore** framework to your project.

## Usage

(see sample Xcode project in `/Demo`)

`IHProgressHUD` is created as a singleton (i.e. it doesn't need to be explicitly allocated and instantiated; you directly call `IHProgressHUD.method()`). It can be accessed from even the background thread.

**Use `IHProgressHUD` wisely! Only use it if you absolutely need to perform a task before taking the user forward. Bad use case examples: pull to refresh, infinite scrolling, sending message.**

Using `IHProgressHUD` in your app will usually look as simple as this (using Grand Central Dispatch):

```Swift
IHProgressHUD.show()
DispatchQueue.global(qos: .default).async(execute: {
// time-consuming task
IHProgressHUD.dismiss()
})
```

### Showing the HUD

You can show the status of indeterminate tasks using one of the following:

```Swift
class func show()
class func show(withStatus status: String?)
```

If you'd like the HUD to reflect the progress of a task, use one of these:

```Swift
class func show(progress: CGFloat)
class func show(progress: CGFloat, status: String?)
```

### Dismissing the HUD

The HUD can be dismissed using:

```Swift
class func dismiss()
class func dismissWithCompletion(_ completion: (() -> Void)?)
class func dismissWithDelay(_ delay: TimeInterval)
class func dismissWithDelay(_ delay: TimeInterval, completion: (() -> Void)?)
```

If you'd like to stack HUDs, you can balance out every show call using:

```
class func popActivity()
```

The HUD will get dismissed once the popActivity calls will match the number of show calls.

Or show a confirmation glyph before before getting dismissed a little bit later. The display time depends on `minimumDismissTimeInterval` and the length of the given string.

```Swift
class func showInfowithStatus(_ status: String?)
class func showSuccesswithStatus(_ status: String?)
class func showError(withStatus status: String?)
class func showImage(_ image: UIImage, status: String?)
```

## Customization

`IHProgressHUD` can be customized via the following methods:

```Swift
class func set(defaultStyle style: IHProgressHUDStyle) // default is IHProgressHUDStyle.light

class func set(defaultMaskType maskType: IHProgressHUDMaskType) // default is IHProgressHUDMaskType.none

class func set(defaultAnimationType type: IHProgressHUDAnimationType) // default is IHProgressHUDAnimationType.flat

class func set(containerView: UIView?) // default is window level

class func set(minimumSize: CGSize) // default is CGSize.zero, can be used to avoid resizing

class func set(ringThickness: CGFloat) // default is 2 pt

class func set(ringRadius : CGFloat) // default is 18 pt

class func setRing(noTextRingRadius radius: CGFloat) // default is 24 pt

class func set(cornerRadius: CGFloat) // default is 14 pt

class func set(borderColor color : UIColor) // default is nil

class func set(borderWidth width: CGFloat)  // default is 0

class func set(font: UIFont) // default is UIFont.preferredFont(forTextStyle: .subheadline)

class func set(foregroundColor color: UIColor) // default is nil

class func set(backgroundColor color: UIColor) // default is nil

class func set(backgroundLayerColor color: UIColor) // default is UIColor.init(white: 0, alpha: 0.4), only used for IHProgressHUDMaskType.custom

class func set(imageViewSize size: CGSize) // default is 28x28 pt

class func set(shouldTintImages: Bool) // default is true

class func set(infoImage image: UIImage) // default is the bundled info image provided by Freepik

class func setSuccessImage(successImage image: UIImage) // default is bundled success image from Freepik

class func setErrorImage(errorImage image: UIImage) // default is bundled error image from Freepik

class func set(viewForExtension view: UIView) // default is nil, only used for App Extension

class func set(graceTimeInterval interval: TimeInterval) // default is 5.0 seconds

class func set(maximumDismissTimeInterval interval: TimeInterval) // default is TimeInterval(CGFloat.infinity)

class func setFadeInAnimationDuration(fadeInAnimationDuration duration: TimeInterval) // default is 0.15 seconds

class func setFadeOutAnimationDuration(fadeOutAnimationDuration duration: TimeInterval) // default is 0.15 seconds

class func setMaxSupportedWindowLevel(maxSupportedWindowLevel windowLevel: UIWindow.Level) // default is UIWindowLevelNormal

class func setHapticsEnabled(hapticsEnabled: Bool) // default is NO
```

### Hint

As standard `IHProgressHUD` offers two preconfigured styles:

* `IHProgressHUDStyle.light`: White background with black spinner and text
* `IHProgressHUDStyle.dark`: Black background with white spinner and text

If you want to use custom colors use `setForegroundColor` and `setBackgroundColor:`. These implicitly set the HUD's style to `IHProgressHUDStyle.custom`.

## Haptic Feedback

For users with newer devices (starting with the iPhone 7), `IHProgressHUD` can automatically trigger haptic feedback depending on which HUD is being displayed. The feedback maps as follows:

* `showSuccessWithStatus:` <-> `UINotificationFeedbackTypeSuccess`
* `showInfoWithStatus:` <-> `UINotificationFeedbackTypeWarning`
* `showErrorWithStatus:` <-> `UINotificationFeedbackTypeError`

To enable this functionality, use `setHapticsEnabled:`.

Users with devices prior to iPhone 7 will have no change in functionality.

## Notifications

`IHProgressHUD` posts four notifications via `NSNotificationCenter` in response to being shown/dismissed:
* `NotificationName.IHProgressHUDWillAppear` when the show animation starts
* `NotificationName.IHProgressHUDDidAppear` when the show animation completes
* `NotificationName.IHProgressHUDDidDisappear` when the dismiss animation starts
* `NotificationName.IHProgressHUDDidAppear` when the dismiss animation completes

Each notification passes a `userInfo` dictionary holding the HUD's status string (if any), retrievable via `[NotificationName.IHProgressHUDStatusUserInfoKey.getNotificationName()]`.

`IHProgressHUD` also posts `IHProgressHUDDidReceiveTouchEvent` when users touch on the overall screen or `IHProgressHUDDidTouchDownInside` when a user touches on the HUD directly. For this notifications `userInfo` is not passed but the object parameter contains the `UIEvent` that related to the touch.

## App Extensions

When using `IHProgressHUD` in an App Extension,  use the `class func set(viewForExtension view: UIView)` there is no need to set any complier flag.  

## Contributing to this project

If you have feature requests or bug reports, feel free to help out by sending pull requests or by [creating new issues](https://github.com/ibrahimhass/IHProgressHUD/issues/new). Please take a moment to
review the guidelines written by [Nicolas Gallagher](https://github.com/necolas):

* [Bug reports](https://github.com/necolas/issue-guidelines/blob/master/CONTRIBUTING.md#bugs)
* [Feature requests](https://github.com/necolas/issue-guidelines/blob/master/CONTRIBUTING.md#features)
* [Pull requests](https://github.com/necolas/issue-guidelines/blob/master/CONTRIBUTING.md#pull-requests)

## License

`IHProgressHUD` is distributed under the terms and conditions of the [MIT license](https://github.com/Swiftify-Corp/IHProgressHUD/blob/master/LICENSE). The success, error and info icons are made by [Freepik](http://www.freepik.com) from [Flaticon](http://www.flaticon.com) and are licensed under [Creative Commons BY 3.0](http://creativecommons.org/licenses/by/3.0/).

## Credits

`IHProgressHUD` is brought to you by [Md Ibrahim Hassan ](mdibrahimhassan@gmail.com)
If you're using `IHProgressHUD` in your project, attribution would be very appreciated. This project is converted with the help of [Swiftify](https://objectivec2swift.com/). The conversion process can be found [here](https://medium.com/swiftify/converting-svprogresshud-to-swift-using-swiftify-27be1817b7f6).
