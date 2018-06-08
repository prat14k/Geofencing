//
//  EventType.swift
//  Geofencing
//
//  Created by Prateek Sharma on 6/8/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import Foundation


struct EventType: OptionSet {
    let rawValue: Int
    
    static let entry = EventType(rawValue: 1)
    static let exit = EventType(rawValue: 2)
    
    static let both: EventType = [.entry, .exit]
    
    var detail: String {
        switch self {
        case .both: return "Entry & Exit"
        case .entry: return "Entry"
        case .exit: return "Exit"
        default: return ""
        }
    }
    
    
}
