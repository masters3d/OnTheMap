//
//  Constants.swift
//  OnTheMap
//
//  Created by Cheyo Jimenez on 5/10/16.
//  Copyright © 2016 Cheyo Jimenez. All rights reserved.
//

import Foundation

enum Udacity{
    static let urlSignUpString: String = "https://www.udacity.com/account/auth#!/signup"
}

enum UserDefault{
    static let loginJSONResponseKey = "loginJSONResponse"
    
    private static let userEmailKey: String = "udacityUserEmail"
    private static let userPasswordKey: String = "udacityUserPassword"
    
    static func getCredentials() -> (email:String, password:String){
        let defaults = NSUserDefaults.standardUserDefaults()
        if let udacityUserEmail = defaults.stringForKey(userEmailKey),
            let udacityUserPassword = defaults.stringForKey(userPasswordKey){
            return (udacityUserEmail, udacityUserPassword)
        } else {
            return ("","")
        }
    }

    static func setCredentials(email:String, password:String){
        NSUserDefaults.standardUserDefaults().setObject(email, forKey: userEmailKey)
        NSUserDefaults.standardUserDefaults().setObject(password, forKey: userPasswordKey)
    }
    
    static func getLoginDataResponse()->NSData?{
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.dataForKey(ConnectionType.login.rawValue)
    }
    
    static func getLoginJSONDictionary()-> NSDictionary? {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let dictionary = defaults.dictionaryForKey(loginJSONResponseKey) {
            return dictionary as NSDictionary
        } else {
            return nil
        }
    }
    
    static func getHTTPBodyUdacityPayload() -> NSData?{
        let (email, password) = UserDefault.getCredentials()
        let object  = ["udacity" : ["username" : email, "password" : password]]
        return try? NSJSONSerialization.dataWithJSONObject(object, options: [])

    }
    
}
