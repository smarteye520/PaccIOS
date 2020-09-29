//
//  Discussion.swift
//  PACC
//
//  Created by RSS on 6/17/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import RealmSwift

class Discussion: Object {
    @objc dynamic var id: String? = nil
    @objc dynamic var name: String? = nil
    @objc dynamic var descript: String? = nil
    @objc dynamic var poster: String? = nil
    @objc dynamic var poster_type: String? = nil
    var favorites = List<String>()
    var comments = List<Comment>()
    @objc dynamic var image: String? = nil
    @objc dynamic var created_at: Date? = nil
    @objc dynamic var imgData: Data? = nil
    @objc dynamic var receiver: String? = nil
 
    convenience override init(value: Any) {
        self.init()
        let info = value as! NSDictionary
        self.id = info["_id"] as? String
        self.name = info["name"] as? String
        self.descript = info["description"] as? String
        self.poster = info["poster"] as? String
        self.poster_type = info["poster_type"] as? String
        self.image = info["image"] as? String
        self.receiver = info["receiver"] as? String
        
        if info["favorites"] != nil {
            let tmpStrArr = (info["favorites"] as! String).components(separatedBy: ",")
            for str in tmpStrArr {
                self.favorites.append(str)
            }
        }
        
        do {
            if info["comments"] != nil {
                let comments = try JSONSerialization.jsonObject(with: (info["comments"] as! String).data(using: .utf8)!, options: .allowFragments) as? [[String : Any]]
                for comment_dic in comments! {
                    self.comments.append(Comment(value: comment_dic))
                }
            }
        }catch {
            print(error.localizedDescription)
        }
        
        let dateStr = info["_createdDate"] as? String
        let index = dateStr?.range(of: ".", options: .backwards)?.lowerBound
        if index == nil {
            self.created_at = dateStr!.utcToLocal()
        }else {
            self.created_at = String((dateStr?.prefix(upTo: index!))!).utcToLocal()
        }
    }
    
    func getDic() -> NSDictionary {
        var data: Data?
        var new_comment: [NSDictionary] = []
        for comment in self.comments {
            new_comment.append(comment.getDic())
        }
        do {
            data = try JSONSerialization.data(withJSONObject: new_comment, options: .prettyPrinted)
        }catch {
            print("json error: \(error.localizedDescription)")
        }
        
        return [
            "_id": self.id ?? "",
            "name": self.name ?? "",
            "description": self.descript ?? "",
            "poster": self.poster ?? "",
            "poster_type": self.poster_type ?? "",
            "image": self.image ?? "",
            "favorites": self.favorites.joined(separator: ","),
            "comments": String.init(data: data!, encoding: .utf8)!
        ]
    }
}
