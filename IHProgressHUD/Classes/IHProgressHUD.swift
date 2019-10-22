//
//  Converted to Swift 4 by Swiftify v4.2.29618 - https://objectivec2swift.com/
//
//  IndefiniteAnimatedView.swift
//  SVProgressHUD, https://github.com/IHProgressHUD/IHProgressHUD
//
//  Original Copyright (c) 2014-2018 Guillaume Campagna. All rights reserved.
//  Modified Copyright © 2018 Ibrahim Hassan. All rights reserved.
//


import UIKit

public enum NotificationName : String {
    case IHProgressHUDDidReceiveTouchEvent, IHProgressHUDDidTouchDownInside, IHProgressHUDWillDisappear, IHProgressHUDDidDisappear, IHProgressHUDWillAppear, IHProgressHUDDidAppear, IHProgressHUDStatusUserInfoKey
    public func getNotificationName() -> Notification.Name {
        return Notification.Name.init(self.rawValue)
    }
}

public enum IHProgressHUDStyle : Int {
    case light
    case dark
    case custom
}

public enum IHProgressHUDMaskType : Int {
    case none = 1
    case clear
    case black
    case gradient
    case custom
}

public enum IHProgressHUDAnimationType : Int {
    case flat
    case native
}

private let IHProgressHUDParallaxDepthPoints : CGFloat = 10.0
private let IHProgressHUDUndefinedProgress : CGFloat = -1
private let IHProgressHUDDefaultAnimationDuration: CGFloat = 0.15
private let IHProgressHUDVerticalSpacing: CGFloat = 12.0
private let IHProgressHUDHorizontalSpacing: CGFloat = 12.0
private let IHProgressHUDLabelSpacing: CGFloat = 8.0

public class IHProgressHUD : UIView {
    
    static var isNotAppExtension = true

