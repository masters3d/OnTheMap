//
//  LogInViewController.swift
//  OnTheMap
//
//  Created by Cheyo Jimenez on 10/30/15.
//  Copyright © 2015 Cheyo Jimenez. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController,ErrorReportingFromNetworkProtocol {
    
    private(set) var errorReported:ErrorType?
    
    func reportErrorFromOperation(operationError: ErrorType?) {
        if let operationError = operationError {
            self.errorReported = operationError
            let descriptionError = (operationError as NSError).localizedDescription
            let errorActionSheet = UIAlertController(title: "Error", message: descriptionError, preferredStyle: .Alert)
            let tryAgain = UIAlertAction(title: "Try Again?", style: .Default, handler: nil)
            errorActionSheet.addAction(tryAgain)
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            errorActionSheet.addAction(cancel)
            self.presentViewController(errorActionSheet, animated: true, completion: { self.activityIndicator.stopAnimating() })
        } else {
            self.errorReported = nil
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "loginUdacitySeg" && errorReported != nil {
            return false
        }
        return true
    }
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

// MARK: Text Field Deleagates
extension LogInViewController: UITextFieldDelegate, UITextViewDelegate{
    
    // this sets the delagates on all the text fields in this view.
    func assingDelegateToTextFields(){
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LogInViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LogInViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //Keyboard will show and hide
    func keyboardWillShow(notification: NSNotification) {
        if emailTextField.isFirstResponder() || passwordTextField.isFirstResponder(){
            view.frame.origin.y = -self.loginGraphic.bounds.minY - 8 // sits righ underneeth loginGraphic
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0.0
    }
    
    // Hide the keyboard when user hits the return key
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    } 
    
}
