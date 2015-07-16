//
//  ViewController.swift
//  ODRefreshControlDemo
//
//  Created by Igor Smirnov on 15/04/15.
//  Copyright (c) 2015 Complex Numbers. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = ODRefreshControl(scrollView: tableView)
        refreshControl.addTarget(self, action: Selector("dropViewDidBeginRefreshing:"), forControlEvents: .ValueChanged)
    }

    override func shouldAutorotate() -> Bool {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            let interfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
            return interfaceOrientation != .PortraitUpsideDown
        } else {
            return true
        }
    }

    func dropViewDidBeginRefreshing(refreshControl: ODRefreshControl) {
        let delayInSeconds: UInt64 = 3
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * NSEC_PER_SEC))
        dispatch_after(popTime, dispatch_get_main_queue()) {
            refreshControl.endRefreshing()
        }
    }

}

