//
//  Shadowable.swift
//  Geofencing
//
//  Created by Prateek Sharma on 6/7/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit

protocol Shadowable { }
extension Shadowable where Self: UIView {
    
    func applyShadow() {
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 0.7
        layer.shadowOpacity = 0.3
    }

}

extension UIView: Shadowable { }
