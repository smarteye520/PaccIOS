//
//  Messages.swift
//  PACC
//
//  Created by RSS on 4/20/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import RealmSwift

class Message: Object {
    
    @objc dynamic var id: String? = nil
    @objc dynamic var sender: String? = nil
    @objc dynamic var senderType: Int = 0
    @objc dynamic var receiver: String?
    @objc dynamic var receiverType: Int = 0
    @objc dynamic var content: String?
    @objc dynamic var is_read: Bool = false
    @objc dynamic var type: Int = 0
    @objc dynamic var created_at: Date? = nil
    @objc dynamic var image: Data? = nil
    @objc dynamic var width: Float = 0.0
    @objc dynamic var height: Float = 0.0
    @objc dynamic var sender_profile: Data?
    
    convenience override init(value: Any) {
        
        self.init()
        let info = value as! NSDictionary
        self.id = info["_id"] as? String
        self.receiver = info["receiver"] as? String
        self.receiverType = info["receiverType"] as? Int ?? 0
        self.content = info["content"] as? String
        self.type = info["type"] as? Int ?? 0
        self.is_read = info["is_read"] as? Bool ?? false
        self.sender = info["sender"] as? String
        self.senderType = info["senderType"] as? Int ?? 0
        self.image = info["image"] as? Data
        self.width = info["width"] as? Float ?? MAX_VALUE
        let MIN_HEIGHT = self.id != User.sharedInstance.id ? MIN_HEIGHT2 : MIN_HEIGHT1
        self.height = info["height"] as? Float ?? MIN_HEIGHT
        
        let dateStr = info["_createdDate"] as? String
        let index = dateStr?.range(of: ".", options: .backwards)?.lowerBound
        if index == nil {
            self.created_at = dateStr!.utcToLocal()
        }else {
            self.created_at = String((dateStr?.prefix(upTo: index!))!).utcToLocal()
        }
    }
    
    
    func getMessageDic() -> NSDictionary {
        return [
            "sender": self.sender ?? "",
            "senderType": self.senderType,
            "receiver": self.receiver ?? "",
            "receiverType": self.receiverType,
            "content": self.content ?? "",
            "type": self.type,
            "is_read": true,
            "width": self.width,
            "height": self.height
        ]
    }
    
    func getChatDic() -> NSDictionary {
        return [
            "sender": self.sender ?? "",
            "senderType": self.senderType,
            "content": self.content ?? "",
            "type": self.type,
            "is_read": true,
            "_createdDate": self.created_at!.localToUTC(),
            "width": self.width,
            "height": self.height
        ]
    }
}
