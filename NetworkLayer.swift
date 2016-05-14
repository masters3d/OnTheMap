//
//  NetworkLayer.swift
//  OnTheMap
//
//  Created by Cheyo Jimenez on 5/10/16.
//  Copyright © 2016 Cheyo Jimenez. All rights reserved.
//

import UIKit

protocol ErrorReportingFromNetworkProtocol {
    func reportErrorFromOperation(operationError:ErrorType?)
    var errorReported:ErrorType? {get}

}

class NetworkOperation: NSOperation, NSURLSessionDataDelegate {
    //Error Reporting
    var delegate:ErrorReportingFromNetworkProtocol?
    
    // custom fields
    private var url:NSURL?
    private var keyString:String?
    var request:NSMutableURLRequest?
    
    // default
   private var data = NSMutableData()
   private var startTime: NSTimeInterval? = nil
   private var totalTime: NSTimeInterval? = nil
    
   private var tempFinished: Bool = false
    override var finished: Bool {
        set {
            willChangeValueForKey("isFinished")
            tempFinished = newValue
            didChangeValueForKey("isFinished")
        }
        get {
            return tempFinished
        }
    }
    
    override func start() {
        
        // clears up any errors in the delegate
        dispatch_async(dispatch_get_main_queue(), {
            self.delegate?.reportErrorFromOperation(nil)
        })
        
        if cancelled {
            finished = true
            return
        }
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        if let request = request{
        let task = session.dataTaskWithRequest(request)
        startTime = NSDate.timeIntervalSinceReferenceDate()
        task.resume()
        }
        
    }
    
    init(url:NSURL, keyForData:String){
        super.init()
        self.url = url
        self.keyString = keyForData
        self.request = NSMutableURLRequest(URL: url)
        
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        guard let httpResponse = response as? NSHTTPURLResponse else {
            fatalError("Unexpected response type")
        }
        
        switch httpResponse.statusCode{
        case 200:
            completionHandler(.Allow)
           
        default:
            let connectionError = NSError(domain: "Check your login information.", code: httpResponse.statusCode, userInfo: nil)
            print(connectionError.localizedDescription)
            dispatch_async(dispatch_get_main_queue(), {
                self.delegate?.reportErrorFromOperation(connectionError)
            })
            completionHandler(.Cancel)
            finished = true
        }
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData incomingData: NSData) {
        data.appendData(incomingData)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let error = error {
            print("Failed! \(error)")
            // sending error to delagate UI on the main queue
            dispatch_async(dispatch_get_main_queue(), {
                self.delegate?.reportErrorFromOperation(error)
            })
            
            finished = true
            return
        }
        
        
        //MARK:- ProcessData() and save
        
            NSUserDefaults.standardUserDefaults().setObject(data, forKey: keyString ?? "")
        
        totalTime = NSDate.timeIntervalSinceReferenceDate() - startTime!
        finished = true
    }
}


enum UdacityConnectionType:String{
    case login = "udacityLoginResponse"
    case getFullName = "getFullNameResponse"
}

//MARK: - Udacity Connection
extension NetworkOperation {
    convenience init(typeOfConnection:UdacityConnectionType){
        switch typeOfConnection {
        case .login:
            self.init(url:NSURL(string: "https://www.udacity.com/api/session")!, keyForData:UdacityConnectionType.login.rawValue)
            request?.HTTPMethod = "POST"
            request?.addValue("application/json", forHTTPHeaderField: "Accept")
            request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request?.HTTPBody = UserDefault.getHTTPBodyUdacityPayload()
            
        case .getFullName:
            self.init(url:NSURL(string: "https://www.udacity.com/api/users/" + "\(UserDefault.getUserId())")!, keyForData:UdacityConnectionType.getFullName.rawValue)
        }
    }
}

//MARK: - Parse Connections
extension NetworkOperation{
    private func escapeURL( userId: String) -> String {
        let parseURL = "https://api.parse.com/1/classes/StudentLocation"
        let urlString = parseURL + "?where={\"uniqueKey\":\"\(userId)\"}"
        let escapedURLString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) ?? ""
        return escapedURLString
    }

}