    private var  defaultStyle = IHProgressHUDStyle.light
    private var defaultMaskType = IHProgressHUDMaskType.none
    private var defaultAnimationType = IHProgressHUDAnimationType.flat
    private var containerView: UIView?
    private var minimumSize = CGSize.init(width: 50, height: 50)
    private var ringThickness: CGFloat = 2.0
    private var ringRadius: CGFloat = 18.0
    private var ringNoTextRadius: CGFloat = 24.0
    private var cornerRadius: CGFloat = 14.0
    private var font = UIFont.preferredFont(forTextStyle: .subheadline)
    private var foregroundColor : UIColor?
    private var backgroundLayerColor = UIColor.init(white: 0, alpha: 0.4)
    private var imageViewSize: CGSize = CGSize.init(width: 28, height: 28)
    private var shouldTintImages : Bool = true
    private var infoImage: UIImage!
    private var successImage: UIImage! //= UIImage.init(named: "success")!
    private var errorImage: UIImage! //= UIImage.init(named: "error")!
    private var viewForExtension: UIView?
    private var graceTimeInterval: TimeInterval = 0.0
    private var minimumDismissTimeInterval: TimeInterval = 5.0
    private var maximumDismissTimeInterval: TimeInterval = TimeInterval(CGFloat.infinity)
    private var offsetFromCenter: UIOffset = UIOffset.init(horizontal: 0, vertical: 0)
    private var fadeInAnimationDuration: TimeInterval = TimeInterval(IHProgressHUDDefaultAnimationDuration)
    private var fadeOutAnimationDuration: TimeInterval = TimeInterval(IHProgressHUDDefaultAnimationDuration)
    private var maxSupportedWindowLevel: UIWindow.Level = UIWindow.Level.normal
    private var hapticsEnabled = false
    private var graceTimer: Timer?
    private var fadeOutTimer: Timer?
    private var controlView: UIControl?
    private var backgroundView: UIView?
    private var backgroundRadialGradientLayer: RadialGradientLayer?
    private var hudView: UIVisualEffectView?
    private var statusLabel: UILabel?
    private var imageView: UIImageView?
    private var indefiniteAnimatedView: IndefiniteAnimatedView?
    private var ringView: ProgressAnimatedView?
    private var backgroundRingView: ProgressAnimatedView?
    private var progress: Float = 0.0
    private var activityCount: Int = 0
    private var visibleKeyboardHeight: CGFloat = 0.0
    private var frontWindow: UIWindow?
    private var hudBackgroundColor : UIColor?
    #if os(iOS)
    @available(iOS 10.0, *)
    private var hapticGenerator: UINotificationFeedbackGenerator? {
        get {
            if hapticsEnabled == true {
                return UINotificationFeedbackGenerator()
            } else {
                return nil
            }
        }
    }
    #endif
    private override init(frame: CGRect) {
        super.init(frame: frame)
        infoImage = loadImageBundle(named: "info")!
        successImage = loadImageBundle(named: "success")!
        errorImage = loadImageBundle(named: "error")
        isUserInteractionEnabled = false
        activityCount = 0
        getBackGroundView().alpha = 0.0
        getImageView().alpha = 0.0
        getStatusLabel().alpha = 1.0
        getIndefiniteAnimatedView().alpha = 0.0
        getBackgroundRingView().alpha = 0.0
        backgroundColor = UIColor.clear
        accessibilityIdentifier = "IHProgressHUD"
        isAccessibilityElement = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func getIndefiniteAnimatedView() -> IndefiniteAnimatedView {
        if defaultAnimationType == .flat {
            if (indefiniteAnimatedView == nil) {
                indefiniteAnimatedView = IndefiniteAnimatedView.init(frame: .zero)
            }
            indefiniteAnimatedView?.setIndefinite(strokeColor: foreGroundColorForStyle())
            indefiniteAnimatedView?.setIndefinite(strokeThickness: ringThickness)
            var radius :CGFloat = 0.0
            if getStatusLabel().text != nil {
                radius = ringRadius
            } else {
                radius = ringNoTextRadius
            }
            indefiniteAnimatedView?.setIndefinite(radius: radius)
        } else {
            indefiniteAnimatedView?.removeAnimationLayer()
            indefiniteAnimatedView?.setActivityIndicator(color: foreGroundColorForStyle())
            indefiniteAnimatedView?.startAnimation()
        }
        indefiniteAnimatedView?.sizeToFit()
        return indefiniteAnimatedView!
    }
    
    private static let sharedView : IHProgressHUD = {
        var localInstance : IHProgressHUD?
        if Thread.current.isMainThread {
            if IHProgressHUD.isNotAppExtension {
            if let window = UIApplication.shared.delegate?.window {
                localInstance = IHProgressHUD.init(frame: window?.bounds ?? CGRect.zero)
            } else {
                localInstance = IHProgressHUD()
                }
            }
            else {
            localInstance = IHProgressHUD.init(frame: UIScreen.main.bounds)
            }
        } else {
            DispatchQueue.main.sync {
                if IHProgressHUD.isNotAppExtension {
                if let window = UIApplication.shared.delegate?.window {
                    localInstance = IHProgressHUD.init(frame: window?.bounds ?? CGRect.zero)
                } else {
                    localInstance = IHProgressHUD()
                    }
                } else {
                localInstance = IHProgressHUD.init(frame: UIScreen.main.bounds)
                }
            }
        }
        return localInstance!
    }()

    // MARK :- Setters
    
    private func showProgress(progress: Float, status: String?) {
        OperationQueue.main.addOperation({ [weak self] in
            guard let strongSelf = self else { return }
                if strongSelf.fadeOutTimer != nil {
                    strongSelf.activityCount = 0
                }
                
                // Stop timer
                strongSelf.setFadeOut(timer: nil)
                strongSelf.setGrace(timer: nil)
                
                // Update / Check view hierarchy to ensure the HUD is visible
                strongSelf.updateViewHierarchy()
                
                // Reset imageView and fadeout timer if an image is currently displayed
                strongSelf.getImageView().isHidden = true
                strongSelf.getImageView().image = nil
                
                // Update text and set progress to the given value
                strongSelf.getStatusLabel().isHidden = (status?.count ?? 0) == 0
                strongSelf.getStatusLabel().text = status
                strongSelf.progress = progress
                
                // Choose the "right" indicator depending on the progress
                if progress >= 0 {
                    // Cancel the indefiniteAnimatedView, then show the ringLayer
                    strongSelf.cancelIndefiniteAnimatedViewAnimation()
                    
                    // Add ring to HUD
                    if strongSelf.getRingView().superview == nil {
                        strongSelf.getHudView().contentView.addSubview(strongSelf.getRingView())
                    }
                    if strongSelf.getBackgroundRingView().superview == nil {
                        strongSelf.getHudView().contentView.addSubview(strongSelf.getBackgroundRingView())
                    }
                    
                    // Set progress animated
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    strongSelf.getRingView().set(strokeEnd: CGFloat(progress))
                    //                strongSelf.ringView.strokeEnd = progress;
                    CATransaction.commit()
                    
                    // Update the activity count
                    if progress == 0 {
                        strongSelf.activityCount += 1
                    }
                } else {
                    // Cancel the ringLayer animation, then show the indefiniteAnimatedView
                    strongSelf.cancelRingLayerAnimation()
                    
                    // Add indefiniteAnimatedView to HUD
                    strongSelf.getHudView().contentView.addSubview(strongSelf.getIndefiniteAnimatedView())
                    
                    if strongSelf.defaultAnimationType == .native {
                        strongSelf.getIndefiniteAnimatedView().stopActivityIndicator()
                    }
                    
                    // Update the activity count
                    strongSelf.activityCount += 1
                }
                
                // Fade in delayed if a grace time is set
                if strongSelf.graceTimeInterval > 0.0 && strongSelf.getBackGroundView().alpha == 0.0 {
                    let timer = Timer(timeInterval: strongSelf.graceTimeInterval, target: strongSelf, selector: #selector(strongSelf.fadeIn(_:)), userInfo: nil, repeats: false)
                    strongSelf.setGrace(timer: timer)
                    if let aTimer = strongSelf.graceTimer {
                        RunLoop.main.add(aTimer, forMode: .common)
                    }
                } else {
                    strongSelf.fadeIn(nil)
                }
                
                // Tell the Haptics Generator to prepare for feedback, which may come soon
            #if os(iOS)
                if #available(iOS 10.0, *) {
                    strongSelf.hapticGenerator?.prepare()
                }
            #endif
        })
    }
    
    @objc private func controlViewDidReceiveTouchEvent(_ sender: Any?, for event: UIEvent?) {
        NotificationCenter.default.post(name: NotificationName.IHProgressHUDDidReceiveTouchEvent.getNotificationName(), object: self, userInfo: notificationUserInfo())

        if let touchLocation = event?.allTouches?.first?.location(in: self) {
            if getHudView().frame.contains(touchLocation) {
                NotificationCenter.default.post(name:
                    NotificationName.IHProgressHUDDidTouchDownInside.getNotificationName(), object: self, userInfo: notificationUserInfo())
            }
        }

    }
    
    func notificationUserInfo() -> [String : Any]? {
        if let statusText = getStatusLabel().text {
            return [NotificationName.IHProgressHUDStatusUserInfoKey.rawValue: statusText]
        }
        return nil
    }

    
    @objc private func fadeIn(_ object: AnyObject?) {
        updateHUDFrame()
        positionHUD()
        if (defaultMaskType != .none) {
            getControlView().isUserInteractionEnabled = true
            accessibilityLabel = getStatusLabel().text ?? "Loading"
            isAccessibilityElement = true
            getControlView().accessibilityViewIsModal = true
        } else {
            getControlView().isUserInteractionEnabled = false
            getHudView().accessibilityLabel = getStatusLabel().text ?? "Loading"
            getHudView().isAccessibilityElement = true
            getControlView().accessibilityViewIsModal = false
        }
        
        if getBackGroundView().alpha != 1.0 {
            NotificationCenter.default.post(name: NotificationName.IHProgressHUDWillAppear.getNotificationName(), object: self, userInfo: notificationUserInfo())
            
            getHudView().transform = CGAffineTransform.init(scaleX: 1/1.5, y: 1/1.5)
            let animationsBlock : () -> Void = {
                // Zoom HUD a little to make a nice appear / pop up animation
                self.getHudView().transform = CGAffineTransform.identity
                
                // Fade in all effects (colors, blur, etc.)
                self.fadeInEffects()
            }
            
            
            let completionBlock : () -> Void = {
                if self.getBackGroundView().alpha == 1.0 {
                    self.registerNotifications()
                }
                
                NotificationCenter.default.post(name: NotificationName.IHProgressHUDDidAppear.getNotificationName(), object: self, userInfo: self.notificationUserInfo())
                
                // Update accessibility

                UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: nil)
                
                UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: self.statusLabel?.text)
                if let cd : TimeInterval = object as? TimeInterval {
                    let timer = Timer.init(timeInterval: cd, target: self, selector: #selector(self.dismiss), userInfo: nil, repeats: false)
                    self.setFadeOut(timer: timer)
                    RunLoop.main.add(self.fadeOutTimer!, forMode: .common)
                }
            }
            
            if fadeInAnimationDuration > 0 {
                UIView.animate(withDuration: self.fadeInAnimationDuration, delay: 0, options: [.allowUserInteraction, .curveEaseIn, .beginFromCurrentState], animations: animationsBlock, completion: {
                    finished in
                    completionBlock()
                })
            } else {
                animationsBlock()
                completionBlock()
            }
            self.setNeedsDisplay()
        } else {
            UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: nil)
            
            UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: self.statusLabel?.text)
            
