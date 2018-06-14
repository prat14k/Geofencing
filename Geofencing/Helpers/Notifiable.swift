//
//  Notifiable.swift
//  Geofencing
//
//  Created by Prateek Sharma on 6/13/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import Foundation
import UserNotifications


protocol Notifiable { }
extension Notifiable {
    func triggerNotification(title: String, subtitle: String, description: String) {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = description
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error)
            }
        }
        
    }
}
