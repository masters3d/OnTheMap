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

class MapViewController: UIViewController, MKMapViewDelegate, ErrorReportingFromNetworkProtocol {

    @IBAction func unwindSegue(segue: UIStoryboardSegue) { }

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBAction func logout(sender: UIBarButtonItem) {
        logoutPerformer()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self

        getUsersLocationsFromServer()
        let locations = getUsersLocations()
        addLocationsToMap(locations)
    }

    @IBAction func refreshUserLocations(sender: UIBarButtonItem) {
        self.presentingAlert = false

        mapView.removeAllAnnotations()
        addLocationsToMap(getUsersLocations())
    }

    func addLocationsToMap(input: [UserLocation]) {
        self.mapView.addAnnotations(
            input.flatMap { $0.annotation }
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

    func getUsersLocations() -> [UserLocation] {
        getUsersLocationsFromServer()
        return UserDefault.getUserLocations()

    }

    //MARK:- Error Reporting Code

    var errorReported: ErrorType?
    var presentingAlert: Bool = false

    func activityIndicatorStart() {
        self.activityIndicator.startAnimating()
    }
    
    func activityIndicatorStop() {
        self.activityIndicator.stopAnimating()
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

        } else {
            pinView!.annotation = annotation
        }

        return pinView
    }

    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {

            if let toOpen = view.annotation?.subtitle! {

                let application = UIApplication.sharedApplication()
                let urlString = toOpen
                let urlStrinCleaned = urlString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                if let url = NSURL(string: urlStrinCleaned) {
                    application.openURL(url)
                } else {
                    let google = "https://www.google.com/webhp?q=" + urlStrinCleaned
                    if let url = NSURL(string: google) {
                        application.openURL(url)
                    }
                }

            }
        }
    }

}
