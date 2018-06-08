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


protocol GeofenceSaveDelegate: class {
    func savedGeofence(region: GeofenceRegion)
}


class AddRegionViewController: UIViewController {

    var events: EventType = []
    
    weak var delegate: GeofenceSaveDelegate?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView! {
        didSet {
            noteTextView.addBorder()
            noteTextView.textContainerInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
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
    var selectedLocation: CLLocation!
    
    lazy var locationManager : CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 30
        manager.delegate = self
        return manager
    }()
    
}



extension AddRegionViewController {
    
    @IBAction func regionToMonitor(_ gesture: UITapGestureRecognizer) {
        let touchLocation = gesture.location(in: mapView)
        let coordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        selectedLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        updateMapAnnotation(coordinate: selectedLocation)
    }
    
    @IBAction func saveRegionForMonitoring() {
        guard !events.isEmpty, selectedLocation != nil, let radius = Double(radiusTextField.text ?? "0")
        else { return presentAlert(title: "No monitoring point selected", message: "Please either select entry or exit monitoring states or both") }
        
        saveGeofenceInStorage(coordinate: selectedLocation.coordinate, radius: radius)
    }
    
    func saveGeofenceInStorage(coordinate: CLLocationCoordinate2D, radius: Double) {
        let geofenceRegion = GeofenceRegion(coordinate: selectedLocation.coordinate, radius: radius, eventType: events, note: noteTextView.text)
        do {
            try RealmService.shared.create(object: geofenceRegion)
            delegate?.savedGeofence(region: geofenceRegion)
            closeViewController()
        } catch {
            presentAlert(title: "Error saving the geofence", message: error.localizedDescription)
        }
    }
    
}



extension AddRegionViewController {
    
    @IBAction func monitorEnteringRegion(_ sender: UIButton) {
        if events.contains(.entry) {
            events.remove(.entry)
            sender.setTitle(Fontello.outlinedCircleIcon, for: .normal)
        } else {
            events.insert(.entry)
            sender.setTitle(Fontello.filledCircleIcon, for: .normal)
        }
    }
    
    @IBAction func monitorExitingRegion(_ sender: UIButton) {
        if events.contains(.exit) {
            events.remove(.exit)
            sender.setTitle(Fontello.outlinedCircleIcon, for: .normal)
        } else {
            events.insert(.exit)
            sender.setTitle(Fontello.filledCircleIcon, for: .normal)
        }
    }
    
    @IBAction func closeViewController() {
        navigationController?.popViewController(animated: true)
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
    
    func updateMapAnnotation(coordinate: CLLocation) {
        let annotation = MKPointAnnotation()
        mapView.removeAnnotations(mapView.annotations)
        annotation.coordinate = coordinate.coordinate
        annotation.title = "Selected Region center"
        mapView.addAnnotation(annotation)
    }
    
    private func set(title: String, for barButton: UIBarButtonItem) {
        barButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont(name: Fontello.name, size: 15)!], for: .normal)
        barButton.title = title
    }
    
    private func setMapRegion(forLocation location : CLLocation) {
        let zoomRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        mapView.setRegion(zoomRegion, animated: true)
    }
    
    @IBAction func zoomToUserLocation() {
        guard currentLocation != nil  else { return presentAlert(title: "Unable to get your location", message: "We are unable to get your location. Please check whether you have permitted for the location services or not") }
        setMapRegion(forLocation: currentLocation)
    }
}
