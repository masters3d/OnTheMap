//
//  PostingViewController.swift
//  OnTheMap
//
//  Created by Cheyo Jimenez on 5/14/16.
//  Copyright © 2016 Cheyo Jimenez. All rights reserved.
//

import UIKit
import MapKit

class PostingViewController:UIViewController{

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var enterLinkTextField: UITextField!
    @IBOutlet weak var enterLocationTextField: UITextField!
    
    @IBOutlet weak var whereAreYouStuding: UILabel!
    
    @IBAction func cancelButton(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func submitButton(sender: UIButton) {
    }
    
    @IBAction func findOnMapButton(sender: UIButton) {
    }
    
//MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        tabBarController?.tabBar.hidden = true
        
        // automaticly sets up the keyboard delegates
        assingDelegateToTextFields()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
        tabBarController?.tabBar.hidden = false
        
        // Part of the text delates methods
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Part of the text delates methods
        subscribeToKeyboardNotifications()
    }
}

    


