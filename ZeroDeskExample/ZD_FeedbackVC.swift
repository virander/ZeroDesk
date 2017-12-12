//
//  ZD_FeedbackVC.swift
//  ZeroDesk
//
//  Created by Apple  on 16/11/17.
//  Copyright © 2017 Apple . All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MapKit
import CoreLocation
import AESKit

enum ZD_FeedbackTags : Int {
    case kFeedbackImgDelete = 0,
    kFeedbackImgMax,
    kFeedbackVideoDelete,
    kFeedbackVideoMax,
    kRemoveFullView
}

class ZD_FeedbackVC: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var backBtn : UIButton?;
    @IBOutlet var topView : UIView?;
    @IBOutlet var bottomView : UIView?;
    @IBOutlet var scrollView : UIScrollView?;
    @IBOutlet var imgcontainerView : UIView?;
    @IBOutlet var nameTF : UITextField?;
    @IBOutlet var emailTF : UITextField?;
    @IBOutlet var contactTF : UITextField?;
    @IBOutlet var segmentBar : UISegmentedControl?;
    @IBOutlet var descriptionTV : UITextView?;
    @IBOutlet var descriptionCharCount : UILabel?;
    @IBOutlet var videoView : UIView?;
    @IBOutlet var imageCentreView : UIView?;
    @IBOutlet var videoCentreView : UIView?;
    @IBOutlet var imageView : UIView?;
    @IBOutlet var submitBtn : UIButton?;
    @IBOutlet var cancelBtn : UIButton?;
    var currentItem : AVPlayerItem?
    var currentImage : UIImage? = nil;
    var preview_FullView : UIView!;
    var removeFullView : UIButton!;
    var videoPlayerLayer_FullView : AVPlayerLayer!;
    var videoPlayer_FullView : AVPlayer!;
    var videoPlayerLayer : AVPlayerLayer!;
    var feedBackImgView : UIImageView?
    var videoPlayer : AVPlayer!;
    var feedbackImgDeleteBtn : UIButton?;
    var feedbackImgMaximizeBtn : UIButton?;
    var feedbackVideoDeleteBtn : UIButton?;
    var feedbackVideoMaximizeBtn : UIButton?;
    var activeTF: UITextField!;
    var activeTV: UITextView!;
    var currentOrigin: CGPoint = CGPoint(x:0,y:0);
    var isVideo : Bool! = false;
    var videodata :NSData?;
    var loaderView :UIActivityIndicatorView?;
    var feddbackType : String? = ""
    var currentCordinate : CLLocation?
    var userLocation : CLLocationManager!;
    var isNoGPSPermission : Bool? = false
    var isGPSOff : Bool? = false
    var isSubmitSuccefully : Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topView?.backgroundColor = _ThemeDarkBlue;
        self.imgcontainerView?.backgroundColor = _ThemeDarkBlue;
        
        self.bottomView?.backgroundColor = _ThemeLightGrayBlue;
        self.topView?.backgroundColor = _ThemeDarkBlue;
        
        self.descriptionTV?.layer.cornerRadius = 6.0;
        self.descriptionTV?.layer.borderColor = UIColor.lightGray.cgColor;
        self.descriptionTV?.layer.borderWidth = 0.33;
        
        self.segmentBar?.tintColor = _ThemeGreen;
        self.descriptionTV?.layer.cornerRadius = 6.0;
        
        self.imageView?.backgroundColor = _PreviewBGColor
        self.imageCentreView?.backgroundColor = _PreviewCenterBGColo;
        self.feedbackImgDeleteBtn?.isHidden = true;
        self.feedbackImgMaximizeBtn?.isHidden = true;
        self.imageView?.layer.cornerRadius = 6.0;
        let imageViewTap = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped));
        imageView?.isUserInteractionEnabled = true;
        imageViewTap.delegate = self
        imageView?.addGestureRecognizer(imageViewTap);
        
        self.videoView?.backgroundColor = _PreviewBGColor
        self.videoCentreView?.backgroundColor = _PreviewCenterBGColo;
        self.videoView?.layer.cornerRadius = 6.0;
        let videoViewTap = UITapGestureRecognizer(target: self, action: #selector(videoViewTapped));
        videoView?.isUserInteractionEnabled = true;
        videoViewTap.delegate = self
        videoView?.addGestureRecognizer(videoViewTap);
        
        self.submitBtn?.backgroundColor = _ThemeGreen;
        self.submitBtn?.layer.cornerRadius = 6.0;
        
        self.cancelBtn?.backgroundColor = _ThemeOrange;
        self.cancelBtn?.layer.cornerRadius = 6.0;
        
        self.nameTF?.keyboardType = .default;
        self.nameTF?.delegate = self;
        //self.nameTF?.text = "Zerodesk iOS";
        
        self.emailTF?.keyboardType = .emailAddress;
        self.emailTF?.delegate = self;
        //self.emailTF?.text = "virander.kumar@successivesoftwares.com";
        
        self.contactTF?.keyboardType = .phonePad;
        self.contactTF?.delegate = self;
        //self.contactTF?.text = "98989898989";
        
        self.descriptionTV?.keyboardType = .default;
        self.descriptionTV?.delegate = self;
        //self.descriptionTV?.text = "This is a testing feedback";
        // Do any additional setup after loading the view, typically from a nib.
        
        //MARK : permission for gps
        userLocation = CLLocationManager.init();
        userLocation?.requestAlwaysAuthorization()
        userLocation?.delegate = self;
        userLocation?.distanceFilter = kCLDistanceFilterNone;
        userLocation?.desiredAccuracy = kCLLocationAccuracyBest;
        self.checkForLoctionService();
        
        self.initLoaderView();
    }
    
    func initLoaderView() {
        loaderView = UIActivityIndicatorView.init(frame: CGRect(x:0, y:0, width: 40, height:40));
        loaderView?.center = self.view.center;
        loaderView?.hidesWhenStopped = true;
        loaderView?.color = UIColor.darkGray;
        
        var window : UIWindow? = UIApplication.shared.keyWindow;
        if (window == nil) {
            window = UIApplication.shared.windows.first;
        }
        window?.addSubview(loaderView!);
        window?.bringSubview(toFront: loaderView!);
    }
    
    func checkForLoctionService() {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                isNoGPSPermission = true
                self.showErrorAlert(title: "", message: "It seems that App doesn't has Location Service Permission. Please allow it by clicking on Settings.");
                
            case .authorizedAlways, .authorizedWhenInUse:
                userLocation?.startUpdatingLocation();
            }
        } else {
            isGPSOff = true
            self.showErrorAlert(title: "", message: "It seems that your GPS is Off. Please turn it On by clicking on Settings.");
        }
    }
    
    //MARK : get current location cllocation delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentCordinate = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    @objc func videoViewTapped() {
        isVideo = true;
        self.openVideoLibrary();
    }
    
    @objc func imageViewTapped() {
        self.openPhotoLibrary();
        isVideo = false;
    }
    
    func openVideoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let videoPicker = UIImagePickerController()
            videoPicker.delegate = self
            videoPicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            videoPicker.allowsEditing = true;
            videoPicker.mediaTypes = ["public.movie"]
            videoPicker.videoMaximumDuration = 10
            videoPicker.videoQuality = .typeMedium
            self.present(videoPicker, animated: true, completion: nil)
        }
    }
    
    func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true;
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    /* Image Picker Controller delegate */
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let infoDict : NSDictionary = info as NSDictionary;
        if isVideo {
            if (videoPlayerLayer != nil) {
                feedbackVideoDeleteBtn?.removeFromSuperview();
                feedbackVideoMaximizeBtn?.removeFromSuperview();
                videoCentreView?.isHidden = false;
                videoPlayerLayer.removeFromSuperlayer()
            }
            
            //Set video for empty
            self.showLoader();
            let videoUrlForConcerssion : URL = infoDict.object(forKey: "UIImagePickerControllerMediaURL") as! URL;
            self.encodeVideoMovToMp4(videoURL: videoUrlForConcerssion, completionHandler: {
                videoPath, success in
                if success {
                    do {
                        self.hideLoader();
                        self.videodata = try NSData(contentsOf: videoPath, options: .mappedIfSafe);
                        
                    } catch {
                        self.hideLoader();
                        // Handle exception in converting
                    }
                }
                else {
                    self.hideLoader();
                    // if converssion is aborted or failed
                }
            })
            
            //set video for display
            let videoUrlForDisplaying : URL = infoDict.object(forKey: "UIImagePickerControllerReferenceURL") as! URL;
            self.setVideoDataToView(videoUrlForDisplaying);
        }
        else {
            
            if (feedBackImgView != nil) {
                feedbackImgDeleteBtn?.removeFromSuperview();
                feedbackImgMaximizeBtn?.removeFromSuperview();
                imageCentreView?.isHidden = false;
                feedBackImgView?.removeFromSuperview();
            }
            
            let image : UIImage = infoDict.object(forKey: "UIImagePickerControllerEditedImage") as! UIImage;
            feedBackImgView = UIImageView.init();
            feedBackImgView?.frame = (imageView?.bounds)!;
            currentImage = image
            feedBackImgView?.image = image;
            self.imageCentreView?.isHidden = true;
            self.feedbackImgDeleteBtn?.isHidden = false;
            self.feedbackImgMaximizeBtn?.isHidden = false;
            self.imageView?.addSubview(feedBackImgView!);
            
            if (feedbackImgMaximizeBtn != nil) {
                feedbackImgMaximizeBtn = nil;
            }
            feedbackImgMaximizeBtn = UIButton.init(frame: CGRect(x:0, y:0, width : 44, height : 44));
            feedbackImgMaximizeBtn?.backgroundColor = _PreviewCenterBGColo;
            feedbackImgMaximizeBtn?.roundCorners([.bottomRight], radius: (feedbackImgMaximizeBtn?.bounds.height)! / 2);
            
            feedbackImgMaximizeBtn?.setImage(#imageLiteral(resourceName: "FullImg"), for: .normal);
            feedbackImgMaximizeBtn?.tag = ZD_FeedbackTags.kFeedbackImgMax.rawValue;
            feedbackImgMaximizeBtn?.addTarget(self, action: #selector(tappedOnFeedBackBtn(_:)), for: .touchUpInside);
            self.imageView?.addSubview(feedbackImgMaximizeBtn!);
            
            if (feedbackImgDeleteBtn != nil) {
                feedbackImgDeleteBtn = nil;
            }
            feedbackImgDeleteBtn = UIButton.init(frame: CGRect(x:(self.videoView?.bounds.width)! - 44, y:0, width : 44, height : 44));
            feedbackImgDeleteBtn?.backgroundColor = _PreviewCenterBGColo;
            feedbackImgDeleteBtn?.roundCorners([.bottomLeft], radius: (feedbackImgDeleteBtn?.bounds.height)! / 2);
            feedbackImgDeleteBtn?.setImage(#imageLiteral(resourceName: "DeleteImg"), for: .normal);
            feedbackImgDeleteBtn?.tag = ZD_FeedbackTags.kFeedbackImgDelete.rawValue;
            feedbackImgDeleteBtn?.addTarget(self, action: #selector(tappedOnFeedBackBtn(_:)), for: .touchUpInside);
            self.imageView?.addSubview(feedbackImgDeleteBtn!);
        }
        
        picker.dismiss(animated: true, completion: nil);
    }
    
    func setVideoDataToView(_ videoUrl : URL) {
        currentItem = AVPlayerItem.init(url: videoUrl);
        videoPlayer = AVPlayer.init(playerItem: currentItem!);
        videoPlayer.allowsExternalPlayback = true;
        videoPlayer.play();
        self.videoCentreView?.isHidden = true;
        videoPlayerLayer = AVPlayerLayer.init(player: videoPlayer);
        videoPlayerLayer.frame = (self.videoView?.bounds)!;
        self.videoView?.layer.insertSublayer(videoPlayerLayer, at: 0);
        
        if (feedbackVideoMaximizeBtn != nil) {
            feedbackVideoMaximizeBtn = nil;
        }
        feedbackVideoMaximizeBtn = UIButton.init(frame: CGRect(x:0, y:0, width : 44, height : 44));
        feedbackVideoMaximizeBtn?.backgroundColor = _PreviewCenterBGColo;
        feedbackVideoMaximizeBtn?.roundCorners([.bottomRight], radius: (feedbackVideoMaximizeBtn?.bounds.height)! / 2);
        feedbackVideoMaximizeBtn?.setImage(#imageLiteral(resourceName: "FullImg"), for: .normal);
        feedbackVideoMaximizeBtn?.tag = ZD_FeedbackTags.kFeedbackVideoMax.rawValue;
        feedbackVideoMaximizeBtn?.addTarget(self, action: #selector(tappedOnFeedBackBtn(_:)), for: .touchUpInside);
        self.videoView?.addSubview(feedbackVideoMaximizeBtn!);
        
        if (feedbackVideoDeleteBtn != nil) {
            feedbackVideoDeleteBtn = nil;
        }
        feedbackVideoDeleteBtn = UIButton.init(frame: CGRect(x:(self.videoView?.bounds.width)! - 44, y:0, width : 44, height : 44));
        feedbackVideoDeleteBtn?.backgroundColor = _PreviewCenterBGColo;
        feedbackVideoDeleteBtn?.roundCorners([.bottomLeft], radius: (feedbackVideoDeleteBtn?.bounds.height)!);
        feedbackVideoDeleteBtn?.setImage(#imageLiteral(resourceName: "DeleteImg"), for: .normal);
        feedbackVideoDeleteBtn?.tag = ZD_FeedbackTags.kFeedbackVideoDelete.rawValue;
        feedbackVideoDeleteBtn?.addTarget(self, action: #selector(tappedOnFeedBackBtn(_:)), for: .touchUpInside);
        self.videoView?.addSubview(feedbackVideoDeleteBtn!);
    }
    
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil);
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true);
        registerForKeyboardNotifications();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true);
        deregisterFromKeyboardNotifications();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func tappedOnFeedBackBtn (_ btn : UIButton) {
        print("selected btn : \(btn.tag)")
        switch btn.tag {
        case ZD_FeedbackTags.kFeedbackVideoMax.rawValue:
            self.initializeVideoPlayerForFullView();
            break;
            
        case ZD_FeedbackTags.kFeedbackVideoDelete.rawValue:
            feedbackVideoDeleteBtn?.removeFromSuperview();
            feedbackVideoMaximizeBtn?.removeFromSuperview();
            videoCentreView?.isHidden = false;
            videoPlayerLayer.removeFromSuperlayer()
            break;
            
        case ZD_FeedbackTags.kFeedbackImgMax.rawValue:
            self.maximizeImg();
            break;
            
        case ZD_FeedbackTags.kFeedbackImgDelete.rawValue:
            feedbackImgDeleteBtn?.removeFromSuperview();
            feedbackImgMaximizeBtn?.removeFromSuperview();
            imageCentreView?.isHidden = false;
            feedBackImgView?.removeFromSuperview();
            break;
            
        case ZD_FeedbackTags.kRemoveFullView.rawValue:
            preview_FullView.removeFromSuperview();
            preview_FullView = nil;
            break;
            
        default:
            break;
        }
    }
    
    func initializeVideoPlayerForFullView() {
        videoPlayer.seek(to: kCMTimeZero);
        if (preview_FullView != nil) {
            preview_FullView.removeFromSuperview();
            preview_FullView = nil
        }
        
        preview_FullView = UIView.init()
        preview_FullView.frame = self.view.bounds;
        self.view.addSubview(preview_FullView);
        videoPlayer.play()
        removeFullView = UIButton.init(frame: CGRect(x:(self.preview_FullView?.bounds.width)! - 60, y:20, width : 44, height : 44));
        removeFullView?.setImage(#imageLiteral(resourceName: "CrossImg"), for: .normal);
        removeFullView?.tag = ZD_FeedbackTags.kRemoveFullView.rawValue;
        removeFullView?.addTarget(self, action: #selector(tappedOnFeedBackBtn(_:)), for: .touchUpInside);
        self.preview_FullView?.addSubview(removeFullView!);
        
        videoPlayerLayer_FullView = AVPlayerLayer.init(player: videoPlayer);
        videoPlayerLayer_FullView.frame = self.view.bounds;
        
        self.preview_FullView.layer.insertSublayer(videoPlayerLayer_FullView, at: 0);
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem)
    }
    
    func maximizeImg() {
        if (preview_FullView != nil) {
            preview_FullView.removeFromSuperview();
            preview_FullView = nil
        }
        
        preview_FullView = UIView.init()
        preview_FullView.frame = self.view.bounds;
        preview_FullView.backgroundColor = UIColor.lightGray;
        self.view.addSubview(preview_FullView);
        
        let tempImgView : UIImageView? = UIImageView.init()
        tempImgView?.frame = preview_FullView.bounds;
        tempImgView?.image = currentImage;
        tempImgView?.contentMode = .scaleAspectFit;
        preview_FullView.addSubview(tempImgView!);
        
        removeFullView = UIButton.init(frame: CGRect(x:(self.preview_FullView?.bounds.width)! - 60, y:20, width : 44, height : 44));
        removeFullView?.setImage(#imageLiteral(resourceName: "CrossImg"), for: .normal);
        removeFullView?.tag = ZD_FeedbackTags.kRemoveFullView.rawValue;
        removeFullView?.addTarget(self, action: #selector(tappedOnFeedBackBtn(_:)), for: .touchUpInside);
        self.preview_FullView?.addSubview(removeFullView!);
        
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        
    }
    
    @IBAction func clickOnBackBtn () {
        self.hideLoader();
        self.navigationController?.popViewController(animated: true);
        //self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func submittButtonTapped() {
        
        let netStat = ZD_ConnectionCheck.sharedInstance;
        netStat.checkNetStat();
        if !netStat.isConnected {
            showErrorAlert(title: "", message: "Please check your internet connection.");
            return;
        }
        
        if ((nameTF?.text?.length) != nil){
            let userNameStr = nameTF?.text
            if (userNameStr?.length)! < 1 {
                showErrorAlert(title: "", message: "Name can't be empty!")
                return;
            }
        }
        
        if ((emailTF?.text?.length) != nil){
            let emailStr = emailTF?.text
            if (emailStr?.length)! < 1 {
                showErrorAlert(title: "", message: "Email can't be empty!")
                return;
            }
            if !(emailStr?.validateEmail())! {
                showErrorAlert(title: "", message: "Plesae check your email format.")
                return;
            }
        }
        
        if ((contactTF?.text?.length) != nil){
            let contactStr = contactTF?.text
            if (contactStr?.length)! < 1 {
                showErrorAlert(title: "", message: "Contact can't be empty!")
                return;
            }
        }
        
        //currentCordinate = CLLocation.init(latitude: 12.0001, longitude: 12.001);
        if (currentCordinate == nil){
            showErrorAlert(title: "", message: "Check your Location Service")
            return;
        }
        
        var descriptionTxt : String = ""
        if ((descriptionTV?.text?.length) != nil){
            let descriptionStr = descriptionTV?.text
            if (descriptionStr?.length)! < 20 || (descriptionStr == "Description*") {
                showErrorAlert(title: "", message: "Description should contain atleast 20 characters.")
                return;
            }
            else {
                descriptionTxt = descriptionStr!;
            }
        }
        
        var imageBase64Str : String;
        if currentImage == nil {
            imageBase64Str = "";
        }
        else {
            let imageData = UIImageJPEGRepresentation(currentImage!, 0.4)! as Data
            imageBase64Str = imageData.base64EncodedString()
        }
        
        let venderID : String = UIDevice.current.identifierForVendor!.uuidString;
        
        //get systemVersion
        let systemVersion : String = UIDevice.current.systemVersion
        
        //iPhone or iPad
        let model: String = UIDevice.current.model
        
        //device name
        let deviceName: String = UIDevice.current.name
        
        //product name
        let productName: String = Bundle.main.infoDictionary!["CFBundleName"] as! String
        
        //total RAM
        let totalMemorytemp : CGFloat = CGFloat(ProcessInfo.processInfo.physicalMemory) / 1048576
        let totalMemory = NSNumber(value: Float(totalMemorytemp))
        
        //Used RAM
        let usedRam : NSNumber = self.report_memory()
        
        //free RAM
        let freeRamtemp : CGFloat = CGFloat(totalMemory.intValue - usedRam.intValue)
        let freeRam : NSNumber = NSNumber(value: Float(freeRamtemp))
    
        /*start encrypting*/
        DispatchQueue.main.async {
            self.showLoader();
        }
        
        let jsonObject: [String: String] = [
            "imei"          : venderID,
            "project_id"    : projectId,
            "ticket_type"   : ((segmentBar?.selectedSegmentIndex == 0) ? "Feedback" : "Incident"),
            "name"          : (nameTF?.text)!,
            "email_id"      : (emailTF?.text)!,
            "contact_no"    : (contactTF?.text)!,
            "snap_image"    : imageBase64Str,
            "description"   : descriptionTxt,
            "lat"           : NSString(format: "%f", (currentCordinate?.coordinate.latitude)!) as String,
            "lng"           : NSString(format: "%f", (currentCordinate?.coordinate.longitude)!) as String,
            "manufacturer"  : "Apple",
            "os_version"    : systemVersion,
            "sdk"           : systemVersion,
            "device_name"   : deviceName,
            "model"         : model,
            "product"       : productName,
            "total_ram"     : totalMemory.stringValue + " MB",
            "free_ram"      : freeRam.stringValue + " MB",
            "used_ram"      : usedRam.stringValue + " MB"
        ]
        
        //JSON in string
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let jsonSTR = jsonString?.data(using: .utf8)!
        let input = [UInt8](jsonSTR!)
        
        //Auth key
        let authSTR : String? = projectId + ":" + self.getCurrentTimeStamp()
        let data = (authSTR)?.data(using: String.Encoding.utf8)
        let base64 = data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        //AES key
        let aesKey = "D(#KN$4eB[XPyTVj".data(using: .utf8)!
        let key = [UInt8](aesKey)
        
        var feedbackStr : String? = ""
        
        do {
            
            let encrypted = try AES(key: key, blockMode: .ECB, padding: .pkcs5).encrypt(input)
            let encryptedByteArrToData = NSData(bytes: encrypted, length: encrypted.count)
            
            //Encode to base64
            feedbackStr = encryptedByteArrToData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            print("encrypted : \(String(describing: feedbackStr))")
            
            let decrypted = try AES(key: key, blockMode: .ECB, padding: .pkcs5).decrypt(encrypted)
            let data = NSData(bytes: decrypted, length: decrypted.count)
            let backToString = String(data: data as Data, encoding: String.Encoding.utf8) as String!
            print("backToString : \(String(describing: backToString))");
            
        } catch {
            print(error)
        }
        
        /*end encrypting*/
        DispatchQueue.main.async {
            self.hideLoader();
        }
        
        if videodata == nil {
            videodata = "".data(using: .utf8)! as NSData
        }
        let param: [String: Any] = [
            "authKey"           : base64 as Any,
            "feedbackDetail"    : feedbackStr as Any,
            "feedbackVideo"     : videodata as Any
        ]
        
        print("jsonString : \(jsonString)")
        
        print("video data : \(String(describing: videodata))");
        /*Show loader*/
        DispatchQueue.main.async {
            self.showLoader();
        }
        let service = ZD_ServiceClass.init();
        service.hitApiUsingMultiPart(param, completionHandler: {
            resultDict , success in
            if success {
                DispatchQueue.main.async {
                    self.hideLoader();
                    print("success 1 : \(resultDict.description)");
                    self.isSubmitSuccefully = true;
                    self.showErrorAlert(title: "", message: resultDict["message"] as! String);
                }
            }
            else {
                DispatchQueue.main.async {
                    self.hideLoader();
                    print("success 2: \(resultDict.description)");
                    self.isSubmitSuccefully = false;
                    self.showErrorAlert(title: "", message: resultDict["message"] as! String);
                }
            }
        })
    }
    
    func showErrorAlert(title : String, message:String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okBtn = UIAlertAction(title: "Ok", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if self.isSubmitSuccefully! {
                self.isSubmitSuccefully! = false
                self.clickOnBackBtn();
            }
        });
        
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            alertVC.dismiss(animated: true, completion: nil)
        });
        
        let settingBtn = UIAlertAction(title: "Settings", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if self.isGPSOff! {
                self.isGPSOff = false
                if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION") {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    };
                }
            }
            else if self.isNoGPSPermission! {
                self.isNoGPSPermission = false
                if let settingsURL = URL(string: UIApplicationOpenSettingsURLString + Bundle.main.bundleIdentifier!) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsURL as URL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(settingsURL)
                    };
                }
            }
            else {
                
            }
        });
        if isNoGPSPermission! || isGPSOff! {
            
            alertVC.addAction(settingBtn);
            alertVC.addAction(cancelBtn);
        }
        else {
            alertVC.addAction(okBtn);
        }
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func getCurrentTimeStamp() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let currentDate = formatter.string(from: date)
        return currentDate;
    }
    
    func report_memory() -> NSNumber {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let memoryMB : CGFloat = CGFloat(taskInfo.resident_size) / 1048576
            let myNumber = NSNumber(value: Float(memoryMB))
            return myNumber
        }
        else {
            print("Error with task_info(): " +
                (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
            return 0
        }
    }
}
extension ZD_FeedbackVC {
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification){
        self.scrollView?.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView?.contentInset = contentInsets
        self.scrollView?.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = (self.scrollView?.frame)!
        aRect.size.height -= keyboardSize!.height
        
        let localActiveField = (self.activeTF != nil) ? self.activeTF : self.activeTV;
        
        let origin : CGPoint = CGPoint(x:localActiveField.frame.origin.x, y : (localActiveField.superview?.frame.origin.y)! + localActiveField.frame.origin.y);
        if (!aRect.contains(origin)) {
            let visibleFrame = CGRect(x:origin.x,y:origin.y-20,width:localActiveField.frame.size.width,height:localActiveField.frame.size.height);
            self.scrollView?.scrollRectToVisible(visibleFrame, animated: true)
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        
        self.scrollView?.contentInset = contentInsets
        self.scrollView?.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
    }
    
    func showLoader() {
        submitBtn?.isUserInteractionEnabled = false;
        loaderView?.startAnimating();
    }
    
    func hideLoader() {
        submitBtn?.isUserInteractionEnabled = true;
        loaderView?.stopAnimating();
    }
    
    func encodeVideoMovToMp4(videoURL: URL, completionHandler : @escaping (URL, Bool) -> Void) {
        
        let avAsset = AVURLAsset(url: videoURL)
        let startDate = Date()
        let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough)
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let myDocPath = NSURL(fileURLWithPath: docDir).appendingPathComponent("temp.mp4")?.absoluteString
        
        let docDir2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        
        let filePath = docDir2.appendingPathComponent("rendered-Video.mp4")
        deleteFile(filePath!)
        
        if FileManager.default.fileExists(atPath: myDocPath!){
            do{
                try FileManager.default.removeItem(atPath: myDocPath!)
            }catch let error{
                print(error)
            }
        }
        
        exportSession?.outputURL = filePath
        exportSession?.outputFileType = AVFileType.mp4
        exportSession?.shouldOptimizeForNetworkUse = true
        
        let start = CMTimeMakeWithSeconds(0.0, 0)
        let range = CMTimeRange(start: start, duration: avAsset.duration)
        exportSession?.timeRange = range
        
        exportSession!.exportAsynchronously{() -> Void in
            switch exportSession!.status{
                
            case .failed:
                completionHandler(URL.init(string: "")!, false);
                print("\(exportSession!.error!)")
                
            case .cancelled:
                completionHandler(URL.init(string: "")!, false);
                print("Export cancelled")
                
            case .completed:
                let endDate = Date()
                let time = endDate.timeIntervalSince(startDate)
                print(time)
                print("Successful")
                let videoFilePath : URL = (exportSession?.outputURL ?? URL.init(string: "")!)
                print("mp4 video file path : \(videoFilePath)")
                completionHandler(videoFilePath, true);
            default:
                break
            }
        }
    }
    
    func deleteFile(_ filePath:URL) {
        guard FileManager.default.fileExists(atPath: filePath.path) else{
            return
        }
        do {
            try FileManager.default.removeItem(atPath: filePath.path)
        }catch{
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }
}

