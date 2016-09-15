//
//  Created by Cheyo Jimenez on 10/30/15.
//  Copyright © 2015 Cheyo Jimenez. All rights reserved.
//

import UIKit
import MapKit

extension MKMapView {
    func removeAllAnnotations() {
        self.removeAnnotations(annotations)
    }
}


class MapViewController: UIViewController, MKMapViewDelegate, ErrorReportingFromNetworkProtocol{
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func logout(sender: UIBarButtonItem) {
         logoutPerformer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        addLocationsToMap(getUsersLocations())
    }
    
    @IBAction func refreshUserLocations(sender: UIBarButtonItem) {
        self.presentingAlert = false
        
        mapView.removeAllAnnotations()
        addLocationsToMap(getUsersLocations())
    }
    
    func addLocationsToMap(input:[UserLocation]) {
        self.mapView.addAnnotations(
            input.flatMap{ $0.annotation }
        )
        
    }
    func getUsersLocationsFromServer() {
    
        activityIndicator.startAnimating()
        let userLocationOperation = NetworkOperation(typeOfConnection: .getStudentLocationsWithLimit)
        userLocationOperation.delegate = self
        userLocationOperation.completionBlock = {
            dispatch_async(dispatch_get_main_queue(), {
    
            self.activityIndicator.stopAnimating()
            })
        }
        userLocationOperation.start()
    
    }
    
    func getUsersLocations() -> [UserLocation]{
        var usersLocations = [UserLocation]()
        
        getUsersLocationsFromServer()
        
        if let dict = UserDefault.getParseUserLocations(),
            let arrayDict = dict["results"] as? NSArray,
            let result = arrayDict as? [NSDictionary] {
            usersLocations = result.flatMap(UserLocation.init)
        }
        return usersLocations
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

    
}

