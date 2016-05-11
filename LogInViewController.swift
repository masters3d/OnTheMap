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
        
        let networkOperation  = NetworkOperation(url: NSURL(string: "https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png")!, keyForData: "imageAvatar")
        
        networkOperation.completionBlock = {
            if let data = NSUserDefaults.standardUserDefaults().dataForKey("imageAvatar"),
                let image = UIImage(data: data){
                
                
                dispatch_async(dispatch_get_main_queue(), {
                    let logo = self.view.viewWithTag(9) as? UIImageView
                    logo?.image = image

                })
              
            }
        }
        networkOperation.start()
        

    }
    
    @IBAction func singupOnTheWeb(sender: UIButton) {
        if let udacitySignupURL = NSURL(string: Udacity.urlSignUp) {
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
        NSUserDefaults.standardUserDefaults().setObject(emailTextField.text, forKey: Udacity.userEmail)
        NSUserDefaults.standardUserDefaults().setObject(passwordTextField.text, forKey: Udacity.userPassword)
    }
    
    private func loadCredentialsFromUserDefaults(){
        let defaults = NSUserDefaults.standardUserDefaults()
        if let udacityUserEmail = defaults.stringForKey(Udacity.userEmail) {
            let udacityUserPassword = defaults.stringForKey(Udacity.userPassword)
            emailTextField.text = udacityUserEmail
            passwordTextField.text = udacityUserPassword
        }
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
