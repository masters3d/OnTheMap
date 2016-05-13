//
//  NetworkLayer.swift
//  OnTheMap
//
//  Created by Cheyo Jimenez on 5/10/16.
//  Copyright © 2016 Cheyo Jimenez. All rights reserved.
//

import Foundation

enum ConnectionType:String{
    case login = "udacityLoginResponse"
}


class NetworkOperation: NSOperation, NSURLSessionDataDelegate {
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
        if cancelled {
            finished = true
            return
        }
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        if let request = request{
        //let request = NSMutableURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request)
        startTime = NSDate.timeIntervalSinceReferenceDate()
        task.resume()
        }
        
    }
    
    init(typeOfConnection:ConnectionType){
        switch typeOfConnection {
        case .login:
            super.init()
            self.url = NSURL(string: "https://www.udacity.com/api/session")
            self.keyString = ConnectionType.login.rawValue
            self.request = NSMutableURLRequest(URL: url!)
            request?.HTTPMethod = "POST"
            request?.addValue("application/json", forHTTPHeaderField: "Accept")
            request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request?.HTTPBody = UserDefault.getHTTPBodyUdacityPayload()
            completionBlock = {
                if let data = UserDefault.getLoginDataResponse() {
                    let subData =  data.subdataWithRange(NSMakeRange(5, data.length - 5 ))
                    
                    do{
                        let jsonDict = try NSJSONSerialization.JSONObjectWithData(subData, options: .MutableLeaves) as! NSDictionary
                        NSUserDefaults.standardUserDefaults().setObject(jsonDict, forKey: UserDefault.loginJSONResponseKey)
                    } catch {
                        print(error)
                    }
                }
            }
            
        default:
            fatalError("Unrecognized connection type")
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
        
        switch httpResponse.statusCode {
        case 200:
            
            completionHandler(.Allow)
           
        default:
            print("Something is wrong: \(httpResponse.statusCode)")
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
            finished = true
            return
        }
        
        do {
           // try processData()
            NSUserDefaults.standardUserDefaults().setObject(data, forKey: keyString ?? "")
            
        } catch {
            print("Failed to process data: \(error)")
        }
        totalTime = NSDate.timeIntervalSinceReferenceDate() - startTime!
        finished = true
    }
    
//    
//    func processData() throws {
//        guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSArray else {
//            throw NSError(domain: "Mine", code: 1123, userInfo: [NSLocalizedDescriptionKey : "Bad data"])
//        }
//        
//        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
//        context.parentContext = dataController?.managedObjectContext
//        
//        context.performBlockAndWait() {
//            for recipeJSON in json {
//                let recipe = MyRecipeMO.insertIntoMOC(context)
//                recipe.populateFromJSON(recipeJSON as! [String:AnyObject])
//            }
//            do {
//                try context.save()
//            } catch {
//                print("Failed to save: \(error)")
//            }
//        }
//    }
    
}



