//
//  Converted to Swift 4 by Swiftify v4.2.29618 - https://objectivec2swift.com/
//
//  ViewController.swift
//  IHProgressHUD : Inspired by IHProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//  Created by mdibrahimhassan@gmail.com on 11/20/2018.
//  Copyright (c) 2018 mdibrahimhassan@gmail.com. All rights reserved.
//

import UIKit
import IHProgressHUD

class ViewController : UIViewController {
    
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var popActivityButton: UIButton!
    
    private var progress: CGFloat = 0.0
    
    private var activityCount = 0 {
        didSet {
            popActivityButton.setTitle("popActivity - \(activityCount)", for: .normal)
        }
    }
    
    // MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        activityCount = 0
//        IHProgressHUD.setHUD(backgroundColor: UIColor.blue)
        addObserver(self, forKeyPath: "activityCount", options: .new, context: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handle(_:)), name: NotificationName.IHProgressHUDWillAppear.getNotificationName(), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handle(_:)), name: NotificationName.IHProgressHUDDidAppear.getNotificationName(), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handle(_:)), name: NotificationName.IHProgressHUDWillDisappear.getNotificationName(), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handle(_:)), name: NotificationName.IHProgressHUDDidAppear.getNotificationName(), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handle(_:)), name: NotificationName.IHProgressHUDDidReceiveTouchEvent.getNotificationName(), object: nil)
        
        addObserver(self as NSObject, forKeyPath: "activityCount", options: .new, context: nil)
    }
    
    @IBAction func show(_ sender: UIButton) {
        DispatchQueue.global(qos: .utility).async {
            IHProgressHUD.show()
        }
        self.activityCount += 1
    }
    
    @IBAction func showWithStatus(_ sender: UIButton) {
        activityCount += 1
        IHProgressHUD.show(withStatus: "Show with Status")
        activityCount += 1
    }
    
    @IBAction func showWithProgress(_ sender: UIButton) {
        activityCount += 1
        progress = 0.0
        IHProgressHUD.show(progress: 0, status: "Show Progress")
        perform(#selector(ViewController.increaseProgress), with: nil, afterDelay: 0.1)
    }
    
    @IBAction func showInfoWithStatus(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            IHProgressHUD.showInfowithStatus("Useful Information.")
        }
    }
    
    
    @IBAction func showSuccessWithStatus(_ sender: Any) {
        IHProgressHUD.showSuccesswithStatus("Status Sucess")
    }
    
    @IBAction func showErrorWithStatus(_ sender: UIButton) {
        IHProgressHUD.showInfowithStatus("Status Error")
    }
    
    @IBAction func DISMISS(_ sender: UIButton) {
        DispatchQueue.global(qos: .background).async {
            IHProgressHUD.dismissWithCompletion({
                print ("Dismissed")
            })
        }
        if activityCount != 0 {
            activityCount -= 1
        }
    }
    
    @IBAction func popActivity(_ sender: UIButton) {
        IHProgressHUD.popActivity()
        if activityCount != 0 {
            activityCount -= 1
        }
    }
    
    @IBAction func changeStyle(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            IHProgressHUD.set(defaultStyle: .light)
        } else {
            IHProgressHUD.set(defaultStyle: .dark)
        }
    }
    
    @IBAction func AnimationStyle(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            IHProgressHUD.set(defaultAnimationType: .flat)
        } else {
            IHProgressHUD.set(defaultAnimationType: .native)
        }
    }
    
    
    @IBAction func setMaskType(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            IHProgressHUD.set(defaultMaskType: .none)
        } else if sender.selectedSegmentIndex == 1 {
            IHProgressHUD.set(defaultMaskType: .clear)
        } else if sender.selectedSegmentIndex == 2 {
            IHProgressHUD.set(defaultMaskType: .black)
        } else if sender.selectedSegmentIndex == 3 {
            IHProgressHUD.set(defaultMaskType: .gradient)
        } else {
            IHProgressHUD.set(defaultMaskType: .gradient)
        }
    }
    
    // MARK: - Notification handling
    @objc func handle(_ notification: Notification?) {
        if let aName = notification?.name {
            print("Notification received: \(aName)")
        }
        if let aKey = notification?.userInfo?[NotificationName.IHProgressHUDStatusUserInfoKey.getNotificationName()] {
            print("Status user info key: \(aKey)")
        }
        if notification?.name.rawValue == "IHProgressHUDDidReceiveTouchEvent" {
            closeProgress()
        }
        if ((notification?.name)!.rawValue == "IHProgressHUDDidReceiveTouchEvent") {
            closeProgress()
        }
    }
    
    @objc func increaseProgress() {
        progress += 0.1
        IHProgressHUD.show(progress: progress, status: "Here is a very large text. Hello world. It is the introduction of Programming")
        if progress < 1.0 {
            perform(#selector(increaseProgress), with: nil, afterDelay: 0.1)
        } else {
            if activityCount >= 1 {
                perform(#selector(closeProgress), with: nil, afterDelay: 0.4)
            } else {
                perform(#selector(closeProgress), with: nil, afterDelay: 0.4)
            }
        }
    }
    
    @objc func closeProgress() {
        IHProgressHUD.dismiss()
        activityCount = 0
    }
}