            if let convertedDuration : TimeInterval = object as? TimeInterval {
                let timer = Timer.init(timeInterval: convertedDuration, target: self, selector: #selector(dismiss), userInfo: nil, repeats: false)
                setFadeOut(timer: timer)
                RunLoop.main.add(self.fadeOutTimer!, forMode: .common)
            }
        }
    }
    
    @objc private func positionHUD(_ notification: Notification? = nil) {
        var keyboardHeight: CGFloat = 0.0
        var animationDuration: Double = 0.0
        
        if IHProgressHUD.isNotAppExtension == false {
            if viewForExtension != nil {
                frame = viewForExtension!.frame
            } else {
                frame = UIScreen.main.bounds
            }
        }
        
        var statusBarFrame = CGRect.zero
        
        #if os(iOS) // notAppExtension + iOS
        if IHProgressHUD.isNotAppExtension {
            if let appDelegate = UIApplication.shared.delegate,
                let window : UIWindow = appDelegate.window! {
                frame = window.bounds
            }
            var orientation = UIApplication.shared.statusBarOrientation

        if frame.width > frame.height {
            orientation = .landscapeLeft
        } else {
            orientation = .portrait
        }
        if let notificationData = notification {
            let keyboardInfo = notificationData.userInfo
            if let keyboardFrame: NSValue = keyboardInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardFrame: CGRect = keyboardFrame.cgRectValue
                if (notification?.name.rawValue == UIResponder.keyboardWillShowNotification.rawValue || notification?.name.rawValue == UIResponder.keyboardDidShowNotification.rawValue) {
                    keyboardHeight = keyboardFrame.width
                    if orientation.isPortrait {
                        keyboardHeight = keyboardFrame.height
                    }
                }
            }
            if let aDuration: Double = keyboardInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
                animationDuration = aDuration
            }
        } else {
            keyboardHeight = getVisibleKeyboardHeight()
        }
        statusBarFrame = UIApplication.shared.statusBarFrame
        updateMotionEffectForOrientation(orientation)
        }
        #endif
        
        let orientationFrame = bounds
        #if os(tvOS)
        if IHProgressHUD.isNotAppExtension {
            if let keyWindow : UIWindow = UIApplication.shared.keyWindow {
                frame = keyWindow.bounds
            }
        }
        updateMotionEffect(forXMotionEffectType: .tiltAlongHorizontalAxis, yMotionEffectType: .tiltAlongHorizontalAxis)
        #endif
        
        var activeHeight = orientationFrame.height
        
        if keyboardHeight > 0 {
            activeHeight += statusBarFrame.height * 2
        }
        activeHeight -= keyboardHeight
        
        let posX = orientationFrame.midX
        let posY = CGFloat(floor(activeHeight * 0.45))
        
        let rotateAngle : CGFloat = 0.0
        let newCenter = CGPoint.init(x: posX, y: posY)
        
        if notification != nil {
            // Animate update if notification was present
            UIView.animate(withDuration: TimeInterval(animationDuration), delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
                self.move(to: newCenter, rotateAngle: rotateAngle)
                self.getHudView().setNeedsDisplay()
            })
        } else {
            move(to: newCenter, rotateAngle: rotateAngle)
        }
    }

    private func updateViewHierarchy() {
        // Add the overlay to the application window if necessary
        if getControlView().superview == nil {
            if containerView != nil {
                self.containerView!.addSubview(getControlView())
//                self.frame = containerView!.frame
            } else {
                if IHProgressHUD.isNotAppExtension {
                if self.containerView != nil {
                    containerView?.addSubview(getControlView())
                } else {
                    getFrontWindow()?.addSubview(getControlView())
                    }
                }
                else {
                // If IHProgressHUD is used inside an app extension add it to the given view
                if viewForExtension != nil {
                     viewForExtension!.addSubview(getControlView())
                    }
                }
            }
        } else {
            // The HUD is already on screen, but maybe not in front. Therefore
            // ensure that overlay will be on top of rootViewController (which may
            // be changed during runtime).
                getControlView().superview?.bringSubviewToFront(getControlView())
        }
        
        // Add self to the overlay view
        if superview == nil {
            getControlView().addSubview(self)
        }
    }

    private func cancelIndefiniteAnimatedViewAnimation(){
        self.indefiniteAnimatedView?.stopActivityIndicator()
        self.indefiniteAnimatedView?.removeFromSuperview()
    }

    private func cancelRingLayerAnimation() {
        // Animate value update, stop animation
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        getHudView().layer.removeAllAnimations()
        getRingView().set(strokeEnd: 0.0)
        
        CATransaction.commit()
        
        // Remove from view
        getRingView().removeFromSuperview()
        getBackgroundRingView().removeFromSuperview()
    }
    
    // stops the activity indicator, shows a glyph + status, and dismisses the HUD a little bit later
    
    private func show(image: UIImage, status: String?, duration: TimeInterval) {
        OperationQueue.main.addOperation({ [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.setFadeOut(timer: nil)
            strongSelf.setGrace(timer: nil)
            strongSelf.updateViewHierarchy()
            
            strongSelf.progress = Float(IHProgressHUDUndefinedProgress)
            strongSelf.cancelRingLayerAnimation()
            strongSelf.cancelIndefiniteAnimatedViewAnimation()
            
            if strongSelf.shouldTintImages {
                if image.renderingMode != UIImage.RenderingMode.alwaysTemplate {
                    strongSelf.getImageView().image = image.withRenderingMode(.alwaysTemplate)
                    strongSelf.getImageView().tintColor = strongSelf.foreGroundColorForStyle()
                } else {
                    strongSelf.getImageView().image = image
                }
            }
            strongSelf.getImageView().isHidden = false
            
            strongSelf.getStatusLabel().isHidden = status == nil || status?.count == 0
            if let stts = status {
                strongSelf.getStatusLabel().text = stts
            }
            if (strongSelf.graceTimeInterval > 0.0 && strongSelf.getBackGroundView().alpha == 0.0) {
                let timer = Timer.init(timeInterval: strongSelf.graceTimeInterval, target: strongSelf, selector: #selector(strongSelf.fadeIn(_:)), userInfo: duration, repeats: false)
                strongSelf.setGrace(timer: timer)
                RunLoop.main.add(strongSelf.graceTimer!, forMode: .common)
            } else {
                strongSelf.fadeIn(duration as AnyObject)
            }
        })
    }
    // shows a image + status, use white PNGs with the imageViewSize (default is 28x28 pt)
    
    private func dismissWithDelay(_ delay: TimeInterval, completion: (() -> Void)?) {
        OperationQueue.main.addOperation({ [weak self] in
            guard let strongSelf = self else { return }
                // Stop timer
                strongSelf.setGrace(timer: nil)
                // Post notification to inform user
                NotificationCenter.default.post(name: NotificationName.IHProgressHUDWillDisappear.getNotificationName(), object: nil, userInfo: strongSelf.notificationUserInfo())
                
                // Reset activity count
                strongSelf.activityCount = 0
                
                let animationsBlock: () -> Void = {
                    // Shrink HUD a little to make a nice disappear animation
                    strongSelf.getHudView().transform = strongSelf.getHudView().transform.scaledBy(x: 1 / 1.3, y: 1 / 1.3)
                    
                    // Fade out all effects (colors, blur, etc.)
                    strongSelf.fadeOutEffects()
                }
                
                let completionBlock: (() -> Void) = {
                    // Check if we really achieved to dismiss the HUD (<=> alpha values are applied)
                    // and the change of these values has not been cancelled in between e.g. due to a new show
                    if strongSelf.getBackGroundView().alpha == 0.0 {
                        // Clean up view hierarchy (overlays)
                        strongSelf.getControlView().removeFromSuperview()
                        strongSelf.getBackGroundView().removeFromSuperview()
                        strongSelf.getHudView().removeFromSuperview()
                        strongSelf.removeFromSuperview()
                        
                        // Reset progress and cancel any running animation
                        strongSelf.progress = Float(IHProgressHUDUndefinedProgress)
                        strongSelf.cancelRingLayerAnimation()
                        strongSelf.cancelIndefiniteAnimatedViewAnimation()
                        
                        // Remove observer <=> we do not have to handle orientation changes etc.
                            NotificationCenter.default.removeObserver(strongSelf)
                        // Post notification to inform user
                        //IHProgressHUDDidDisappearNotification
                        NotificationCenter.default.post(name: NotificationName.IHProgressHUDDidDisappear.getNotificationName(), object: strongSelf, userInfo: strongSelf.notificationUserInfo())
                        
                        // Tell the rootViewController to update the StatusBar appearance
                        #if os(iOS)
                        if IHProgressHUD.isNotAppExtension {
                        let rootController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
                        rootController?.setNeedsStatusBarAppearanceUpdate()
                        }
                        #endif
                        if completion != nil {
                            completion!()
                        }
                        // Run an (optional) completionHandler
                        
                    }
                }
                
                // UIViewAnimationOptionBeginFromCurrentState AND a delay doesn't always work as expected
                // When UIViewAnimationOptionBeginFromCurrentState is set, animateWithDuration: evaluates the current
                // values to check if an animation is necessary. The evaluation happens at function call time and not
                // after the delay => the animation is sometimes skipped. Therefore we delay using dispatch_after.
                
                let dipatchTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC)))
                DispatchQueue.main.asyncAfter(deadline: dipatchTime, execute: {
                    if strongSelf.fadeOutAnimationDuration > 0 {
                            UIView.animate(withDuration: strongSelf.fadeOutAnimationDuration, delay: 0, options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState], animations: {
                                animationsBlock()
                            }) { finished in
                                completionBlock()
                            }
                    }else {
                        animationsBlock()
                        completionBlock()
                    }
                })
                
                // Inform iOS to redraw the view hierarchy
                strongSelf.setNeedsDisplay()
        }
    )
    }
    
    @objc private func dismiss() {
        dismissWithDelay(0.0, completion: nil)
    }
    
    private func setStatus(_ status: String?) {
        getStatusLabel().text = status
        updateHUDFrame()
    }
    
    private func updateHUDFrame() {
        // Check if an image or progress ring is displayed
        let imageUsed: Bool = (getImageView().image) != nil && !((getImageView().isHidden) )
        let progressUsed: Bool = getImageView().isHidden

        // Calculate size of string
        var labelRect : CGRect = CGRect.zero
        var labelHeight: CGFloat = 0.0
        var labelWidth: CGFloat = 0.0

        if getStatusLabel().text != nil {
            let constraintSize = CGSize(width: 200.0, height: 300.0)
            labelRect = getStatusLabel().text?.boundingRect(with: constraintSize, options: [.usesFontLeading, .truncatesLastVisibleLine, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: getStatusLabel().font], context: nil) ?? CGRect.zero
            labelHeight = CGFloat(ceilf(Float(labelRect.height )))
            labelWidth = CGFloat(ceilf(Float(labelRect.width )))
        }

        // Calculate hud size based on content
        // For the beginning use default values, these
        // might get update if string is too large etc.
        var hudWidth: CGFloat
        var hudHeight: CGFloat

        var contentWidth: CGFloat = 0.0
        var contentHeight: CGFloat = 0.0

        if (imageUsed || progressUsed) {
            if imageUsed {
                contentWidth = getImageView().frame.width
                contentHeight = getImageView().frame.height
            } else {
                contentWidth = getIndefiniteAnimatedView().frame.width
                contentHeight = getIndefiniteAnimatedView().frame.height
            }
        }
        // |-spacing-content-spacing-|
        hudWidth = CGFloat(IHProgressHUDHorizontalSpacing + max(labelWidth, contentWidth) + IHProgressHUDHorizontalSpacing)

        // |-spacing-content-(labelSpacing-label-)spacing-|
        hudHeight = CGFloat(IHProgressHUDVerticalSpacing) + labelHeight + contentHeight + CGFloat(IHProgressHUDVerticalSpacing)
        if ((getStatusLabel().text != nil) && (imageUsed || progressUsed )) {
            // Add spacing if both content and label are used
            hudHeight += CGFloat(IHProgressHUDLabelSpacing)//8 [80]
        }

        // Update values on subviews
        getHudView().bounds = CGRect(x: 0.0, y: 0.0, width: max(minimumSize.width, hudWidth), height: max(minimumSize.height, hudHeight))

        // Animate value update
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        // Spinner and image view
        var centerY: CGFloat
        if getStatusLabel().text != nil {
            let yOffset = max(IHProgressHUDVerticalSpacing, (minimumSize.height - contentHeight - CGFloat(IHProgressHUDLabelSpacing) - labelHeight) / 2.0)//12
            centerY = yOffset + contentHeight / 2.0 //26
        } else {
            centerY = getHudView().bounds.midY
        }
        getIndefiniteAnimatedView().center = CGPoint(x: getHudView().bounds.midX, y: centerY)
        if CGFloat(progress) != IHProgressHUDUndefinedProgress {
            getRingView().center = CGPoint(x: getHudView().bounds.midX , y: centerY)
            getBackgroundRingView().center = getRingView().center
        }
        getImageView().center = CGPoint(x: getHudView().bounds.midX , y: centerY)
        // Label
        if imageUsed || progressUsed {
            if imageUsed {
                centerY = getImageView().frame.maxY + IHProgressHUDLabelSpacing + labelHeight / 2.0
            } else {
                centerY = getIndefiniteAnimatedView().frame.maxY + IHProgressHUDLabelSpacing + labelHeight / 2.0
            }
        } else {
            centerY = getHudView().bounds.midY
        }
        getStatusLabel().frame = labelRect
        getStatusLabel().center = CGPoint(x: getHudView().bounds.midX , y: centerY)
        CATransaction.commit()
    }

    private func registerNotifications() {
        #if os(iOS)
        NotificationCenter.default.addObserver(self, selector: #selector(positionHUD(_:)), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.positionHUD(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.positionHUD(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.positionHUD(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.positionHUD(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        #endif
        NotificationCenter.default.addObserver(self, selector: #selector(self.positionHUD(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func fadeOutEffects() {
        if defaultStyle == .custom {
            getHudView().effect = nil
        }
        getHudView().backgroundColor = .clear
        getBackGroundView().alpha = 0.0
        
        getImageView().alpha = 0.0
        getStatusLabel().alpha = 0.0
        getIndefiniteAnimatedView().alpha = 0.0
        getRingView().alpha = 0
        getBackgroundRingView().alpha = 0
    }//
    
    private func getBackgroundRingView() -> ProgressAnimatedView {
        if backgroundRingView == nil {
            backgroundRingView = ProgressAnimatedView.init(frame: .zero)
            backgroundRingView?.set(strokeEnd: 1.0)
        }
        
        backgroundRingView?.set(strokeColor: foreGroundColorForStyle().withAlphaComponent(0.1))
        backgroundRingView?.set(strokeThickness: ringThickness)
        
        var radius : CGFloat = 0.0
        if getStatusLabel().text != nil {
            radius = ringRadius
        } else {
            radius = ringNoTextRadius
        }
        backgroundRingView?.set(radius: radius)
        return backgroundRingView!
    }
    
    private func getRingView() -> ProgressAnimatedView {
        if ringView == nil {
            ringView = ProgressAnimatedView.init(frame: .zero)
        }
        
        ringView?.set(strokeThickness: ringThickness)
        ringView?.set(strokeColor: foreGroundColorForStyle())
        var radius : CGFloat = 0.0
        if getStatusLabel().text != nil {
            radius = ringRadius
        } else {
            radius = ringNoTextRadius
        }
        ringView?.set(radius: radius)
        
        return ringView!
    }
    
    private func getImageView() -> UIImageView {
        if imageView != nil && imageView?.bounds.size != imageViewSize {
            imageView?.removeFromSuperview()
            imageView = nil
        }
        
        if imageView == nil {
            imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: imageViewSize.width, height: imageViewSize.height))
        }
        if imageView?.superview == nil {
            getHudView().contentView.addSubview(imageView!)
        }
        
        return imageView!
    }
    
    private func getStatusLabel() -> UILabel {
        if statusLabel == nil {
            statusLabel = UILabel.init(frame: .zero)
            statusLabel?.backgroundColor = .clear
            statusLabel?.adjustsFontSizeToFitWidth = true
            statusLabel?.textAlignment = .center
            statusLabel?.baselineAdjustment = .alignCenters
            statusLabel?.numberOfLines = 0
        }
        if statusLabel?.superview == nil && statusLabel != nil {
            getHudView().contentView.addSubview(statusLabel!)
        }
        statusLabel?.textColor = foreGroundColorForStyle()
        statusLabel?.font = font
        statusLabel?.alpha = 1.0
        statusLabel?.isHidden = false
        return statusLabel!
    }
    
    private func fadeInEffects() {
        if defaultStyle != .custom {
            var blurStyle = UIBlurEffect.Style.light
            if defaultStyle == .dark {
                blurStyle = UIBlurEffect.Style.light
            }
            let blurEffect = UIBlurEffect.init(style: blurStyle)
            getHudView().effect = blurEffect
            
            getHudView().backgroundColor = backgroundColorForStyle().withAlphaComponent(0.6)
        } else {
            getHudView().backgroundColor = backgroundColorForStyle()
        }
        
        getBackGroundView().alpha = 1.0
        getImageView().alpha = 1.0
        getIndefiniteAnimatedView().alpha = 1.0
        getRingView().alpha = 1.0
        getBackgroundRingView().alpha = 1.0
    }
    
    private func backgroundColorForStyle() -> UIColor {
        if defaultStyle == .light {
            return .white
        } else if defaultStyle == .dark {
            return .black
        } else {
            let color = hudBackgroundColor ?? backgroundColor!
            return color
        }
    }
    
    private func getFrontWindow() -> UIWindow? {
        if IHProgressHUD.isNotAppExtension {
        let frontToBackWindows: NSEnumerator = (UIApplication.shared.windows as NSArray).reverseObjectEnumerator()
        for window in frontToBackWindows {
            guard let win : UIWindow = window as? UIWindow else {return nil}
            let windowOnMainScreen: Bool = win.screen == UIScreen.main
            let windowIsVisible: Bool = !win.isHidden && (win.alpha > 0)
            var windowLevelSupported = false
            windowLevelSupported = win.windowLevel >= UIWindow.Level.normal && win.windowLevel <= maxSupportedWindowLevel
            
            let windowKeyWindow = win.isKeyWindow

            if windowOnMainScreen && windowIsVisible && windowLevelSupported && windowKeyWindow {
                return win
                }
            }
        }
        return nil
    }
    
    private func getVisibleKeyboardHeight() -> CGFloat {
        if IHProgressHUD.isNotAppExtension {
        var keyboardWindow : UIWindow? = nil
        for testWindow in UIApplication.shared.windows {
            if !testWindow.self.isEqual(UIWindow.self) {
                keyboardWindow = testWindow
                break
            }
        }
        for possibleKeyboard in keyboardWindow?.subviews ?? [] {
            var viewName = String.init(describing: possibleKeyboard.self)
            if viewName.hasPrefix("UI") {
                if viewName.hasSuffix("PeripheralHostView") || viewName.hasSuffix("Keyboard") {
                    return possibleKeyboard.bounds.height
                } else if viewName.hasSuffix("InputSetContainerView") {
                    for possibleKeyboardSubview: UIView? in possibleKeyboard.subviews {
                        viewName = String.init(describing: possibleKeyboardSubview.self)
                        if viewName.hasPrefix("UI") && viewName.hasSuffix("InputSetHostView") {
                            let convertedRect = possibleKeyboard.convert(possibleKeyboardSubview?.frame ?? CGRect.zero, to: self)
                            let intersectedRect: CGRect = convertedRect.intersection(bounds)
                            if !intersectedRect.isNull {
                                return intersectedRect.height
                            }
                        }
                    }
                }
            }
        }
        }
        return 0
    }
    
    #if os(iOS)
    private func updateMotionEffectForOrientation(_ orientation: UIInterfaceOrientation) {
        let xMotionEffectType: UIInterpolatingMotionEffect.EffectType = orientation.isPortrait ? .tiltAlongHorizontalAxis : .tiltAlongVerticalAxis
        let yMotionEffectType: UIInterpolatingMotionEffect.EffectType = orientation.isPortrait ? .tiltAlongVerticalAxis : .tiltAlongHorizontalAxis
        updateMotionEffect(forXMotionEffectType: xMotionEffectType, yMotionEffectType: yMotionEffectType)
    }
    #endif

    private func updateMotionEffect(forXMotionEffectType xMotionEffectType: UIInterpolatingMotionEffect.EffectType, yMotionEffectType: UIInterpolatingMotionEffect.EffectType) {
        let effectX = UIInterpolatingMotionEffect(keyPath: "center.x", type: xMotionEffectType)
        effectX.minimumRelativeValue = -IHProgressHUDParallaxDepthPoints
        effectX.maximumRelativeValue = IHProgressHUDParallaxDepthPoints
        
        let effectY = UIInterpolatingMotionEffect(keyPath: "center.y", type: yMotionEffectType)
        effectY.minimumRelativeValue = -IHProgressHUDParallaxDepthPoints
        effectY.maximumRelativeValue = IHProgressHUDParallaxDepthPoints
        
        let effectGroup = UIMotionEffectGroup()
        effectGroup.motionEffects = [effectX, effectY]
        
        // Clear old motion effect, then add new motion effects
        getHudView().motionEffects = []
        getHudView().addMotionEffect(effectGroup)
    }

    private func move(to newCenter: CGPoint, rotateAngle angle: CGFloat) {
        getHudView().transform = CGAffineTransform(rotationAngle: angle)
        guard let container = containerView else {
            getHudView().center = CGPoint(x: newCenter.x + offsetFromCenter.horizontal, y: newCenter.y + offsetFromCenter.vertical)
            return
        }
            getHudView().center = CGPoint(x: container.center.x + offsetFromCenter.horizontal, y: container.center.y + offsetFromCenter.vertical)
    }
}

