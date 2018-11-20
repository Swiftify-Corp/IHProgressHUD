//
//  TodayViewController.swift
//  TodayExtenionDemo
//
//  Created by Ibrahim Hassan on 20/11/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import NotificationCenter
import IHProgressHUD

class TodayViewController: UIViewController, NCWidgetProviding {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IHProgressHUD.set(defaultMaskType: .gradient)
        IHProgressHUD.set(defaultStyle: .dark)
        IHProgressHUD.set(viewForExtension: self.view)
        IHProgressHUD.show()
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
