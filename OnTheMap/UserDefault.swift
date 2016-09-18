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
    
    static func getCredentials() -> (email:String, password:String)?{
        if let udacityUserEmail = defaults.stringForKey(userEmailKey),
            let udacityUserPassword = defaults.stringForKey(userPasswordKey){
            return (udacityUserEmail, udacityUserPassword)
        } else {
            return nil
        }
    }

    static func setCredentials(email:String, password:String){
        defaults.setObject(email, forKey: userEmailKey)
        defaults.setObject(password, forKey: userPasswordKey)
    }
    
    static func getLoginJSONDictionary()-> NSDictionary? {
        var jsonDict:NSDictionary?
        if let data = defaults.dataForKey(ConnectionType.login.rawValue) {
            let subData =  data.subdataWithRange(NSMakeRange(5, data.length - 5 ))
            
            do {
                jsonDict  = try NSJSONSerialization.JSONObjectWithData(subData, options: .MutableLeaves) as? NSDictionary
            
            } catch {
                print("error parsing the udacity connection \(error)")
            }
        }
        return jsonDict
    }
    
    static func getHTTPBodyUdacityPayload() -> NSData?{
        guard let (email, password) = UserDefault.getCredentials() else {
            return nil
        }
        
        
        let object  = ["udacity" : ["username" : email, "password" : password]]
        return try? NSJSONSerialization.dataWithJSONObject(object, options: [])

    }
    
    static func getFullNameFromJSONDictionary()->(fist:String, last:String, nick:String)?{
        var first:String = ""
        var last:String = ""
        var nick:String = ""
        if let data = defaults.dataForKey(ConnectionType.getFullName.rawValue) {
            let subData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            do {
                guard let response = try NSJSONSerialization.JSONObjectWithData(subData, options: .MutableLeaves) as? NSDictionary
                        else { return nil }
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
    
    
    static func getCurrentLoggedInUserLocations() -> [UserLocation] {
        var locations = [UserLocation]()
        let key = ConnectionType.getLoggedInStudentMultipleLocations.rawValue
        guard let data = defaults.dataForKey(key) else { warnLog(); return [] }
        
        let subData = data//.subdataWithRange(NSMakeRange(5, data.length - 5))
        
        guard let response = try? NSJSONSerialization.JSONObjectWithData(subData, options: .MutableLeaves),
            let responseDictionary = response as? NSDictionary  else { warnLog(); return [] }

         guard let results = responseDictionary["results"],
            let resultsArray = results as? NSArray else { warnLog(); return [] }
        
        for each in resultsArray {
         guard let dict = each as? NSDictionary,
         let userLocation = UserLocation(dict) else { warnLog(); continue }
            locations.append(userLocation)
        }
        
        return locations
    }
    
    
    static func getCurrentSessionID() -> String? {
        if let response = getLoginJSONDictionary(),
            let session = response["session"],
            let idObject = session["id"],
            let id = idObject as? String {
            return id
        } else {
            return nil
        }
    }
    
    static func getUserId()->String?{
        if let response = getLoginJSONDictionary(),
            let account = response["account"],
            let id = account["key"],
            let accountID = id as? String {
            return accountID
        } else {
            return nil
        }
    }
    
    static func deleteUserSavedData(){
        NSUserDefaults.resetStandardUserDefaults()
        
    print()
    
    }
    
    //MARK:- Parse 
    
    static var postParsePayload:NSData? {
        set { self.defaults.setValue(newValue, forKey: "parsePayload") }
        get { return self.defaults.dataForKey("parsePayload")}
    }
    
    static func getUserLocations() -> [UserLocation] {
        var usersLocations = [UserLocation]()
        if let dict = UserDefault.getParseUserLocations(),
            let arrayDict = dict["results"] as? NSArray,
            let result = arrayDict as? [NSDictionary] {
            usersLocations = result.flatMap(UserLocation.init)
        }
        
        return usersLocations
    }
    
    static func getParseUserLocations() -> NSDictionary? {
        guard let data = defaults.dataForKey(ConnectionType.getStudentLocationsWithLimit.rawValue) else { return nil }
        var jsonDict:NSDictionary?
        do {
            jsonDict  = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves) as? NSDictionary
            
        } catch {
            print("error parsing the Parse connection \(error)")
        }
        
        return jsonDict
    
    }
}
