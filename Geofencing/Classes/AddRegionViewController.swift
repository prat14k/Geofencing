//
//  AddRegionViewController.swift
//  Geofencing
//
//  Created by Prateek Sharma on 6/7/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class AddRegionViewController: UIViewController {

    
    var isEntryMonitoringSelected: Bool = false
    var isExitMonitoringSelected: Bool = false
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView! {
        didSet {
            noteTextView.addBorder()
            noteTextView.textContainerInset = UIEdgeInsets.zero
            noteTextView.textContainer.lineFragmentPadding = 0
        }
    }
    
    @IBOutlet weak var entryMonitoringButton: UIButton! {
        didSet {
            entryMonitoringButton.setTitle(Fontello.outlinedCircleIcon, for: .normal)
        }
    }
    @IBOutlet weak var exitMonitoringButton: UIButton! {
        didSet {
            exitMonitoringButton.setTitle(Fontello.outlinedCircleIcon, for: .normal)
        }
    }
    
    @IBOutlet weak var userLocationBarButton: UIBarButtonItem! {
        didSet {
            set(title: Fontello.locationIcon, for: userLocationBarButton)
        }
    }
    
    var currentLocation: CLLocation!
    
    lazy var locationManager : CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 30
        manager.delegate = self
        return manager
    }()
    
}



extension AddRegionViewController {
    
    @IBAction func monitorEnteringRegion(_ sender: UIButton) {
        isEntryMonitoringSelected = !isEntryMonitoringSelected
        let title = isEntryMonitoringSelected ? Fontello.filledCircleIcon : Fontello.outlinedCircleIcon
        sender.setTitle(title, for: .normal)
    }
    
    @IBAction func monitorExitingRegion(_ sender: UIButton) {
        isExitMonitoringSelected = !isExitMonitoringSelected
        let title = isExitMonitoringSelected ? Fontello.filledCircleIcon : Fontello.outlinedCircleIcon
        sender.setTitle(title, for: .normal)
    }
    
    @IBAction func cancelAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveRegionForMonitoring() {
        guard isExitMonitoringSelected || isEntryMonitoringSelected
        else { return presentAlert(title: "No monitoring point selected", message: "Please either select entry or exit monitoring states or both") }
    }
    
}


extension AddRegionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationAuthStatusConfigure()
    }
    
    func locationAuthStatusConfigure() {
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
}

extension AddRegionViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        else if status == .authorizedAlways || status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        }
    }
    
}


extension AddRegionViewController {
    
    private func set(title: String, for barButton: UIBarButtonItem) {
        barButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont(name: Fontello.name, size: 15)!], for: .normal)
        barButton.title = title
    }
    
    private func setMapRegion(forLocation location : CLLocation) {
        let zoomRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4))
        mapView.setRegion(zoomRegion, animated: true)
    }
    
    @IBAction func zoomToUserLocation() {
        guard currentLocation == nil  else { return presentAlert(title: "Unable to get your location", message: "We are unable to get your location. Please check whether you have permitted for the location services or not") }
        setMapRegion(forLocation: currentLocation)
    }
}
