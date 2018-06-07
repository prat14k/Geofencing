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


class GeofencingViewController: UIViewController {

    @IBOutlet weak var userLocationBarButton: UIBarButtonItem! {
        didSet {
            set(title: Fontello.locationIcon, for: userLocationBarButton)
        }
    }
    @IBOutlet weak var addRegionBarButton: UIBarButtonItem! {
        didSet {
            set(title: Fontello.plusIcon, for: addRegionBarButton)
        }
    }
    
    @IBOutlet weak var geofencedMapView: MKMapView! 
    @IBOutlet weak var segmentControlBackgroundView: UIView! {
        didSet {
            segmentControlBackgroundView.applyShadow()
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
    
    private func set(title: String, for barButton: UIBarButtonItem) {
        barButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont(name: Fontello.name, size: 15)!], for: .normal)
        barButton.title = title
    }
    
}

extension GeofencingViewController {
    
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

extension GeofencingViewController : CLLocationManagerDelegate {
    
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
            geofencedMapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        }
    }
    
}

extension GeofencingViewController {
    
    private func addAnnotations() {
        let annotation1 = MKPointAnnotation()
        annotation1.coordinate = CLLocationCoordinate2D(latitude: 37.3832703, longitude: -122.0071247)
        annotation1.title = "Title1"
        
        let annotation2 = MKPointAnnotation()
        annotation2.coordinate = CLLocationCoordinate2D(latitude: 37.354968, longitude: -121.944333)
        annotation2.title = "Title2"
    }
    
    @IBAction func addRegion() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            performSegue(withIdentifier: SegueIdentifiers.addRegionVCSegue, sender: nil)
        }
    }
    
    @IBAction func regionCategoryIndexChanged() {
        
    }
    
}

extension GeofencingViewController {
    private func setMapRegion(forLocation location : CLLocation) {
        let zoomRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4))
        geofencedMapView.setRegion(zoomRegion, animated: true)
    }
    
    @IBAction func zoomToUserLocation() {
        guard currentLocation == nil  else { return presentAlert(title: "Unable to get your location", message: "We are unable to get your location. Please check whether you have permitted for the location services or not") }
        setMapRegion(forLocation: currentLocation)
    }
}







//    @IBOutlet weak var regionsCategorySegmentControl: UISegmentedControl!
