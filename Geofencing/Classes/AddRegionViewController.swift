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


class AddRegionViewController: BaseMapViewController {

    private var events: EventType = []
    private var selectedLocation: CLLocation!
    
    weak var delegate: GeofenceSaveDelegate?
    
    @IBOutlet weak private var mapView: MKMapView!
    @IBOutlet weak private var radiusTextField: UITextField!
    @IBOutlet weak private var noteTextView: UITextView! {
        didSet {
            noteTextView.addBorder()
            noteTextView.textContainerInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
            noteTextView.textContainer.lineFragmentPadding = 0
        }
    }
    
    @IBOutlet weak private var entryMonitoringButton: UIButton! {
        didSet {
            entryMonitoringButton.setTitle(Fontello.outlinedCircleIcon, for: .normal)
        }
    }
    @IBOutlet weak private var exitMonitoringButton: UIButton! {
        didSet {
            exitMonitoringButton.setTitle(Fontello.outlinedCircleIcon, for: .normal)
        }
    }
    
}



extension AddRegionViewController {
    
    @IBAction private func regionToMonitor(_ gesture: UITapGestureRecognizer) {
        let touchLocation = gesture.location(in: mapView)
        let coordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        selectedLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        updateMapAnnotation(coordinate: selectedLocation)
    }
    
    private func isUserInputValid() -> Bool {
        guard !events.isEmpty, selectedLocation != nil,
              let radius = Double(radiusTextField.text ?? "0"),
              radius > 0
        else {
            presentAlert(title: "All required fields not filled", message: "Please check whether you have provided appropriate values for region center(click on the map to select one), monitoring state(entry or exit) and radius for the region")
            return false
        }
        return true
    }
    
    @IBAction private func saveRegionForMonitoring() {
        guard isUserInputValid() else { return }
        saveGeofenceInStorage(coordinate: selectedLocation.coordinate, radius: Double(radiusTextField.text ?? "0")!)
    }
    
    private func saveGeofenceInStorage(coordinate: CLLocationCoordinate2D, radius: Double) {
        guard isLocationAlwaysPermissionProvided  else { return presentAlert(title: "Location Premissions Denied", message: "Please provide the Always location usage permission in the Settings app in order to save regions") }
        let geofenceRegion = GeofenceRegion(identifier: UUID().uuidString, coordinate: selectedLocation.coordinate, radius: radius, eventType: events, note: noteTextView.text)
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
    
    @IBAction private func monitorEnteringRegion(_ sender: UIButton) {
        if events.contains(.entry) {
            events.remove(.entry)
            sender.setTitle(Fontello.outlinedCircleIcon, for: .normal)
        } else {
            events.insert(.entry)
            sender.setTitle(Fontello.filledCircleIcon, for: .normal)
        }
    }
    
    @IBAction private func monitorExitingRegion(_ sender: UIButton) {
        if events.contains(.exit) {
            events.remove(.exit)
            sender.setTitle(Fontello.outlinedCircleIcon, for: .normal)
        } else {
            events.insert(.exit)
            sender.setTitle(Fontello.filledCircleIcon, for: .normal)
        }
    }
    
}


extension AddRegionViewController {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            if currentLocation == nil { setMapRegion(for: location.coordinate) }
            currentLocation = location
            mapView.showsUserLocation = true
        }
    }
    
    @IBAction private func closeViewController() {
        navigationController?.popViewController(animated: true)
    }
    
}


extension AddRegionViewController {
    
    private func updateMapAnnotation(coordinate: CLLocation) {
        let annotation = MKPointAnnotation()
        mapView.removeAnnotations(mapView.annotations)
        annotation.coordinate = coordinate.coordinate
        annotation.title = "Selected Region center"
        mapView.addAnnotation(annotation)
    }
    
    
    private func setMapRegion(for coordinate: CLLocationCoordinate2D) {
        let zoomRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        mapView.setRegion(zoomRegion, animated: true)
    }
    
    @IBAction private func zoomToUserLocation() {
        guard isLocationAlwaysPermissionProvided || isLocationWhenInUsePermissionProvided  else { return presentAlert(title: StringLiterals.unableToLocateError, message: StringLiterals.permissionNotProvided) }
        guard currentLocation != nil  else { return presentAlert(title: StringLiterals.unableToLocateError, message: StringLiterals.internetConnectionProblem) }
        setMapRegion(for: currentLocation.coordinate)
    }
    
}
