//
//  LogInViewController.swift
//  OnTheMap
//
//  Created by Cheyo Jimenez on 10/30/15.
//  Copyright © 2015 Cheyo Jimenez. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, ErrorReportingFromNetworkProtocol {

    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var loginGraphic: UIButton!

    @IBAction func loginToUdacity(_ sender: UIButton) {
        UserDefault.setCredentials(emailTextField.text ?? warnLog(""), password: passwordTextField.text ?? warnLog(""))

        self.view.endEditing(true)
        activityIndicator.startAnimating()
        self.presentingAlert = false

        let networkOpUdacityLogin       = NetworkOperation(typeOfConnection: .login )
        let networkOpGetUdacityFullName = NetworkOperation(typeOfConnection: .getFullName)
        networkOpUdacityLogin.delegate = self
        networkOpGetUdacityFullName.delegate = self
        networkOpGetUdacityFullName.addDependency(networkOpUdacityLogin)
        networkOpGetUdacityFullName.completionBlock = {
            DispatchQueue.main.async(execute: {
                if self.shouldPerformSegue(withIdentifier: "loginUdacitySeg", sender: nil) {
                    self.activityIndicator.stopAnimating()
                    self.performSegue(withIdentifier: "loginUdacitySeg", sender: nil) }
            })
        }
        // this should excecute the operations in order.
        let networkQueue = OperationQueue()
        networkQueue.addOperation(networkOpUdacityLogin)
        networkQueue.addOperation(networkOpGetUdacityFullName)

    }

    @IBAction func singupOnTheWeb(_ sender: UIButton) {
        if let udacitySignupURL = URL(string: Udacity.urlSignUpString) {
            UIApplication.shared.openURL(udacitySignupURL)
        }
    }

    //MARK:- Error Reporting Code

    var errorReported: Error?
    var presentingAlert: Bool = false
    
    func activityIndicatorStart() {
        self.activityIndicator.startAnimating()
    }
    
    func activityIndicatorStop() {
        self.activityIndicator.stopAnimating()
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "loginUdacitySeg" && (errorReported != nil  || presentingAlert == true) {
            return false
        }
        return true
    }
    //MARK:- Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let (email, password) = UserDefault.getCredentials() ?? (warnLog(""), warnLog(""))

        emailTextField.text  = email
        passwordTextField.text = password

        // part of the text delegates
        assingDelegateToTextFields()

        //log in if the credential are already saved

        DispatchQueue.main.async(execute: {
            if (!email.isEmpty && !password.isEmpty) {
                self.performSegue(withIdentifier: "loginUdacitySeg", sender: nil)
            }
        })

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //part of the Text delefates handeling
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        //part of the Text delefates handeling
        unsubscribeFromKeyboardNotifications()
    }
}

// MARK: Text Field Deleagates
extension LogInViewController {

    //Keyboard will show and hide
    override func keyboardWillShow(_ notification: Notification) {
        if emailTextField.isFirstResponder || passwordTextField.isFirstResponder {
            view.frame.origin.y = -self.loginGraphic.bounds.minY - 8 // sits righ underneeth loginGraphic
        }
    }
}