extension IHProgressHUD {
    
    public class func set(defaultStyle style: IHProgressHUDStyle) {
        sharedView.defaultStyle = style
    }
    
    public class func setHUD(backgroundColor color: UIColor) {
        sharedView.defaultStyle = .custom
        sharedView.hudBackgroundColor = color
    }
    
    public class func set(defaultMaskType maskType: IHProgressHUDMaskType) {
        sharedView.defaultMaskType = maskType
    }
    
    public class func set(defaultAnimationType type: IHProgressHUDAnimationType) {
        sharedView.defaultAnimationType = type
    }
    
    public class func set(status: String?) {
        sharedView.setStatus(status)
    }
    
    public class func set(containerView: UIView?) {
        sharedView.containerView = containerView
    } // default is window level
    
    public class func set(minimumSize: CGSize) {
        sharedView.minimumSize = minimumSize
    }
    
    // default is CGSizeZero, can be used to avoid resizing for a larger message
    
    public class func set(ringThickness: CGFloat) {
        sharedView.ringThickness = ringThickness
    } // default is 2 pt
    
    public class func set(ringRadius : CGFloat) {
        sharedView.ringRadius = ringRadius
    }// default is 18 pt
    
    public class func setRing(noTextRingRadius radius: CGFloat) {
        sharedView.ringNoTextRadius = radius
    } // default is 24 pt
    
