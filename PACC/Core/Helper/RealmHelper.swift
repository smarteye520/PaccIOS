//
//  RealmHelper.swift
//  PACC
//
//  Created by RSS on 7/3/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import RealmSwift

class RealmHelper: NSObject {
    
    class var sharedInstance: RealmHelper {
        struct Static {
            static let instance : RealmHelper = RealmHelper()
        }
        return Static.instance
    }
    
    let realm = try! Realm()
    
    func insert(_ object: Object) {
        DispatchQueue.main.async {
            try! self.realm.write {
                self.realm.add(object)
            }
        }
    }
    
    func delete(_ object: Object) {
        DispatchQueue.main.async {
            try! self.realm.write {
                self.realm.delete(object)
            }
        }
    }
    
    func empty_realm_db() {
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func filter(_ results: Results<Object>, _ predicate: NSPredicate) -> Results<Object> {
        return results.filter(predicate)
    }
    
    func sort(_ results: Results<Object>, _ key_path: String) -> Results<Object> {
        return results.sorted(byKeyPath: key_path)
    }
    
    func chain_query(_ results: Results<Object>, _ key_path: String, _ predicate: NSPredicate) -> Results<Object> {
        return results.filter(predicate).sorted(byKeyPath: key_path)
    }
    
}
