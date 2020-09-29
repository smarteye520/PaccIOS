//
//  Shop.swift
//  PACC
//
//  Created by RSS on 4/20/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import RealmSwift

class Shop: Object {
    @objc dynamic var id: String? = nil
    @objc dynamic var name: String? = nil
    @objc dynamic var image: String? = nil
    @objc dynamic var price: Double = 0.0
    @objc dynamic var descript: String? = nil
    @objc dynamic var currency: String? = nil
    @objc dynamic var imgData: Data? = nil
    
    convenience override init(value: Any) {
        self.init()
        let info = value as! NSDictionary
        self.id = info["_id"] as? String
        self.name = info["name"] as? String
        
        let baseURL: String = "https://static.wixstatic.com/media/"
        var origin: String = info["mainMedia"] as! String
        var index1 = origin.index(origin.endIndex, offsetBy: -origin.count + 15)
        if origin.range(of: "wix:image://v1")?.lowerBound == nil {
            index1 = origin.index(origin.endIndex, offsetBy: -origin.count + 11)
        }
        origin = String(origin[index1..<origin.endIndex])
        let index2 = origin.range(of: "/")?.lowerBound
        if index2 == nil {
            self.image = baseURL
        }else {
            self.image = baseURL.appending("\(origin.prefix(upTo: index2!))")
        }
        
        self.price = info["price"] as? Double ?? 0.0
        self.currency = info["currency"] as? String
    }
}
