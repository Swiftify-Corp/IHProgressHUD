//
//  ViewController.swift
//  tvOSSample
//
//  Created by Ibrahim Hassan on 20/11/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import IHProgressHUD

class ViewController: UIViewController {
    
    @IBOutlet weak var controlView: UIView!
    
    private var progress: CGFloat = 0.0
    
    // MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //IHProgressHUD.setHUD(backgroundColor: UIColor.blue)
        //        addObserver(self, forKeyPath: "activityCount", options: .new, context: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handle(_:)), name: NotificationName.IHProgressHUDWillAppear.getNotificationName(), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handle(_:)), name: NotificationName.IHProgressHUDDidAppear.getNotificationName(), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handle(_:)), name: NotificationName.IHProgressHUDWillDisappear.getNotificationName(), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handle(_:)), name: NotificationName.IHProgressHUDDidAppear.getNotificationName(), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handle(_:)), name: NotificationName.IHProgressHUDDidReceiveTouchEvent.getNotificationName(), object: nil)
        
        addObserver(self as NSObject, forKeyPath: "activityCount", options: .new, context: nil)
    }
    
    @IBAction func show(_ sender: UIButton) {
        DispatchQueue.global(qos: .utility).async {
            IHProgressHUD.show()
        }
    }
    
    @IBAction func showWithStatus(_ sender: UIButton) {
        IHProgressHUD.show(withStatus: "Show with Status")
    }
    
    @IBAction func showWithProgress(_ sender: UIButton) {
        progress = 0.0
        IHProgressHUD.show(progress: 0, status: "Show Progress")
        perform(#selector(increaseProgress), with: nil, afterDelay: 0.1)
    }
    
    @IBAction func showInfoWithStatus(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            IHProgressHUD.showInfowithStatus("Useful Information.")
        }
    }
    
    
    @IBAction func showSuccessWithStatus(_ sender: Any) {
        IHProgressHUD.showSuccesswithStatus("Status Success")
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
    }
    
    @IBAction func popActivity(_ sender: UIButton) {
        IHProgressHUD.popActivity()
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
        if notification?.name.rawValue == "SVProgressHUDDidReceiveTouchEvent" {
            closeProgress()
        }
        if ((notification?.name)!.rawValue == "SVProgressHUDDidReceiveTouchEvent") {
            closeProgress()
        }
    }
    
    @objc func increaseProgress() {
        progress += 0.1
        IHProgressHUD.show(progress: progress, status: "Here is a very large text. Hello world. It is the introduction of Programming")
        if progress < 1.0 {
            perform(#selector(increaseProgress), with: nil, afterDelay: 0.1)
        } else {
            perform(#selector(closeProgress), with: nil, afterDelay: 0.4)
        }
    }
    
    @objc func closeProgress() {
        IHProgressHUD.dismiss()
    }
}

