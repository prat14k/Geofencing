//
//  PinAnnotation.swift
//  Geofencing
//
//  Created by Prateek Sharma on 6/8/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


class PinAnnotation: NSObject, MKAnnotation {

    var title: String?
    var subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let identifier: UUID
    
    init(identifier: UUID, coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
        self.identifier = identifier
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
    
}