    public class func set(cornerRadius: CGFloat) {
        sharedView.cornerRadius = cornerRadius
    }// default is 14 pt
    
    public class func set(borderColor color : UIColor) {
        sharedView.getHudView().layer.borderColor = color.cgColor
        
    }// default is nil
    
    public class func set(borderWidth width: CGFloat) {
        sharedView.getHudView().layer.borderWidth = width
    }// default is 0
    
    public class func set(font: UIFont) {
        sharedView.font = font
    } // default is [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
    
    public class func set(foregroundColor color: UIColor) {
        sharedView.foregroundColor = color
//        sharedView.defaultStyle = .custom
    }
    // default is [UIColor blackColor], only used for ProgressHUDStyleCustom
    
    public class func set(backgroundColor color: UIColor) {
        sharedView.backgroundColor = color
        sharedView.defaultStyle = .custom
    } // default is [UIColor whiteColor], only used for ProgressHUDStyleCustom
    
    public class func set(backgroundLayerColor color: UIColor) {
        sharedView.backgroundLayerColor = color
    } // default is [UIColor colorWithWhite:0 alpha:0.5], only used for ProgressHUDMaskTypeCustom
    
    public class func set(imageViewSize size: CGSize) {
        sharedView.imageViewSize = size
    } // default is 28x28 pt
    
