//
//  ZD_LandingViewController.swift
//  ZeroDesk
//
//  Created by Apple  on 16/11/17.
//  Copyright © 2017 Apple . All rights reserved.
//

import UIKit

class ZD_LandingViewController: UIViewController {
    
    @IBOutlet var crashBtn : UIButton?;
    @IBOutlet var feedBackBtn : UIButton?;
    @IBOutlet var topView : UIView?;
    let tempArr = [1,2,3,4]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = _ThemeLightGrayBlue;
        topView?.backgroundColor = _ThemeDarkBlue;
        
        let spacing : CGFloat! = (crashBtn?.bounds.height)! / 3;
        
        crashBtn?.layer.cornerRadius = (crashBtn?.bounds.height)! / 2;
        crashBtn?.imageEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
        
        feedBackBtn?.layer.cornerRadius = (feedBackBtn?.bounds.height)! / 2;
        feedBackBtn?.imageEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickOnCrashBtn () {
        print("temp str : \(tempArr[4])")
    }
    
    @IBAction func clickOnFeedbackBtn () {
        let feedbackVC = self.storyboard?.instantiateViewController(withIdentifier: "ZD_FeedbackVC") as! ZD_FeedbackVC;
        self.show(feedbackVC, sender: self);
    }
}

