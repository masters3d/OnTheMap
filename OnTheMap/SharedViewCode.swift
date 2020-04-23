//
//  SharedViewCode.swift
//  OnTheMap
//
//  Created by Cheyo Jimenez on 5/14/16.
//  Copyright © 2016 Cheyo Jimenez. All rights reserved.
//

import UIKit

// Logging Free function

func warnLog(_ line:Int = #line, file:String = #file) {
    print("Warning line: \(line) file: \(file) ")
}

@discardableResult func warnLog<T>(_ input: T, line:Int = #line, file:String = #file) -> T {
    print("Warning line: \(line) file: \(file) ")
    return input
}



extension ErrorReportingFromNetworkProtocol where Self : UIViewController  {

 func presentErrorPopUp(_ description: String) {
        self.presentingAlert = true
        let errorActionSheet = UIAlertController(title: "Error: Please Try again", message: description, preferredStyle: .alert)
        let tryAgain = UIAlertAction(title: "Okay", style: .default, handler: nil) 
        errorActionSheet.addAction(tryAgain)
        self.present(errorActionSheet, animated: true, completion: {
            self.presentingAlert = false
          })
    }



    // Error reporting
    func reportErrorFromOperation(_ operationError: Error?) {
            print("presenting error:\(presentingAlert)")
        if let operationError = operationError ,
            self.errorReported == nil && presentingAlert == false {
            self.errorReported = operationError
            let descriptionError = operationError.localizedDescription
            self.presentErrorPopUp(descriptionError)
            self.activityIndicatorStop()

        } else {
            self.errorReported = nil
        }
    }

    
    // Log out for all views
    func logoutPerformer(_ block:(() -> Void)? = nil) {
        let logoutActionSheet = UIAlertController(title: "Confirmation Required", message: "Are you sure you want to logout?", preferredStyle: .alert)
        let logoutConfirmed = UIAlertAction(title: "Logout", style: .destructive, handler: { Void in
            self.dismiss(animated: true, completion: nil)
            if let block = block {
                block()
            }
            
            // NETWORK CALL: Logging out Deleting
            self.activityIndicatorStart()
            let logoutNetworkOperation = NetworkOperation(typeOfConnection: ConnectionType.deleteSession)
                logoutNetworkOperation.delegate = self
                logoutNetworkOperation.completionBlock = {
                    DispatchQueue.main.async(execute: {
                    self.activityIndicatorStop()
                    print("log out successfull")
                    // Deleting user Defaults Values
                    UserDefault.deleteUserSavedData()
                    })
                }
            logoutNetworkOperation.start()
            // END OF NETWORK CALL: Logging out Deleting

        })

        logoutActionSheet.addAction(logoutConfirmed)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        logoutActionSheet.addAction(cancel)
        present(logoutActionSheet, animated: true, completion: {
            self.presentingAlert = false
        })
    }
}


//MARK:-Keyboard code
extension UIViewController:UITextFieldDelegate, UITextViewDelegate {

    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0.0
    }
    // this needs to be overitten by class that wants keboard support
    @objc func keyboardWillShow(_ notification: Notification) {
    }

    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // Hide the keyboard when user hits the return key
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // This function gets called inside the view so to set the instance as the delegate
    func setDelegate(_ field: UITextField) {
        field.delegate = self
    }

    // Automaticly sets the deltegates to all the UITextFields including the sub views
    func assingDelegateToTextFields() {

        // recursive function to find all the sub views in a view
        func getAllSubViews(_ input: [UIView]) -> [UIView] {

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
