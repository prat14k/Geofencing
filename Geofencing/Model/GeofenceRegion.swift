//
//  GeofenceRegion.swift
//  Geofencing
//
//  Created by Prateek Sharma on 6/8/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation
import MapKit



@objcMembers class GeofenceRegion: Object {
    dynamic var radius: Double = 0
    dynamic let identifier = UUID()
    dynamic var note: String?
    dynamic var eventType: EventType = .entry
    dynamic var location: Location!
    
    convenience init(coordinate: CLLocationCoordinate2D, radius: Double, eventType: EventType, note: String? = nil) {
        self.init()
        self.location = Location(coordinate: coordinate)
        self.radius = radius
        self.note = note
        self.eventType = eventType
    }
    
}

