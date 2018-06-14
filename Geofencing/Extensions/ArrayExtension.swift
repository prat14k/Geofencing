//
//  ArrayExtension.swift
//  Geofencing
//
//  Created by Prateek Sharma on 6/8/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import Foundation

extension Array where Element: GeofenceRegion{
    
    func region(for identifier: String) -> (Int, GeofenceRegion)? {
        let searchedIndex = index { $0.identifier == identifier }
        guard let index = searchedIndex else { return nil }
        return (index, self[index])
    }
    
}
