//
//  LogInViewController.swift
//  OnTheMap
//
//  Created by Cheyo Jimenez on 10/30/15.
//  Copyright © 2015 Cheyo Jimenez. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var loginGraphic: UIButton!
    
    @IBAction func loginToUdacity(sender: UIButton) {
        saveCredentialsToUserDefaults()
        self.view.endEditing(true)
        
        let networkOp = NetworkOperation(typeOfConnection: .login, spinner: activityIndicator)
        
        networkOp.start()

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
