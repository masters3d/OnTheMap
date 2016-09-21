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

    var errorReported: Error?
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
    @IBAction func submitButton(_ sender: UIButton) {
        guard let link = enterLinkTextField.text else { return }
        if link.isEmpty {
            self.presentErrorPopUp("Please Enter a Web Link")
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
            DispatchQueue.main.async(execute: {
                self.activityIndicator.stopAnimating()

                // sucesss go back to the map view
                self.dismiss(animated: true, completion: nil)
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
            DispatchQueue.main.async(execute: {
                self.activityIndicator.stopAnimating()

                // sucesss go back to the map view
                self.dismiss(animated: true, completion: nil)
            })
        }

        //chaining up Operations
        putUpdatingLocationNetwork.addDependency(currentStudentLocations)
        let networkQueue = OperationQueue()
        networkQueue.addOperation(currentStudentLocations)
        networkQueue.addOperation(putUpdatingLocationNetwork)

    }

    func createJSONPostforLoggedInUser() -> Data? {

        let latitude = locationTosSubmit?.coordinate.latitude.description ?? warnLog("0.00")
        let longitude = locationTosSubmit?.coordinate.longitude.description ?? warnLog("0.00")

        let postHTTPJSON: [String : Any] =
            ["uniqueKey":  UserDefault.getUserId()                            ?? warnLog(""),
             "firstName":  UserDefault.getFullNameFromJSONDictionary()?.fist   ?? warnLog(""),
             "lastName":  UserDefault.getFullNameFromJSONDictionary()?.last    ?? warnLog(""),
             "mapString":  locationString                                      ?? warnLog(""),
             "mediaURL":  enterLinkTextField.text                              ?? warnLog(""),
             "latitude":  Double(latitude) ?? warnLog(0.00),
             "longitude":  Double(longitude) ?? warnLog(0.00) ]

        return try? JSONSerialization.data(withJSONObject: postHTTPJSON, options: JSONSerialization.WritingOptions())

    }

    func confirmOveride() {
        let overrideLocationActionSheet = UIAlertController(title: "Confirmation Required", message: "Are you sure you want to overide Location?", preferredStyle: .alert)
        let confirmed = UIAlertAction(title: "Overide", style: .destructive, handler: { Void in

            // update location Network call
            self.putUpdatingLocation()

        })

        overrideLocationActionSheet.addAction(confirmed)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        overrideLocationActionSheet.addAction(cancel)
        present(overrideLocationActionSheet, animated: true, completion: {
            self.presentingAlert = false
        })
    }

    @IBOutlet weak var findOnMapButton: UIButton!
    @IBAction func findOnMapButton(_ sender: UIButton) {
        activityIndicator.startAnimating()

        let geocoder = CLGeocoder()

        guard let inputLocation = enterLocationTextField.text , !inputLocation.isEmpty
            else {
                self.presentErrorPopUp("Please enter a location")
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

                self.enterLocationTextField.isHidden = true
                self.enterLinkTextField.isHidden = false
                self.backgroundCover.isHidden = true
                self.submitButton.isHidden = false
                self.findOnMapButton.isHidden = true
                
                self.activityIndicator.stopAnimating()
                
                
            } else {
                self.presentErrorPopUp("Please try again")
                self.activityIndicator.stopAnimating()
            }

        }
    }


    //MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = true

        // hide the web link
        self.enterLinkTextField.isHidden = true

        // automaticly sets up the keyboard delegates
        assingDelegateToTextFields()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        tabBarController?.tabBar.isHidden = false

        // Part of the text delates methods
        unsubscribeFromKeyboardNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Part of the text delates methods
        subscribeToKeyboardNotifications()
    }
}

