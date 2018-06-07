//
//  AlertControllerExtension.swift
//  Geofencing
//
//  Created by Prateek Sharma on 6/8/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit


extension UIAlertController {
    
    static var okayButton: UIAlertAction { return UIAlertAction(title: "Okay", style: .default, handler: nil) }
    
    static func create(title: String? = nil, message: String? = nil, style: UIAlertControllerStyle = .alert, actions: [UIAlertAction] = [okayButton]) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        actions.forEach { (action) in
            alertController.addAction(action)
        }
        return alertController
    }
    
}
