//
//  BaseMapViewController.swift
//  Geofencing
//
//  Created by Prateek Sharma on 6/13/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit
import CoreLocation


class BaseMapViewController: UIViewController, LocationManagerProtocol {

    var currentLocation: CLLocation!
    
    lazy var locationManager = create()
    var isLocationAlwaysPermissionProvided: Bool { return CLLocationManager.authorizationStatus() == .authorizedAlways }
    var isLocationWhenInUsePermissionProvided: Bool { return CLLocationManager.authorizationStatus() == .authorizedWhenInUse }
    
    @IBOutlet weak private var userLocationBarButton: UIBarButtonItem! {
        didSet {
            set(title: Fontello.locationIcon, for: userLocationBarButton)
        }
    }
    
    
    func set(title: String, for barButton: UIBarButtonItem) {
        barButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont(name: Fontello.name, size: 15)!], for: .normal)
        barButton.title = title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationAuthStatusConfigure()
    }
    
    func locationAuthStatusConfigure() {
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            presentAlert(title: "Geofencing cannot be done", message: "You must need to authorize always location for geofencing.")
        }
    }
    
}

extension BaseMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationAuthStatusConfigure()
    }
    
}