    public class func set(shouldTintImages: Bool) {
        sharedView.shouldTintImages = shouldTintImages
    } // default is YES
    
    public class func set(infoImage image: UIImage) {
        sharedView.infoImage = image
    } // default is the bundled info image provided by Freepik
    
    public class func setSuccessImage(successImage image: UIImage) {
        sharedView.successImage = image
    } // default is the bundled success image provided by Freepik
    
    public class func setErrorImage(errorImage image: UIImage) {
        sharedView.errorImage = image
    } // default is the bundled error image provided by Freepik
    
    public class func set(viewForExtension view: UIView) {
        IHProgressHUD.isNotAppExtension = false
        sharedView.viewForExtension = view
    }// default is nil, only used if #define SV_APP_EXTENSIONS is set
    
    public class func set(graceTimeInterval interval: TimeInterval) {
        sharedView.graceTimeInterval = interval
    } // default is 0 seconds
    
    public class func set(minimumDismiss interval: TimeInterval) {
        sharedView.minimumDismissTimeInterval = interval
    } // default is 5.0 seconds
    
    public class func set(maximumDismissTimeInterval interval: TimeInterval) {
        sharedView.maximumDismissTimeInterval = interval
    } // default is infinite
    
    public class func setFadeInAnimationDuration(fadeInAnimationDuration duration: TimeInterval) {
        sharedView.fadeInAnimationDuration = duration
    } // default is 0.15 seconds
    
