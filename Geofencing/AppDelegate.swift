//
//  AppDelegate.swift
//  Geofencing
//
//  Created by Prateek Sharma on 6/7/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import UserNotifications
import CoreLocation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, LocationManagerProtocol {

    var window: UIWindow?
    lazy var locationManager = create()
    
    private func removeNavBarBottomLine() {
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        removeNavBarBottomLine()
        IQKeyboardManager.shared.enable = true
        registerNotifications()
        locationManager.requestAlwaysAuthorization()
        
        return true
    }

    private func registerNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound , .badge , .alert]) { [weak self] (granted, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print(granted)
            }
            UNUserNotificationCenter.current().delegate = self
        }
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

}


extension AppDelegate:UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert , .badge])
    }
    
}


extension AppDelegate: CLLocationManagerDelegate, Notifiable {
    
    private func handleMonitoring(event: EventType, regionIdentifier: String) {
        let geofencedRegions = RealmService.shared.read(aClass: GeofenceRegion.self)
        guard let (index, geofenceRegion) = geofencedRegions.region(for: regionIdentifier)
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




