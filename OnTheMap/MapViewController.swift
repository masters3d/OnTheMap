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

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) { }

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBAction func logout(_ sender: UIBarButtonItem) {
        logoutPerformer()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self

        getUsersLocationsFromServer()
        let locations = getUsersLocations()
        addLocationsToMap(locations)
    }

    @IBAction func refreshUserLocations(_ sender: UIBarButtonItem) {
        self.presentingAlert = false

        mapView.removeAllAnnotations()
        addLocationsToMap(getUsersLocations())
    }

    func addLocationsToMap(_ input: [UserLocation]) {
        self.mapView.addAnnotations(
            input.flatMap { $0.annotation }
        )

    }
    func getUsersLocationsFromServer() {

        activityIndicator.startAnimating()
        let userLocationOperation = NetworkOperation(typeOfConnection: .getStudentLocationsWithLimit)
        userLocationOperation.delegate = self
        userLocationOperation.completionBlock = {
            DispatchQueue.main.async(execute: {
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

    var errorReported: Error?
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
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

        } else {
            pinView!.annotation = annotation
        }

        return pinView
    }

    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {

            if let toOpen = view.annotation?.subtitle! {

                let application = UIApplication.shared
                let urlString = toOpen
                let urlStrinCleaned = urlString.trimmingCharacters(in: CharacterSet.whitespaces)
                if let url = URL(string: urlStrinCleaned) {
                    application.openURL(url)
                } else {
                    let google = "https://www.google.com/webhp?q=" + urlStrinCleaned
                    if let url = URL(string: google) {
                        application.openURL(url)
                    }
                }

            }
        }
    }

}
