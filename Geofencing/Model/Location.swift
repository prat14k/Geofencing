//
//  Location.swift
//  Geofencing
//
//  Created by Prateek Sharma on 6/8/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation


@objcMembers class Location: Object {
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    
    var coordinate: CLLocationCoordinate2D { return CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
    
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init()
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }
}



