//
//  LocationManagerProtocol.swift
//  Geofencing
//
//  Created by Prateek Sharma on 6/14/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import Foundation
import CoreLocation



protocol LocationManagerProtocol {
    var locationManager: CLLocationManager { get }
}
extension LocationManagerProtocol where Self: CLLocationManagerDelegate {
    func create() -> CLLocationManager {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 30
        manager.delegate = self
        return manager
    }
}

