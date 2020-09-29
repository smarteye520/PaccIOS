//
//  PaccPos.swift
//  PACC
//
//  Created by RSS on 7/22/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

class PaccPos: NSObject {
    var id: String?
    var creater: String?
    var name: String?
    init?(_ info: NSDictionary) {
        self.id = info["_id"] as? String
        self.creater = info["creater"] as? String
        self.name = info["name"] as? String
    }
}
