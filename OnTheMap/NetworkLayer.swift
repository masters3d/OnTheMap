//
//  NetworkLayer.swift
//  OnTheMap
//
//  Created by Cheyo Jimenez on 5/10/16.
//  Copyright © 2016 Cheyo Jimenez. All rights reserved.
//

import UIKit


enum APIConstants {
    static let limit = "?limit=100"
    static let udacitySession  = "https://www.udacity.com/api/session"
    static let udacityUsers = "https://www.udacity.com/api/users/"
    static let parseStudentLocation = "https://parse.udacity.com/parse/classes/StudentLocation"
    static let parseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let parseHeaderAppID = "X-Parse-Application-Id"
    static let parseRestAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    static let parseHeaderForREST = "X-Parse-REST-API-Key"

}


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
        
        //MARk:-ProcessData() and save
        // Right now we are just saving here for later retrival
            NSUserDefaults.standardUserDefaults().setObject(data, forKey: keyString ?? "")
        
        totalTime = NSDate.timeIntervalSinceReferenceDate() - startTime! // this should always have a value
        finished = true
    }
}

//MARK: - Udacity Connection

enum UdacityConnectionType:String{
    case login = "udacityLoginResponse"
    case getFullName = "getFullNameResponse"
}

extension NetworkOperation {
    convenience init(typeOfConnection:UdacityConnectionType){
        switch typeOfConnection {
        case .login:
            self.init(url:NSURL(string: APIConstants.udacitySession)!, keyForData:typeOfConnection.rawValue)
            request?.HTTPMethod = "POST"
            request?.addValue("application/json", forHTTPHeaderField: "Accept")
            request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request?.HTTPBody = UserDefault.getHTTPBodyUdacityPayload()
            
        case .getFullName:
            let userID = UserDefault.getUserId() ?? ""
            guard let getFullNameURL = NSURL(string: APIConstants.udacityUsers + "\(userID)") else { fatalError("Malformed URL")}
            self.init(url:getFullNameURL, keyForData:typeOfConnection.rawValue)
        }
    }
}

//MARK: - Parse Connections

enum ParseConnectionType: String {
    case getStudentLocationsWithLimit = "APILocationsWithLimit"
}

extension NetworkOperation{
    
   static func escapeForURL(input: String) -> String? {
        return input.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    }

    private func escapeUserURL( userId: String) -> String {
        let parseURL = APIConstants.parseStudentLocation
        let urlString = parseURL + "?where={\"uniqueKey\":\"\(userId)\"}"
        let escapedURLString = NetworkOperation.escapeForURL(urlString) ?? urlString
        return escapedURLString
    }
    
}

extension NetworkOperation {
    convenience init(typeOfConnection:ParseConnectionType){
        switch typeOfConnection {
           case .getStudentLocationsWithLimit:
            let parseURL = APIConstants.parseStudentLocation + APIConstants.limit
            guard let parseURLEscaped = NSURL(string: NetworkOperation.escapeForURL(parseURL ) ?? parseURL) else { fatalError("Malformed URL") }
            self.init(url:parseURLEscaped, keyForData: typeOfConnection.rawValue)
            request?.addValue(APIConstants.parseApplicationID, forHTTPHeaderField: APIConstants.parseHeaderAppID)
            request?.addValue(APIConstants.parseRestAPIKey, forHTTPHeaderField: APIConstants.parseHeaderForREST)
        }
    }
}





