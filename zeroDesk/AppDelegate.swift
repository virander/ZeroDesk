//
//  AppDelegate.swift
//  TESTZD
//
//  Created by Apple  on 11/12/17.
//  Copyright © 2017 Apple . All rights reserved.
//

import Foundation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var crashReporter : PLCrashReporter?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        crashReporter = PLCrashReporter.shared()
        if (crashReporter?.hasPendingCrashReport())! {
            self.handleCrashReport()
        }
        if !(crashReporter?.enable())! {
            print("Warning: Could not enable crash reporter");
        }
        return true
    }
    
    func handleCrashReport() {
        var crashData : Data?;
        
        do {
            crashData = try crashReporter?.loadPendingCrashReportDataAndReturnError();
            
            //If crash data is nil
            if crashData?.base64EncodedData() == nil {
                crashReporter?.purgePendingCrashReport();
                return
            }
            self.generateCrashReport(crashData!);
        }
        catch {
            
        }
    }
    
    // We could send the report from here, but we'll just print out
    // some debugging info instead
    func generateCrashReport(_ crashData : Data) {
        
        var report : PLCrashReport;
        do {
            report = try PLCrashReport.init(data: crashData)
            if report.isKind(of: NSNull.classForCoder()) {
                crashReporter?.purgePendingCrashReport();
                return
            }
            
            //Get app crash
            let crash : NSString = PLCrashReportTextFormatter.stringValue(for: report, with: PLCrashReportTextFormatiOS)! as NSString
            
            //get app version
            let appVersion : String? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
            
            //get app PACKAGE_NAME
            let packageName = Bundle.main.bundleIdentifier!;
            
            //get systemVersion
            let systemVersion : String = UIDevice.current.systemVersion
            
            //get application start time
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-yy hh:mm:ss a"
            let START_TIME = formatter.string(from: date)
            
            //get application USER_CRASH_DATE
            let USER_CRASH_DATE = formatter.string(from: report.systemInfo.timestamp)
            
            /****************************************/
            let deviceBASE_OS = UIDevice.current.systemVersion
            let versionJson: [String: Any] = [
                "ACTIVE_CODENAMES"  : [],
                "BASE_OS"           : deviceBASE_OS,
                "CODENAME"          : "",
                "INCREMENTAL"       : 0,
                "PREVIEW_SDK_INT"   : 0,
                "RELEASE"           : 0,
                "RESOURCES_SDK_INT" : 0,
                "SDK"               : 0,
                "SDK_INT"           : 0,
                "SECURITY_PATCH"    : 0,
                ]
            
            /****************************************/
            // Swift 3
            let modelName = UIDevice.current.model
            let modelType = self.modelIdentifier()
            
            let buildJson: [String: Any] = [
                "DEVICE"    : modelName,
                "MODEL"     : modelType,
                "BOARD"     : "",
                "BOOTLOADER": "",
                "BRAND"     : "Apple",
                "CPU_ABI"   : "",
                "CPU_ABI2"  : "",
                "VERSION"   : versionJson
            ]
            
            /****************************************/
            let crashJson : [String: Any] = [
                "ANDROID_VERSION"    : systemVersion,
                "BUILD"              : buildJson,
                "STACK_TRACE"        : crash as String,
                "REPORT_ID"          : report.applicationInfo.applicationIdentifier,
                "manufacturer"       : "Apple",
                "USER_APP_START_DATE": START_TIME,
                "IS_SILENT"          : "false",
                "USER_CRASH_DATE"    : USER_CRASH_DATE,
                "PACKAGE_NAME"       : packageName,
                "APP_VERSION_NAME"   : report.applicationInfo.applicationVersion,
                "APP_VERSION_CODE"   : appVersion!,
                ]
            
            //JSON in string
            let jsonData = try? JSONSerialization.data(withJSONObject: crashJson, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            self.sendCrashReportToServer(jsonString!);
        }
        catch {
            
        }
    }
    
    func sendCrashReportToServer(_ param : String) {
        let service = ZD_ServiceClass.init();
        service.hitApiForCrashlytics(param, projectId, completionHandler: {
            resultDict , success in
            if success {
                DispatchQueue.main.async {
                    self.crashReporter?.purgePendingCrashReport();
                }
            }
            else {
                DispatchQueue.main.async {
                }
            }
        })
    }
    
    func modelIdentifier() -> String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

