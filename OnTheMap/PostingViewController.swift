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
    
    // temp storage for the Location
    var locationTosSubmit:CLLocation?
    var locationString:String?

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
        if let link = enterLinkTextField.text{
            if link.isEmpty {
            self.presentErrorPopUp("Please Enter a Web Link", presentingError: &presentingAlert)
            }
            
            if let payload = createJSONPostforLoggedInUser() {
                UserDefault.postParsePayload = payload
               
                // Posting
                self.activityIndicator.startAnimating()
                let postingLocationNetwork = NetworkOperation.init(typeOfConnection: ConnectionType.postLoggedInStudentLocation)
                postingLocationNetwork.delegate = self
                
                postingLocationNetwork.completionBlock = {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.activityIndicator.stopAnimating()
                        
                        // sucesss go back to the map view
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                }
                postingLocationNetwork.start()
            }
        }
    }
    
    func createJSONPostforLoggedInUser() -> NSData? {
        
        let latitude = locationTosSubmit?.coordinate.latitude.description ?? warnLog("0.00")
        let longitude = locationTosSubmit?.coordinate.longitude.description ?? warnLog("0.00")
        
        let postHTTPJSON =
            ["uniqueKey":  UserDefault.getUserId()                            ?? warnLog(""),
            "firstName":  UserDefault.getFullNameFromJSONDictionary()?.fist   ?? warnLog(""),
            "lastName":  UserDefault.getFullNameFromJSONDictionary()?.last    ?? warnLog(""),
            "mapString":  locationString                                      ?? warnLog(""),
            "mediaURL":  enterLinkTextField.text                              ?? warnLog(""),
            "latitude":  Double(latitude) ?? warnLog(0.00),
            "longitude":  Double(longitude) ?? warnLog(0.00) ]


        return try? NSJSONSerialization.dataWithJSONObject(postHTTPJSON, options: NSJSONWritingOptions())
        
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
        
        
        let inputLocation = enterLocationTextField.text ?? warnLog("")
        
        geocoder.geocodeAddressString(inputLocation) { (placemarkArray, error) in
        
        if let error = error {
            self.reportErrorFromOperation(error)
        }
        
        if let placemark = placemarkArray?.first,
            let location = placemark.location {
            self.locationString = inputLocation
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

    


