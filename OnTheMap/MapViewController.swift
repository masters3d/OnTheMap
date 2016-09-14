//
//  Created by Cheyo Jimenez on 10/30/15.
//  Copyright © 2015 Cheyo Jimenez. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate, ErrorReportingFromNetworkProtocol{
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBAction func logout(sender: UIBarButtonItem) {
         logoutPerformer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    @IBAction func refreshUserLocations(sender: UIBarButtonItem) {
        self.presentingAlert = false
        getUsersLocationsFromServer()
    }
    func getUsersLocationsFromServer() {
    
        activityIndicator.startAnimating()
        let userLocationOperation = NetworkOperation(typeOfConnection: .getStudentLocationsWithLimit)
        userLocationOperation.delegate = self
        userLocationOperation.completionBlock = {
            dispatch_async(dispatch_get_main_queue(), {
                
                var usersLocations = [UserLocation]()
                if let dict = UserDefault.getParseUserLocations(),
                    let arrayDict = dict["results"] as? NSArray,
                    let result = arrayDict as? [NSDictionary] {
                    
                    usersLocations = result.flatMap{UserLocation($0)}
                }
                self.mapView.addAnnotations(
                    usersLocations.flatMap{
                        let lat = CLLocationDegrees($0.latitude)
                        let long = CLLocationDegrees($0.longitude)
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = "\($0.firstName) \($0.lastName)"
                        annotation.subtitle = $0.mediaURL
                        return annotation
                    }
                )
                
            self.activityIndicator.stopAnimating()
            })
        }
        userLocationOperation.start()
    
    }
    
//    func getUsersLocations() -> [UserLocation]{
//        var usersLocations = [UserLocation]()
//        
//        if UserDefault.getParseUserLocations() == nil {
//            getUsersLocationsFromServer()
//        }
//        
//        if let dict = UserDefault.getParseUserLocations(),
//            let arrayDict = dict["results"] as? NSArray,
//            let result = arrayDict as? [NSDictionary] {
//            usersLocations = result.flatMap(UserLocation.init)
//        }
//        return usersLocations
//    }

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

    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
//        func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//    
//            if control == annotationView.rightCalloutAccessoryView {
//                let app = UIApplication.sharedApplication()
//                app.openURL(NSURL(string: annotationView.annotation.subtitle))
//            }
//        }

    // MARK: - Sample Data
    
    // Some sample data. This is a dictionary that is more or less similar to the
    // JSON data that you will download from Parse.
    
    func locationData() -> [[String : AnyObject]] {
        return  [
            [
                "createdAt" : "2015-02-24T22:27:14.456Z",
                "firstName" : "Jessica",
                "lastName" : "Uelmen",
                "latitude" : 28.1461248,
                "longitude" : -82.75676799999999,
                "mapString" : "Tarpon Springs, FL",
                "mediaURL" : "www.linkedin.com/in/jessicauelmen/en",
                "objectId" : "kj18GEaWD8",
                "uniqueKey" : 872458750,
                "updatedAt" : "2015-03-09T22:07:09.593Z"
            ], [
                "createdAt" : "2015-02-24T22:35:30.639Z",
                "firstName" : "Gabrielle",
                "lastName" : "Miller-Messner",
                "latitude" : 35.1740471,
                "longitude" : -79.3922539,
                "mapString" : "Southern Pines, NC",
                "mediaURL" : "http://www.linkedin.com/pub/gabrielle-miller-messner/11/557/60/en",
                "objectId" : "8ZEuHF5uX8",
                "uniqueKey" : 2256298598,
                "updatedAt" : "2015-03-11T03:23:49.582Z"
            ], [
                "createdAt" : "2015-02-24T22:30:54.442Z",
                "firstName" : "Jason",
                "lastName" : "Schatz",
                "latitude" : 37.7617,
                "longitude" : -122.4216,
                "mapString" : "18th and Valencia, San Francisco, CA",
                "mediaURL" : "http://en.wikipedia.org/wiki/Swift_%28programming_language%29",
                "objectId" : "hiz0vOTmrL",
                "uniqueKey" : 2362758535,
                "updatedAt" : "2015-03-10T17:20:31.828Z"
            ], [
                "createdAt" : "2015-03-11T02:48:18.321Z",
                "firstName" : "Jarrod",
                "lastName" : "Parkes",
                "latitude" : 34.73037,
                "longitude" : -86.58611000000001,
                "mapString" : "Huntsville, Alabama",
                "mediaURL" : "https://linkedin.com/in/jarrodparkes",
                "objectId" : "CDHfAy8sdp",
                "uniqueKey" : 996618664,
                "updatedAt" : "2015-03-13T03:37:58.389Z"
            ]
        ]
    }

    
}

