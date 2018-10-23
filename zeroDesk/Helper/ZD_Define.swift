//
//  ZD_Define.swift
//  ZeroDesk
//
//  Created by Apple  on 16/11/17.
//  Copyright © 2017 Apple . All rights reserved.
//

import Foundation
import UIKit

let isAppInDevelopment = true

//MARK: Colors from Images
let _tempColor          = UIColor(patternImage: UIImage(named: "temp.png")!)
let _ThemeDarkBlue      = UIColor(red: 1/255,  green: 26/255,  blue: 39/255, alpha: 1.0)
let _ThemeGreen         = UIColor(red: 3/255,  green: 149/255,  blue: 136/255,  alpha: 1.0)
let _ThemeOrange        = UIColor(red: 247/255, green: 109/255,  blue: 60/255,  alpha: 1.0)
let _ThemeSkyBlue       = UIColor(red: 3/255, green: 155/255,  blue: 229/255,  alpha: 1.0)
let _PreviewBGColor       = UIColor(red: 54/255, green: 80/255,  blue: 89/255,  alpha: 1.0)
let _PreviewCenterBGColo = UIColor(red: 1/255,  green: 26/255,  blue: 39/255, alpha: 0.5)
let _ThemeLightGrayBlue = UIColor(red: 245/255,  green: 245/255,  blue: 245/255, alpha: 1.0)

let projectId : String = "Mp5SkVtvFH0m7J62rUBsjaXzIXFUOIGW"; //server
//let projectId : String = "9b7a276c337761fc0ed396eaf521bed3"; // local
let submitFeedbackAPI = "generate-mobile-app-ticket";
let submitCrashAPI = "submit-crash-report";

