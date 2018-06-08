//
//  RealmService.swift
//  SettingsScreen
//
//  Created by Prateek Sharma on 6/2/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import Foundation
import RealmSwift



class RealmService {
    private init() {}
    let realm = try! Realm()
    static let shared = RealmService()
}

extension RealmService {
    
    func read<T: Object>(aClass: T.Type) -> [T] {
        let objects = realm.objects(aClass)
        return objects.map { $0 }
    }
    
    func create(object: Object) throws {
        try write { realm.add(object) }
    }
    
    func create(objects: [Object]) throws {
        try write { realm.add(objects) }
    }
    
    func update(object: Object, with dictionary: [String:Any?]) throws {
        try write {
            for (key, value) in dictionary {
                object.setValue(value, forKey: key)
            }
        }
    }
    
    func delete(object: Object) throws {
        try write { realm.delete(object) }
    }
    
    func write(updates: () -> ()) throws {
        try realm.write {
            updates()
        }
    }
    
}
