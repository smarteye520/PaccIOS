//
//  Comment.swift
//  PACC
//
//  Created by RSS on 6/17/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import RealmSwift

class Comment: Object {
    @objc dynamic var commenter: String? = nil
    @objc dynamic var content: String? = nil
    @objc dynamic var created_at: Date? = nil
    convenience override init(value: Any) {
        self.init()
        let info = value as! NSDictionary
        self.commenter = info["id"] as? String
        self.content = info["content"] as? String
        self.created_at = (info["created_at"] as! String).utcToLocal()
    }
    func getDic() -> NSDictionary {
        return [
            "id": self.commenter!,
            "content": self.content!,
            "created_at": self.created_at!.localToUTC()
        ]
    }
}
