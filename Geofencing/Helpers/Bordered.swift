//
//  Bordered.swift
//  Geofencing
//
//  Created by Prateek Sharma on 6/7/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit


protocol Bordered { }
extension Bordered where Self: UIView {
    
    func addBorder() {
        layer.borderColor = UIColor(red: 221.0/255.0, green: 221.0/255.0, blue: 221.0/255.0, alpha: 1.0).cgColor
        layer.borderWidth = 0.7
    }
    
}

extension UIView: Bordered { }
