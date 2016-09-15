//
//  UserLocation.swift
//  OnTheMap
//
//  Created by Cheyo Jimenez on 9/14/16.
//  Copyright © 2016 Cheyo Jimenez. All rights reserved.
//

import Foundation
import MapKit

private func log(input:Any) {
       print("UserLocation json parsing error at line: \(#line)"); print(input);
    }

struct UserLocation {
    let createdAt:String
    let firstName:String
    let lastName:String
    let latitude:Double
    let longitude:Double
    let mapString:String
    let mediaURL:String
    let objectId:String
    let uniqueKey:String
    let updatedAt:String
    
    var coordinate:CLLocationCoordinate2D { return CLLocationCoordinate2D(
                                                latitude: CLLocationDegrees(latitude),
                                                longitude: CLLocationDegrees(longitude))}
    var fullname: String { return "\(firstName) \(lastName)" }

    var annotation:MKAnnotation {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = fullname
                    annotation.subtitle = mediaURL
                    return annotation
                    }
    
    init?(_ input: NSDictionary) {
        // we are seperating each guard so we can find out which one fails
        guard let createdAt 	= input["createdAt"] as? String else { log(input); return nil }
        guard let firstName 	= input["firstName"] as? String	else { log(input); return nil }
        guard let lastName		= input["lastName"] as? String	else { log(input); return nil }
        guard let latitude		= input["latitude"] as? Double  else { log(input); return nil }
        guard let longitude		= input["longitude"] as? Double else { log(input); return nil }
        guard let mapString		= input["mapString"] as? String else { log(input); return nil }
        guard let mediaURL		= input["mediaURL"] as? String 	else { log(input); return nil }
        guard let objectId		= input["objectId"] as? String 	else { log(input); return nil }
        guard let uniqueKey		= input["uniqueKey"] as? String else { log(input); return nil }
        guard let updatedAt		= input["updatedAt"] as? String else { log(input); return nil }
        
        self.createdAt = createdAt
        self.firstName = firstName
        self.lastName = lastName
        self.latitude = latitude
        self.longitude = longitude
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.objectId = objectId
        self.uniqueKey = uniqueKey
        self.updatedAt = updatedAt
    }
}

// SAMPLE DICT
//        {
//            createdAt = "2016-09-14T18:54:07.423Z";
//            firstName = Bryan;
//            lastName = Davis;
//            latitude = "49.2635385";
//            longitude = "-123.1385709";
//            mapString = "Vancouver BC, Canada";
//            mediaURL = "http://www.nytimes.com";
//            objectId = MLPWgVgqqA;
//            uniqueKey = 4240088784;
//            updatedAt = "2016-09-14T18:54:07.423Z";
//        },

//                let annotation = MKPointAnnotation()
//                annotation.coordinate = coordinate
//                annotation.title = "\($0.firstName) \($0.lastName)"
//                annotation.subtitle = $0.mediaURL
//                return annotation
