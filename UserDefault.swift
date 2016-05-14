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

enum UserDefault {
    private static let defaults = NSUserDefaults.standardUserDefaults()
    
    private static let userEmailKey: String = "udacityUserEmail"
    private static let userPasswordKey: String = "udacityUserPassword"
    
    static func getCredentials() -> (email:String, password:String){
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
    
    static func getLoginJSONDictionary()-> NSDictionary? {
        var jsonDict:NSDictionary?
        if let data = defaults.dataForKey(UdacityConnectionType.login.rawValue) {
            let subData =  data.subdataWithRange(NSMakeRange(5, data.length - 5 ))
            
            do {
                jsonDict  = try NSJSONSerialization.JSONObjectWithData(subData, options: .MutableLeaves) as? NSDictionary
            } catch {
                print(error)
            }
        }
        return jsonDict
    }
    
    static func getHTTPBodyUdacityPayload() -> NSData?{
        let (email, password) = UserDefault.getCredentials()
        let object  = ["udacity" : ["username" : email, "password" : password]]
        return try? NSJSONSerialization.dataWithJSONObject(object, options: [])

    }
    
    static func getFullNameFromJSONDictionary()->(fist:String, last:String, nick:String)?{
        var first:String = ""
        var last:String = ""
        var nick:String = ""
        if let data = defaults.dataForKey(UdacityConnectionType.getFullName.rawValue) {
            let subData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            do {
                let response = try NSJSONSerialization.JSONObjectWithData(subData, options: .MutableLeaves) as! NSDictionary
                if let user = response["user"],
                    let lastname = user["last_name"] as? String,
                    let nickname = user["nickname"] as? String,
                    let firstname = user["first_name"] as? String {
                    (first, last, nick) = (firstname, lastname, nickname)
                }
                
            } catch {
            print(error)
                return nil
            }
        }
        return (first, last, nick)
    }
    
    
    static func getUserId()->String{
        if let response = getLoginJSONDictionary(),
            let account = response["account"],
            let id = account["key"],
            let accountID = id as? String {
            return accountID
        } else {
            return ""
        }
    }
    
    static func deleteUserSavedData(){
        defaults.setObject(nil, forKey: UdacityConnectionType.login.rawValue)
        defaults.setObject(nil, forKey: UdacityConnectionType.getFullName.rawValue)
        defaults.setObject(nil, forKey: UserDefault.userEmailKey )
        defaults.setObject(nil, forKey: UserDefault.userPasswordKey )
    }
    
}
