
//
//  User.swift
//  PACC
//
//  Created by RSS on 4/19/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

class User: NSObject {
    class var sharedInstance: User {
        struct Static {
            static let instance : User = User()
        }
        return Static.instance
    }
    var id: String?
    var isPatient: Bool?
    var email: String?
    var password: String?
    var profileimg: String?
    var location: String?
    var lat: Double?
    var long: Double?
    var bio: String?
    var phonenum: String?
    var dob: String?
    var name: String?
    var business_type: String?
    var from: String?
    var to: String?
    var linked_business: String?
    var is_premium: Bool?
    
    var logged_in: Bool?
    
    func loadUserInfo(_ userInfo: NSDictionary) {
        self.id = userInfo["_id"] as? String
        self.email = userInfo["email"] as? String
        self.name = userInfo["name"] as? String
        self.password = userInfo["password"] as? String
        self.profileimg = userInfo["profileimg"] as? String
        self.location = userInfo["location"] as? String
        self.lat = userInfo["lat"] as? Double
        self.long = userInfo["long"] as? Double
        self.bio = userInfo["bio"] as? String
        self.phonenum = userInfo["phonenum"] as? String
        self.dob = userInfo["dob"] != nil ? userInfo["dob"] as? String : nil
        self.business_type = userInfo["business_type"] != nil ? userInfo["business_type"] as? String : nil
        self.from = userInfo["from"] != nil ? userInfo["from"] as? String : nil
        self.to = userInfo["to"] != nil ? userInfo["to"] as? String : nil
        self.linked_business = userInfo["linked_business"] != nil ? userInfo["linked_business"] as? String : nil
        self.is_premium = userInfo["is_preminum"] != nil ? userInfo["is_preminum"] as? Bool : nil
    }
    
    func getDic() -> NSMutableDictionary {
        let parameters: NSMutableDictionary = [
            "name": self.name != nil ? self.name! : "",
            "email": self.email != nil ? self.email! : "",
            "password": self.password != nil ? self.password!: "",
            "profileimg": self.profileimg != nil ? self.profileimg! : "",
            "location": self.location != nil ? self.location! : "",
            "lat": self.lat != nil ? self.lat! : 0.0,
            "long": self.long != nil ? self.long! : 0.0,
            "phonenum": self.phonenum != nil ? self.phonenum! : "",
            "bio": self.bio != nil ? self.bio! : "",
            "is_preminum": self.is_premium != nil ? self.is_premium! : false
        ]
        
        if self.id != nil {
            parameters.setValue(self.id!, forKey: "_id")
        }
        if User.sharedInstance.isPatient! {
            parameters.setValue(self.dob != nil ? self.dob! : "", forKey: "dob")
        }else {
            parameters.setValue(self.business_type != nil ? self.business_type! : "", forKey: "business_type")
            parameters.setValue(self.from != nil ? self.from! : "", forKey: "from")
            parameters.setValue(self.to != nil ? self.to! : "", forKey: "to")
            parameters.setValue(self.linked_business != nil ? self.linked_business! : "", forKey: "linked_business")
        }
        return parameters
    }
    
    func initialize() {
        self.id = nil
        self.email = nil
        self.bio = nil
        self.name = nil
        self.password = nil
        self.profileimg = nil
        self.location = nil
        self.lat = nil
        self.long = nil
        self.phonenum = nil
        self.business_type = nil
        self.dob = nil
        self.from = nil
        self.to = nil
        self.linked_business = nil
        self.is_premium = nil
    }
}
