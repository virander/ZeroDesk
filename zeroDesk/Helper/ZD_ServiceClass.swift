//
//  ZD_ServiceClass.swift
//  ZeroDesk
//
//  Created by Apple  on 16/11/17.
//  Copyright © 2017 Apple . All rights reserved.
//

import Foundation

class ZD_ServiceClass : NSObject {
    
    var baseUrl : String!
    var data    : Data!
    override init(){
        
        super.init()
        //baseUrl = "http://192.168.1.117:8888/" // local server
        baseUrl = "http://echallan.zerodesk.in/"  //Live server
    }
    
    
    //MARKS : Api for sending feedback
    /* this api is using multipart data form */
    
    /******************************* START FEEDBACK API ********************************/
    func hitApiUsingMultiPart(_ param : [String:Any], completionHandler : @escaping (NSDictionary, Bool) -> Void) {
        
        let tempStr : String = baseUrl + submitFeedbackAPI;
        let myUrl = NSURL(string: tempStr);
        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "POST";
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(param["authKey"] as? String, forHTTPHeaderField: "Auth-Token");
        
        let videodata = param["feedbackVideo"]
        let feebackDetailDict = ["feedback_details" : param["feedbackDetail"]];
        request.httpBody = createBodyWithParameters(parameters: feebackDetailDict as? [String : String], filePathKey: "snap_video", videoDataKey: videodata as! NSData, boundary: boundary) as Data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error=\(String(describing: error))")
                return
            }
            
            // You can print out response object
            print("******* response = \(String(describing: response))")
            
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("****** response data = \(responseString!)")
            do {
                let responseDictionary = try JSONSerialization.jsonObject(with: data!);
                completionHandler(responseDictionary as! NSDictionary, true);
            }
            catch {
                let responseString = String(data: data!, encoding: .utf8)
                completionHandler(["message":responseString as Any], false);
            }
        }
        task.resume()
    }
    /******************************* END FEEDBACK API ********************************/
    
    
    
    
    //MARKS: This method is used for creating formm data
    /************************ start creating formm data ***********************/
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, videoDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        let filename = "video.mp4";
        let mimetype = "mp4/MOV";
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        if videoDataKey.length > 0 {
            body.append(videoDataKey as Data)
            body.appendString(string: "\r\n")
        }
        else {
            body.appendString(string: "")
            body.appendString(string: "\r\n")
        }
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    /************************ end creating formm data ***********************/
    
    
    //MARKS: This method is used for generating boundary
    /*************** generate boundary for form data ***************/
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    
    /***************************************************************************************/
  
    
    //MARKS : Api for sending Crash report
    /* this api is using raw data */
    
    /******************************* START CRASH API ********************************/
    func hitApiForCrashlytics(_ param : String, _ clientId : String, completionHandler: @escaping (_ result:NSDictionary, _ success : Bool) -> Void) {
        
        let data11 = param.data(using: .utf8)!
        
        let url:NSURL = NSURL(string: String(format: "%@/%@?client_id=%@&device_type=%@", baseUrl, submitCrashAPI, clientId, "ios"))!
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.uploadTask(with: request as URLRequest, from: data11, completionHandler: {
            (data,response,error) in
            
            guard error == nil else {
                print(error!);
                completionHandler(["message":error?.localizedDescription as Any], false);
                return
            }
            do {
                let responseDictionary = try JSONSerialization.jsonObject(with: data!);
                print("success == \(responseDictionary)");
                completionHandler(responseDictionary as! NSDictionary, true);
            }
            catch {
                print(error);
                let responseString = String(data: data!, encoding: .utf8)
                completionHandler(["message":responseString as Any], false);
            }
        });
        task.resume()
    }
    /******************************* END CRASH API ********************************/
}

//EXTENSIONS
extension NSMutableData {
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

