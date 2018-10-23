//
//  ZD_ConnectionCheck.swift
//  ZeroDesk
//
//  Created by Apple  on 16/11/17.
//  Copyright © 2017 Apple . All rights reserved.
//

import UIKit

protocol ZD_ConnectionCheckDelegate {
    func webConfigErrorOccur(message : NSString) -> Void
}
class ZD_ConnectionCheck: NSObject {
    
    var isConnected             : Bool = false;
    var isApiWorking            : Bool = false;
    var delegate                : ZD_ConnectionCheckDelegate?;
    static let sharedInstance   = ZD_ConnectionCheck();
    
    func startCalls () {
        isApiWorking = false
        NotificationCenter.default.addObserver(self, selector: #selector(networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil);
        ZD_Reach().monitorReachabilityChanges();
        checkNetStat();
    }
    
    //MARK : Check connection status
    func checkNetStat() {
        let status = ZD_Reach().connectionStatus()
        switch status {
        case .unknown, .offline:
            print("Not connected");
            isConnected = false;
            break;
        case .online(.wwan):
            print("Connected via WWAN")
            isConnected = true;
            break;
        case .online(.wiFi):
            print("Connected via WiFi")
            isConnected = true;
            break;
        }
    }
    
    //MARK : notify the current status of internet connection
    @objc func networkStatusChanged(_ notification: Notification)
    {
        let userInfo = (notification as NSNotification).userInfo
        print(userInfo!);
        checkNetStat();
        
        //MARK : Fetch the name of current VIEWController class
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            let className : NSString = NSStringFromClass(topController.classForCoder) as NSString
            
            if isConnected {
                print("isApiWorking : \(isApiWorking)")
                if (className.isEqual(to: "RunMyRoute.ActivityLogVC")) {
                    
                }
                else {
                    
                }
            }
            else {
                //MARK : Stop offline sync
                self.stopOfflineSynching()
            }
        }
    }
    
    //MARK : Offline data sync delegates methods
    func startOfflineSynching () {
        
    }
    
    func stopOfflineSynching () {
        print("stopOfflineSynching")
    }
}

