//
//  SharedViewCode.swift
//  OnTheMap
//
//  Created by Cheyo Jimenez on 5/14/16.
//  Copyright © 2016 Cheyo Jimenez. All rights reserved.
//

import UIKit

// Logging Free function

func warnLog(line:Int = #line, file:String = #file) {
    print("Warning line: \(line) file: \(file) ")
}

func warnLog<T>(input: T, line:Int = #line, file:String = #file) -> T {
    print("Warning line: \(line) file: \(file) ")
    return input
}



extension ErrorReportingFromNetworkProtocol where Self : UIViewController  {
    
    // Log out for all views
    func logoutPerformer(block:(() -> Void)? = nil) {
        let logoutActionSheet = UIAlertController(title: "Confirmation Required", message: "Are you sure you want to logout?", preferredStyle: .Alert)
        let logoutConfirmed = UIAlertAction(title: "Logout", style: .Destructive, handler: { Void in
            self.dismissViewControllerAnimated(true, completion: nil)
            if let block = block {
                block()
            }
            
            // NETWORK CALL: Logging out Deleting
            // we could have activityIndicator started here
            let logoutNetworkOperation = NetworkOperation(typeOfConnection: ConnectionType.deleteSession)
                logoutNetworkOperation.delegate = self
                logoutNetworkOperation.completionBlock = {
                    dispatch_async(dispatch_get_main_queue(), {
                    // we could have activityIndicator stop here
                    print("log out successfull")
                    // Deleting user Defaults Values
                    UserDefault.deleteUserSavedData()
                    })
                }
            logoutNetworkOperation.start()
            // END OF NETWORK CALL: Logging out Deleting

        })

        logoutActionSheet.addAction(logoutConfirmed)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        logoutActionSheet.addAction(cancel)
        presentViewController(logoutActionSheet, animated: true, completion: {
            self.presentingAlert = false
        })
    }
}

extension UIViewController {

    func presentErrorPopUp(description: String, inout presentingError: Bool) {
        presentingError = true
        let errorActionSheet = UIAlertController(title: "Error: Please Try again", message: description, preferredStyle: .Alert)
        let tryAgain = UIAlertAction(title: "Okay", style: .Default, handler: { _ in presentingError = false})
        errorActionSheet.addAction(tryAgain)
        self.presentViewController(errorActionSheet, animated: true, completion: {
            presentingError = false
          })
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

    // This function gets called inside the view so to set the instance as the delegate
    func setDelegate(field: UITextField) {
        field.delegate = self
    }

    // Automaticly sets the deltegates to all the UITextFields including the sub views
    func assingDelegateToTextFields() {

        // recursive function to find all the sub views in a view
        func getAllSubViews(input: [UIView]) -> [UIView] {

            if input.isEmpty {
                return []
            }

            let collection = input.filter({$0.subviews.count <= 1})
            var total = collection

            total += collection.flatMap({ subView in
                getAllSubViews(subView.subviews)
            })

            return total

        }
        let allSubViews = getAllSubViews(view.subviews)

        for each in  allSubViews {
            if (each is UITextField) {
                let field = each as! UITextField

                setDelegate(field)
            }
        }
    }

}
