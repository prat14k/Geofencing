//
//  ViewControllerExtension.swift
//  Geofencing
//
//  Created by Prateek Sharma on 6/8/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit


extension UIViewController {
    
    func presentAlert(title: String?, message: String?) {
        let controller = UIAlertController.create(title: title, message: message)
        present(controller, animated: true, completion: nil)
    }
    
}
