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
            UserDefault.deleteUserSavedData()
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

//MARK:-Keyboard code
extension UIViewController:UITextFieldDelegate, UITextViewDelegate {

    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0.0
    }
    // this needs to be overitten by class that wants keboard support
    func keyboardWillShow(notification: NSNotification) {
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    // Hide the keyboard when user hits the return key
     public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // Automaticly sets the deltegates to all the UITextFields on the top view
    func setDelegate(field:UITextField){
        field.delegate = self
    }
    
    // Does not work for nested UITextField
    func assingDelegateToTextFields(){
        for each in view.subviews {
            if (each is UITextField) {
                let field = each as! UITextField
                setDelegate(field)
            }
        }
    }

    
}

