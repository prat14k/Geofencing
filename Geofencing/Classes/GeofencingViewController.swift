//
//  GeofencingViewController.swift
//  Geofencing
//
//  Created by Prateek Sharma on 6/7/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation



class GeofencingViewController: BaseMapViewController {

    lazy private var geofencedRegions: [GeofenceRegion] = RealmService.shared.read(aClass: GeofenceRegion.self)
    
    
    @IBOutlet weak private var addRegionBarButton: UIBarButtonItem! {
        didSet {
            set(title: Fontello.plusIcon, for: addRegionBarButton)
        }
    }
    
    @IBOutlet weak private var geofencedMapView: MKMapView! {
        didSet {
            geofencedMapView.delegate = self
        }
    }
    @IBOutlet weak private var segmentControlBackgroundView: UIView! {
        didSet {
            segmentControlBackgroundView.applyShadow()
        }
    }
    
}

extension GeofencingViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.addRegionVCSegue, let vc = segue.destination as? AddRegionViewController {
            vc.delegate = self
        }
    }
    
}

extension GeofencingViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showGeofencedRegion(eventType: .both)
    }
    
    private func showGeofencedRegion(eventType: EventType) {
        geofencedMapView.removeOverlays(geofencedMapView.overlays)
        geofencedMapView.removeAnnotations(geofencedMapView.annotations)
        guard eventType != .both  else { return addGeofencedRegionsToMap(regions: geofencedRegions) }
        let regions = geofencedRegions.filter { $0.eventType.contains(eventType) }
        addGeofencedRegionsToMap(regions: regions)
    }
    
    private func addGeofencedRegionsToMap(regions: [GeofenceRegion]) {
        for region in regions {
            addAnnotation(coordinate: region.location.coordinate, identifier: region.identifier, title: "Radius: \(region.radius) - \(region.eventType.detail)", subtitle: region.note)
            startMonitoring(region: region)
            addCircleOnMap(region: region)
        }
    }
    
}



extension GeofencingViewController: Notifiable {
    
    private func handleMonitoring(event: EventType, regionIdentifier: String) {
        guard let uuid = UUID(uuidString: regionIdentifier),
            let (index, geofenceRegion) = geofencedRegions.region(for: uuid)
            else { return }
        triggerNotification(title: "Region \(index+1) \(event.detail)", subtitle: "Radius \(geofenceRegion.radius)", description: geofenceRegion.note ?? "")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        handleMonitoring(event: .entry, regionIdentifier: region.identifier)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        handleMonitoring(event: .exit, regionIdentifier: region.identifier)
    }
    
}

extension GeofencingViewController {
    
    private func addAnnotation(coordinate: CLLocationCoordinate2D, identifier: UUID, title: String?, subtitle: String?) {
        let annotation = PinAnnotation(identifier: identifier, coordinate: coordinate, title: title, subtitle: subtitle)
        geofencedMapView.addAnnotation(annotation)
    }
    
    @IBAction private func zoomToUserLocation() {
        guard currentLocation != nil  else { return presentAlert(title: "Unable to get your location", message: "We are unable to get your location. Please check whether you have permitted for the location services or not") }
        setMapRegion(for: currentLocation.coordinate)
    }
    
    private func setMapRegion(for location: CLLocationCoordinate2D) {
        let zoomRegion = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4))
        geofencedMapView.setRegion(zoomRegion, animated: true)
    }
    
}

extension GeofencingViewController {
    
    @IBAction private func addRegion() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            performSegue(withIdentifier: SegueIdentifiers.addRegionVCSegue, sender: nil)
        }
    }
    
    @IBAction private func regionCategoryIndexChanged(_ sender: UISegmentedControl) {
        var eventType: EventType = []
        switch sender.selectedSegmentIndex {
        case 1: eventType = .entry
        case 2: eventType = .exit
        default: eventType = .both
        }
        showGeofencedRegion(eventType: eventType)
    }
    
}




extension GeofencingViewController: GeofenceSaveDelegate {
    
    func savedGeofence(region: GeofenceRegion) {
        geofencedRegions.append(region)
        startMonitoring(region: region)
        addCircleOnMap(region: region)
    }
    
    private func removeGeofence(identifier: UUID) {
        guard let (index, region) = geofencedRegions.region(for: identifier)  else { return }
        removeCircleOverlay(for: region)
        try? RealmService.shared.delete(object: region)
        stopMonitoring(geofenceRegion: region)
        geofencedRegions.remove(at: index)
    }
    
}


extension GeofencingViewController {
    
    private func startMonitoring(region: GeofenceRegion) {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)
        else { return presentAlert(title: "Error", message: "Geofencing is not supported") }
        
        guard CLLocationManager.authorizationStatus() == .authorizedAlways
        else { return presentAlert(title: "Error", message: "Please grant the always location usage permission") }
        
        let circularRegion = geofence(region: region)
        locationManager.startMonitoring(for: circularRegion)
    }
    
    private func geofence(region: GeofenceRegion) -> CLCircularRegion {
        let circularRegion = CLCircularRegion(center: region.location.coordinate, radius: region.radius, identifier: region.identifier.uuidString)
        circularRegion.notifyOnEntry = region.eventType.contains(.entry)
        circularRegion.notifyOnExit = region.eventType.contains(.exit)
        return circularRegion
    }
    
    private func stopMonitoring(geofenceRegion: GeofenceRegion) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geofenceRegion.identifier.uuidString else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
}

extension GeofencingViewController {
    
    private func removeCircleOverlay(for geofenceRegion: GeofenceRegion) {
        for case let circleOverlay as MKCircle in geofencedMapView.overlays {
            let coord = circleOverlay.coordinate
            if coord.latitude == geofenceRegion.location.latitude && coord.longitude == geofenceRegion.location.longitude && circleOverlay.radius == geofenceRegion.radius {
                geofencedMapView.remove(circleOverlay)
                break
            }
        }
    }
    
    private func addCircleOnMap(region: GeofenceRegion) {
        let circle = MKCircle(center: region.location.coordinate, radius: region.radius)
        geofencedMapView.add(circle)
    }
    
    private func buttonForGeofenceRegionRemoval() -> UIButton {
        let calloutRemoveButton = UIButton(type: .custom)
        calloutRemoveButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        calloutRemoveButton.setTitle("X", for: .normal)
        calloutRemoveButton.setTitleColor(UIColor.black, for: .normal)
        return calloutRemoveButton
    }
    
}


extension GeofencingViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let pinAnnotation = annotation as? PinAnnotation  else { return nil }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: StringLiterals.mapAnnotationViewReuseIdentifier) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: StringLiterals.mapAnnotationViewReuseIdentifier)
            annotationView?.canShowCallout = true
            annotationView?.leftCalloutAccessoryView = buttonForGeofenceRegionRemoval()
        } else {
            annotationView?.annotation = pinAnnotation
        }
        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let geofenceAnnotation = view.annotation as? PinAnnotation,
              let (_, region) = geofencedRegions.region(for: geofenceAnnotation.identifier)
        else { return }
        
        setMapRegion(for: region.location.coordinate)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? MKCircle else { return MKOverlayRenderer() }
        let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
        circleRenderer.lineWidth = 1.0
        circleRenderer.strokeColor = .red
        circleRenderer.fillColor = UIColor.red
        circleRenderer.alpha = 0.5
        return circleRenderer
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? PinAnnotation  else { return }
        removeGeofence(identifier: annotation.identifier)
        mapView.removeAnnotation(annotation)
    }
}
