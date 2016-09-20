//
//  PostingViewController.swift
//  OnTheMap
//
//  Created by Cheyo Jimenez on 5/14/16.
//  Copyright © 2016 Cheyo Jimenez. All rights reserved.
//

import UIKit
import MapKit

class PostingViewController: UIViewController, ErrorReportingFromNetworkProtocol {

    // temp storage for the Location
    var locationTosSubmit: CLLocation?
    var locationString: String?
    
    
    //MARK:- Error Reporting Code

    var errorReported: ErrorType?
    var presentingAlert: Bool = false
    
    func activityIndicatorStart() {
        self.activityIndicator.startAnimating()
    }
    
    func activityIndicatorStop() {
        self.activityIndicator.stopAnimating()
    }

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var enterLinkTextField: UITextField!
    @IBOutlet weak var enterLocationTextField: UITextField!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backgroundCover: UIView!
    @IBOutlet weak var whereAreYouStuding: UILabel!

    @IBOutlet weak var submitButton: UIButton!
    @IBAction func submitButton(sender: UIButton) {
        guard let link = enterLinkTextField.text else { return }
        if link.isEmpty {
            self.presentErrorPopUp("Please Enter a Web Link", presentingError: &presentingAlert)
        }

        guard let payload = createJSONPostforLoggedInUser() else { return }
        UserDefault.postParsePayload = payload

        guard let userID = UserDefault.getUserId() else { return }

        if  UserDefault.getUserLocations().map({$0.uniqueKey}).contains(userID) {

            // confirm overide and run the code
            confirmOveride()

        } else {

            // Post a new location
            postingNewLocation()

        }
    }

    func postingNewLocation() {
        // Posting
        self.activityIndicator.startAnimating()
        let postingLocationNetwork = NetworkOperation(typeOfConnection: ConnectionType.postLoggedInStudentLocation)
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

    func putUpdatingLocation() {

        self.activityIndicator.startAnimating()

        //Getting Current student location
        let currentStudentLocations = NetworkOperation(typeOfConnection: ConnectionType.getLoggedInStudentMultipleLocations)
        currentStudentLocations.delegate = self

        // Posting PUT Updating.
        let putUpdatingLocationNetwork = NetworkOperation(typeOfConnection: ConnectionType.putUpdateStudentLocation)
        putUpdatingLocationNetwork.delegate = self

        putUpdatingLocationNetwork.completionBlock = {
            dispatch_async(dispatch_get_main_queue(), {
                self.activityIndicator.stopAnimating()

                // sucesss go back to the map view
                self.navigationController?.popViewControllerAnimated(true)
            })
        }

        //chaining up Operations
        putUpdatingLocationNetwork.addDependency(currentStudentLocations)
        let networkQueue = NSOperationQueue()
        networkQueue.addOperation(currentStudentLocations)
        networkQueue.addOperation(putUpdatingLocationNetwork)

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

    func confirmOveride() {
        let overrideLocationActionSheet = UIAlertController(title: "Confirmation Required", message: "Are you sure you want to overide Location?", preferredStyle: .Alert)
        let confirmed = UIAlertAction(title: "Overide", style: .Destructive, handler: { Void in

            // update location Network call
            self.putUpdatingLocation()

        })

        overrideLocationActionSheet.addAction(confirmed)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        overrideLocationActionSheet.addAction(cancel)
        presentViewController(overrideLocationActionSheet, animated: true, completion: {
            self.presentingAlert = false
        })
    }

    @IBOutlet weak var findOnMapButton: UIButton!
    @IBAction func findOnMapButton(sender: UIButton) {
        activityIndicator.startAnimating()

        let geocoder = CLGeocoder()

        guard let inputLocation = enterLocationTextField.text where !inputLocation.isEmpty
            else {
                self.presentErrorPopUp("Please enter a location", presentingError: &self.presentingAlert )
                self.activityIndicator.stopAnimating()
                return
                }

        geocoder.geocodeAddressString(inputLocation) { (placemarkArray, error) in

            if let error = error {
                self.reportErrorFromOperation(error)
                self.activityIndicator.stopAnimating()
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

                self.enterLocationTextField.hidden = true
                self.enterLinkTextField.hidden = false
                self.backgroundCover.hidden = true
                self.submitButton.hidden = false
                self.findOnMapButton.hidden = true
                
                self.activityIndicator.stopAnimating()
                
                
            } else {
                self.presentErrorPopUp("Please try again", presentingError: &self.presentingAlert )
                self.activityIndicator.stopAnimating()
            }

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

