//
//  Connections.swift
//  PACC
//
//  Created by RSS on 4/20/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

class Connection {
    var id: String?
    var follower: String?
    var following: String?
    
    func loadConnectionInfo(_ userInfo: NSDictionary) {
        self.id = userInfo["_id"] as? String
        self.follower = userInfo["follower"] as? String
        self.following = userInfo["following"] as? String
    }
}
