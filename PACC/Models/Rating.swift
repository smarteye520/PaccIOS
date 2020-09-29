//
//  Rating.swift
//  PACC
//
//  Created by RSS on 8/15/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

class Rating: NSObject {
    var sender: String?
    var receiver: String?
    var rating: Double?
    
    init?(_ info: NSDictionary) {
        self.sender = info["sender"] as? String
        self.receiver = info["receiver"] as? String
        self.rating = info["rating"] as? Double
    }
}