    public class func setFadeOutAnimationDuration(fadeOutAnimationDuration duration: TimeInterval) {
        sharedView.fadeOutAnimationDuration = duration
    } // default is 0.15 seconds
    
    public class func setMaxSupportedWindowLevel(maxSupportedWindowLevel windowLevel: UIWindow.Level) {
        sharedView.maxSupportedWindowLevel = windowLevel
    } // default is UIWindowLevelNormal
    
    public class func setHapticsEnabled(hapticsEnabled: Bool) {
        sharedView.hapticsEnabled = hapticsEnabled
    } // default is NO
    
    
    // MARK: - Show Methods
    public class func show() {
        show(withStatus: nil)
    }
    
    public class func show(withStatus status: String?) {
        show(progress: IHProgressHUDUndefinedProgress, status: status)
    }
    
    public class func show(progress: CGFloat) {
        show(progress: progress, status: nil)
    }
    
    public class func show(progress: CGFloat, status: String?) {
        sharedView.showProgress(progress: Float(progress), status: status)
    }
    
    public class func setOffsetFromCenter(_ offset: UIOffset) {
        sharedView.offsetFromCenter = offset
    }
    
    public class func resetOffsetFromCenter() {
        setOffsetFromCenter(.zero)
    }
    
    public class func popActivity() {
        if sharedView.activityCount > 0 {
            sharedView.activityCount -= 1
        }
        if sharedView.activityCount == 0 {
            sharedView.dismiss()
        }
    } // decrease activity count, if activity count == 0 the HUD is dismissed
    
    public class func dismiss() {
        dismissWithDelay(0.0)
    }
    
