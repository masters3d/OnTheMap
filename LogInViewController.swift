//
//  LogInViewController.swift
//  OnTheMap
//
//  Created by Cheyo Jimenez on 10/30/15.
//  Copyright © 2015 Cheyo Jimenez. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController,ErrorReportingFromNetworkProtocol {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var loginGraphic: UIButton!
    
    @IBAction func loginToUdacity(sender: UIButton) {
        saveCredentialsToUserDefaults()
        self.view.endEditing(true)
        activityIndicator.startAnimating()
        
        let networkOpUdacityLogin       = NetworkOperation(typeOfConnection: .login )
        let networkOpGetUdacityFullName = NetworkOperation(typeOfConnection: .getFullName)
        networkOpUdacityLogin.delegate = self
        networkOpGetUdacityFullName.delegate = self
        networkOpGetUdacityFullName.addDependency(networkOpUdacityLogin)
        networkOpGetUdacityFullName.completionBlock = {
            dispatch_async(dispatch_get_main_queue(), {
                if self.shouldPerformSegueWithIdentifier("loginUdacitySeg", sender: nil) {
                    self.activityIndicator.stopAnimating()
                    self.performSegueWithIdentifier("loginUdacitySeg", sender: nil) }
            })
        }
        // this should excecute the operations in order.
       let networkQueue = NSOperationQueue()
        networkQueue.addOperation(networkOpUdacityLogin)
        networkQueue.addOperation(networkOpGetUdacityFullName)
  
    }
    
    @IBAction func singupOnTheWeb(sender: UIButton) {
        if let udacitySignupURL = NSURL(string: Udacity.urlSignUpString) {
            UIApplication.sharedApplication().openURL(udacitySignupURL)
        }
    }
    
//MARK:- Error Reporting Code
    
    private(set) var errorReported:ErrorType?
    private var presentingAlert:Bool = false
    
    func reportErrorFromOperation(operationError: ErrorType?) {
        if let operationError = operationError where
            self.errorReported == nil && presentingAlert == false {
            self.errorReported = operationError
            let descriptionError = (operationError as NSError).localizedDescription
            self.presentErrorPopUp(descriptionError, presentingError: &presentingAlert)
            self.activityIndicator.stopAnimating()
            
        } else {
            self.errorReported = nil
        }
    }
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "loginUdacitySeg" && (errorReported != nil  || presentingAlert == true){
            return false
        }
        return true
    }
//MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assingDelegateToTextFields()
        loadCredentialsFromUserDefaults()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
}


// MARK: Text Field Deleagates
extension LogInViewController{
    
    //Keyboard will show and hide
    override func keyboardWillShow(notification: NSNotification) {
        if emailTextField.isFirstResponder() || passwordTextField.isFirstResponder(){
            view.frame.origin.y = -self.loginGraphic.bounds.minY - 8 // sits righ underneeth loginGraphic
        }
    }
    
}

// MARK: User Default
extension LogInViewController{
    
    private func saveCredentialsToUserDefaults(){
        UserDefault.setCredentials(emailTextField.text ?? "", password: passwordTextField.text ?? "")
    }
    
    private func loadCredentialsFromUserDefaults(){
        let (email, password) = UserDefault.getCredentials()
        emailTextField.text = email
        passwordTextField.text = password
    }
}