/* Extensions for class */

extension ZD_FeedbackVC : UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTF = textField;
        activeTV = nil;
        return true;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return false;
    }
}

extension ZD_FeedbackVC : UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        activeTF = nil;
        activeTV = textView;
        return true;
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Description*" {
            textView.text = "";
            textView.textColor = UIColor.black;
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Description*";
            textView.textColor = UIColor.lightGray;
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        if textView.text.characters.count <= 500 {
            let text1 : String? = textView.text! + text;
            var stringToBeSearch : String!;
            if text.characters.count < 1 {
                let index = text1?.index((text1?.startIndex)!, offsetBy: (text1?.characters.count)! - 1)
                let subText : String? = text1?.substring(to: index!)
                stringToBeSearch = subText!;
            }
            else {
                stringToBeSearch = text1!;
            }
            let charCount : NSNumber! = stringToBeSearch.characters.count as NSNumber;
            
            self.descriptionCharCount?.text = charCount.stringValue + " / 500"
            return true
        }
        else {
            return false
        }
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

extension Dictionary {
    
    var queryString: String? {
        var output: String = ""
        for (key,value) in self {
            output +=  "\(key):\(value)\(",")"
        }
        return output
    }
}

extension UIView {
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
extension String {
    func validateEmail() -> Bool {
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
    
    func validateUrl() -> Bool {
        
        let urlRegEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [urlRegEx])
        return predicate.evaluate(with: self)
    }
    func validateZip() -> Bool {
        let zipRegEx = "^\\d{5}(-\\d{4})?$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", zipRegEx)
        return predicate.evaluate(with: self)
    }
    
    func isAlphanumeric() -> Bool {
        let letters = CharacterSet.letters
        let digits = CharacterSet.decimalDigits
        
        var letterCount = 0
        var digitCount = 0
        
        for uni in self.unicodeScalars {
            if letters.contains(UnicodeScalar(uni.value)!) {
                letterCount += 1
            } else if digits.contains(UnicodeScalar(uni.value)!) {
                digitCount += 1
            }
        }
        if letterCount > 0 && digitCount > 0 {
            return true
        }
        return false
    }
    var length: Int {
        return characters.count
    }
    
    func insertString(_ string: String, ind: Int) -> String {
        return String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters.count - ind))
    }
}
