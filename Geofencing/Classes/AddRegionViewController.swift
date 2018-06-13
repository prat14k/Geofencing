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
            presentAlert(title: "No monitoring point selected", message: "Please either select entry or exit monitoring states or both")
            return false
        }
        return true
    }
    
    @IBAction private func saveRegionForMonitoring() {
        guard isUserInputValid() else { return }
        saveGeofenceInStorage(coordinate: selectedLocation.coordinate, radius: Double(radiusTextField.text ?? "0")!)
    }
    
    private func saveGeofenceInStorage(coordinate: CLLocationCoordinate2D, radius: Double) {
        guard isLocationPermissionProvided  else { return presentAlert(title: "Location Premissions Denied", message: "Please provide the location permissions") }
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
    
    
    private func setMapRegion(for location: CLLocation) {
        let zoomRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        mapView.setRegion(zoomRegion, animated: true)
    }
    
    @IBAction private func zoomToUserLocation() {
        guard currentLocation != nil  else { return presentAlert(title: "Unable to get your location", message: "We are unable to get your location. Please check whether you have permitted for the location services or not") }
        setMapRegion(for: currentLocation)
    }
    
}
