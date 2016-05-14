//
//  SharedViewCode.swift
//  OnTheMap
//
//  Created by Cheyo Jimenez on 5/14/16.
//  Copyright © 2016 Cheyo Jimenez. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func logoutPerformer(block:(() -> Void)? = nil) {
        let logoutActionSheet = UIAlertController(title: "Confirmation Required", message: "Are you sure you want to logout?", preferredStyle: .Alert)
        let logoutConfirmed = UIAlertAction(title: "Logout", style: .Destructive, handler: { Void in
            self.dismissViewControllerAnimated(true, completion: nil)
            if let block = block {
                block()
            }
            // Deleting user Defaults Values
            
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: UdacityConnectionType.login.rawValue)
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: UdacityConnectionType.getFullName.rawValue)
            
        })
        logoutActionSheet.addAction(logoutConfirmed)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        logoutActionSheet.addAction(cancel)
        presentViewController(logoutActionSheet, animated: true, completion: nil)
    }
    
    
    func presentErrorPopUp(description:String, inout presentingError:Bool){
        presentingError = true
        let errorActionSheet = UIAlertController(title: "Error", message: description, preferredStyle: .Alert)
        let tryAgain = UIAlertAction(title: "Try Again?", style: .Default, handler: { _ in presentingError = false})
        errorActionSheet.addAction(tryAgain)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in presentingError = false})
        errorActionSheet.addAction(cancel)
        self.presentViewController(errorActionSheet, animated: true, completion: { })
    }
    
}

