//
//  PostingViewController.swift
//  OnTheMap
//
//  Created by Cheyo Jimenez on 5/14/16.
//  Copyright © 2016 Cheyo Jimenez. All rights reserved.
//

import UIKit
import MapKit

class PostingViewController:UIViewController, ErrorReportingFromNetworkProtocol{

    var locationTosSubmit:CLLocation?
    var urlToSubmit:NSURL?

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var enterLinkTextField: UITextField!
    @IBOutlet weak var enterLocationTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backgroundCover: UIView!
    @IBOutlet weak var whereAreYouStuding: UILabel!
    
    @IBAction func cancelButton(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBOutlet weak var submitButton: UIButton!
    @IBAction func submitButton(sender: UIButton) {
    }
    
    @IBOutlet weak var findOnMapButton: UIButton!
    @IBAction func findOnMapButton(sender: UIButton) {
        enterLocationTextField.hidden = true
        enterLinkTextField.hidden = false
        backgroundCover.hidden = true
        submitButton.hidden = false
        findOnMapButton.hidden = true
        
        activityIndicator.startAnimating()
        
        let geocoder = CLGeocoder()
        
        
        let inputLocation = enterLocationTextField.text ?? ""
        
        geocoder.geocodeAddressString(inputLocation) { (placemarkArray, error) in
        
        if let error = error {
            self.reportErrorFromOperation(error)
        }
        
        if let placemark = placemarkArray?.first,
            let location = placemark.location {
            
            self.locationTosSubmit = location
            let regionCenter = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                    longitude: location.coordinate.longitude)
            let mapRegion = MKCoordinateRegion(center: regionCenter, span: MKCoordinateSpanMake(0.25, 0.25))

            self.mapView.setRegion(mapRegion, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            self.mapView.addAnnotation(annotation)
            
            self.activityIndicator.stopAnimating()
        }
        
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
    
    
//MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        tabBarController?.tabBar.hidden = true
        
        
        // hide the web link
        self.enterLinkTextField.hidden = true
        
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

    