    public class func dismissWithCompletion(_ completion: (() -> Void)?) {
        dismissWithDelay(0.0, completion: completion)
    }
    
    public class func dismissWithDelay(_ delay: TimeInterval) {
        dismissWithDelay(delay, completion: nil)
    }
    
    public class func dismissWithDelay(_ delay: TimeInterval, completion: (() -> Void)?) {
        sharedView.dismissWithDelay(delay, completion: completion)
    }

    public class func isVisible() -> Bool {
        return sharedView.getBackGroundView().alpha > 0.0
    }
    
    public class func displayDurationForString(_ string:String?) -> TimeInterval {
        let minimum = max(CGFloat(string?.count ?? 0) * 0.06 + 0.5, CGFloat(sharedView.minimumDismissTimeInterval))
        return TimeInterval(min(minimum, CGFloat(sharedView.maximumDismissTimeInterval)))
    }
    
    public class func showInfowithStatus(_ status: String?) {
        showImage(sharedView.infoImage, status: status)
        #if os(iOS)
        if #available(iOS 10.0, *) {
            sharedView.hapticGenerator?.notificationOccurred(.warning)
        }
        #endif
    }
    
    public class func showImage(_ image: UIImage, status: String?) {
        let displayInterval = displayDurationForString(status)
        sharedView.show(image: image, status: status, duration: displayInterval)
    }
    
    public class func showSuccesswithStatus(_ status: String?) {
        showImage(sharedView.successImage, status: status)
        #if os(iOS)
        if #available(iOS 10.0, *) {
            sharedView.hapticGenerator?.notificationOccurred(.success)
        }
        #endif
    }
    
    public class func showError(withStatus status: String?) {
        showImage(sharedView.errorImage, status: status)
        #if os(iOS)
        if #available(iOS 10.0, *) {
            sharedView.hapticGenerator?.notificationOccurred(.error)
        }
        #endif
    }
}
//MARK: -
extension IHProgressHUD {
    private func setGrace(timer: Timer?) {
        if (graceTimer != nil) {
            graceTimer?.invalidate()
            graceTimer = nil
        } else {
            if timer != nil {
                graceTimer = timer
            }
        }
    }
    
    private func setFadeOut(timer: Timer?) {
        if (fadeOutTimer != nil) {
            fadeOutTimer?.invalidate()
            fadeOutTimer = nil
        }
        if timer != nil {
            fadeOutTimer = timer
        }
    }
}

//MARK: - Instance Getter Methods
extension IHProgressHUD {
    private func foreGroundColorForStyle() -> UIColor {
        guard let color = foregroundColor else {
            if defaultStyle == .light {
                return .black
            } else if defaultStyle == .dark {
                return .white
            } else {
                return .black
            }
        }
        return color
    }
    
    private func getHudView() -> UIVisualEffectView {
        if hudView == nil {
            let tmphudView = UIVisualEffectView()
            tmphudView.layer.masksToBounds = true
            tmphudView.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleLeftMargin]
            hudView = tmphudView
            hudView?.accessibilityLabel = "HUD View"
        }
        
        if hudView?.superview == nil {
            self.addSubview(hudView!)
        }
        
        hudView?.layer.cornerRadius = cornerRadius
        return hudView!
    }
    
    private func getBackGroundView() -> UIView {
        if backgroundView == nil {
            backgroundView = UIView()
            backgroundView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        if backgroundView?.superview == nil {
            insertSubview(self.backgroundView!, belowSubview: getHudView())
        }
        // Update styling
        if defaultMaskType == .gradient {
            if (backgroundRadialGradientLayer == nil) {
                backgroundRadialGradientLayer = RadialGradientLayer()
            }
            if (backgroundRadialGradientLayer?.superlayer == nil) {
                backgroundView!.layer.insertSublayer(backgroundRadialGradientLayer!, at: 0)
            }
        } else {
            if ((backgroundRadialGradientLayer != nil) && (backgroundRadialGradientLayer?.superlayer != nil)) {
                backgroundRadialGradientLayer?.removeFromSuperlayer()
            }
            if defaultMaskType == .black {
                backgroundView?.backgroundColor = UIColor(white: 0, alpha: 0.4)
            } else if defaultMaskType == .custom {
                backgroundView?.backgroundColor = backgroundLayerColor
            } else {
                backgroundView?.backgroundColor = UIColor.clear
            }
        }
        
        // Update frame
        if backgroundView != nil {
            backgroundView?.frame = bounds
        }
        if backgroundRadialGradientLayer != nil {
            backgroundRadialGradientLayer?.frame = bounds
            
            // Calculate the new center of the gradient, it may change if keyboard is visible
            var gradientCenter: CGPoint = center
            gradientCenter.y = (bounds.size.height - visibleKeyboardHeight) / 2
            backgroundRadialGradientLayer?.gradientCenter = gradientCenter
            backgroundRadialGradientLayer?.setNeedsDisplay()
        }
        return backgroundView!
    }
    
    private func getControlView() -> UIControl {
        if controlView == nil {
            controlView = UIControl.init()
            controlView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            controlView?.backgroundColor = .clear
            controlView?.isUserInteractionEnabled = true
            controlView?.addTarget(self, action: #selector(controlViewDidReceiveTouchEvent(_:for:)), for: .touchDown)
        }
        if IHProgressHUD.isNotAppExtension {
        if let windowBounds : CGRect = UIApplication.shared.delegate?.window??.bounds {
            controlView?.frame = windowBounds
            }
        }
        else {
        controlView?.frame = UIScreen.main.bounds
        }
        return controlView!
    }
    
    private func loadImageBundle(named imageName:String) -> UIImage? {
        var imageBundle = Bundle.init(for: IHProgressHUD.self)
        if let resourcePath = imageBundle.path(forResource: "IHProgressHUD", ofType: "bundle") {
            if let resourcesBundle = Bundle(path: resourcePath) {
                imageBundle = resourcesBundle
            }
        }
        
        return (UIImage(named: imageName, in: imageBundle, compatibleWith: nil))
    }
}
