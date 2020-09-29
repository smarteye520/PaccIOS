//
//  API.swift
//  PACC
//
//  Created by RSS on 4/19/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class API: NSObject {
    class var sharedInstance: API {
        struct Static {
            static let instance: API = API()
        }
        return Static.instance
    }
    let db_root = Database.database().reference(fromURL: APIURL.fir_db)
    let storageRef = Storage.storage().reference(forURL: APIURL.fir_storage) as StorageReference
    let headers = ["Content-Type": "application/json"]
    
    var isFinished_getAllItems: Bool = false
    
    // Login
    func login(_ email: String,_ password: String, completion: @escaping (_ errMsg: String?) -> Void) {
        var loginURL: String = APIURL.login
        if User.sharedInstance.isPatient! {
            loginURL += "User"
        }else {
            loginURL += "Business"
        }
        
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        Alamofire.request(loginURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if response.result.isSuccess {
                
                let userDic = response.result.value as! NSDictionary
                
                if userDic["error"] == nil {
//                    UserDefaults.standard.set((userDic.value(forKey: "data") as! NSArray)[0] as! NSDictionary, forKey: "User.sharedInstance.loadUserInfo")
                    UserDefaults.standard.set(true, forKey: "User.sharedInstance.logged_in")
                    User.sharedInstance.loadUserInfo((userDic.value(forKey: "data") as! NSArray)[0] as! NSDictionary)
                    User.sharedInstance.logged_in = true
                    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.saveUser()
                    completion(nil)
                }else {
                    completion(userDic["error"] as? String)
                }
                
            }else {
                completion(response.result.error.debugDescription)
            }
        }
    }
    
    // Register
    func register(completion: @escaping (_ errMsg: String?) -> Void) {
        
        var registerURL: String = APIURL.register
        if User.sharedInstance.isPatient! {
            registerURL += "User"
        }else {
            registerURL += "Business"
        }
        
        Alamofire.request(registerURL, method: .post, parameters: User.sharedInstance.getDic() as? [String: Any], encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if response.result.isSuccess {
                if (response.result.value as! NSDictionary)["data"] != nil {
                    let userDic = (response.result.value as! NSDictionary)["data"] as! NSDictionary
                    User.sharedInstance.loadUserInfo(userDic )
//                    UserDefaults.standard.set(userDic , forKey: "User.sharedInstance.loadUserInfo")
                    completion(nil)
                }else {
                    completion((response.result.value as! NSDictionary)["message"] as? String)
                }
            }else {
                completion(response.result.error.debugDescription)
            }
        }
    }
    
    // Get List of Items in Collection
    func getAllItems(_ collection: String, completion: @escaping (_ result: [Any]?) -> Void) {
//        if isFinished_getAllItems {
//            return
//        }
        
        let url: String = "\(APIURL.list_collection)\(collection)"
        self.isFinished_getAllItems = true
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
            var result: [Any] = []
            self.isFinished_getAllItems = false
            if response.result.isSuccess {
                if (response.result.value as! NSDictionary)["data"] != nil {
                    let items = (response.result.value as! NSDictionary)["data"] as! NSArray
                    for item in items {
                        switch collection {
                        case "User":
                            let user = User()
                            user.loadUserInfo(item as! NSDictionary)
                            if user.id != User.sharedInstance.id {
                                result.append(user)
                            }else{
                               User.sharedInstance.loadUserInfo(item as! NSDictionary)
//                               UserDefaults.standard.set(item as! NSDictionary, forKey: "User.sharedInstance.loadUserInfo")
                            }
                        case "Business":
                            let user = User()
                            user.loadUserInfo(item as! NSDictionary)
                            if user.id != User.sharedInstance.id {
                                result.append(user)
                            }else{
                                User.sharedInstance.loadUserInfo(item as! NSDictionary)
//                                UserDefaults.standard.set(item as! NSDictionary, forKey: "User.sharedInstance.loadUserInfo")
                            }
                        case "Message":
                            let message = Message(value: item)
                            result.append(message)
                            RealmHelper.sharedInstance.insert(message)
                        case "Products":
                            let product = Shop(value: item)
                            let predicate = NSPredicate(format: "id = %@", product.id!)
                            if RealmHelper.sharedInstance.realm.objects(Shop.self).filter(predicate).count == 0 {
                                RealmHelper.sharedInstance.insert(product)
                                result.append(product)
                            }else {
                                for object in RealmHelper.sharedInstance.realm.objects(Shop.self).filter(predicate) {
                                    result.append(object)
                                }
                            }
                        case "Discussion":
                            let discussion = Discussion(value: item)
                            let predicate = NSPredicate(format: "id = %@", discussion.id!)
                            if RealmHelper.sharedInstance.realm.objects(Discussion.self).filter(predicate).count == 0 {
                                RealmHelper.sharedInstance.insert(discussion)
                                result.append(discussion)
                            }else {
                                for object in RealmHelper.sharedInstance.realm.objects(Discussion.self).filter(predicate) {
                                    result.append(object)
                                }
                            }
                        case "PaccPosition":
                            result.append(PaccPos(item as! NSDictionary)!)
                        case "Rating":
                            result.append(Rating(item as! NSDictionary)!)
                        default:
                            break
                        }
                    }
                    completion(result)
                }else {
                    completion(nil)
                }
            }else {
                completion(nil)
            }
        }
    }
    
    // Get Pacc Positions
    func getPaccPositions(completion: @escaping (_ result: [PaccPos]?) -> Void) {
        let url: String = "\(APIURL.list_collection)PaccPosition"
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
            var result: [PaccPos] = []
            if response.result.isSuccess {
                if (response.result.value as! NSDictionary)["data"] != nil {
                    let items = (response.result.value as! NSDictionary)["data"] as! NSArray
                    
                    for item in items {
                        result.append(PaccPos(item as! NSDictionary)!)
                    }
                    completion(result)
                }else {
                    completion(nil)
                }
            }else {
                completion(nil)
            }
        }
    }
    
    // Get followers
    func getFollows(completion: @escaping (_ result: [Connection]?) -> Void) {
        var url: String = ""
        if User.sharedInstance.isPatient! {
            if(User.sharedInstance.id != nil){
                 url = "\(APIURL.followings)\(User.sharedInstance.id!)"
            }else {
                url = "\(APIURL.followings)\(1)"
            }
           
        }else {
            if(User.sharedInstance.id != nil){
                url = "\(APIURL.followers)\(User.sharedInstance.id!)"
            }else {
                 url = "\(APIURL.followers)\(1)"
            }
           
        }
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
            var connections: [Connection] = []
            if response.result.isSuccess {
                
                if (response.result.value as! NSDictionary)["error"] == nil {
                    let items = (response.result.value as! NSDictionary)["data"] as! NSArray
                    
                    for item in items {
                        let connection = Connection()
                        connection.loadConnectionInfo(item as! NSDictionary)
                        connections.append(connection)
                    }
                }
                
                completion(connections)
            }else {
                completion(nil)
            }
        }
    }
    
    // Get linked businesses
    func get_linked_businesses(completion: @escaping (_ result: [User]?) -> Void) {
        let url: String = "\(APIURL.linked_business)\(User.sharedInstance.id!)"
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
            var linked_businesses: [User] = []
            if response.result.isSuccess {
                
                if (response.result.value as! NSDictionary)["error"] == nil {
                    let items = (response.result.value as! NSDictionary)["data"] as! NSArray
                    
                    for item in items {
                        let user = User()
                        user.loadUserInfo(item as! NSDictionary)
                        linked_businesses.append(user)
                    }
                }
                completion(linked_businesses)
            }else {
                completion(nil)
            }
        }
    }
    
    // Get existing businesses
    func get_existing_businesses(completion: @escaping (_ result: [User]?) -> Void) {
        let url: String = "\(APIURL.list_collection)Business"
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
            var linked_businesses: [User] = []
            if response.result.isSuccess {
                
                if (response.result.value as! NSDictionary)["error"] == nil && (response.result.value as! NSDictionary)["data"] != nil {
                    let items = (response.result.value as! NSDictionary)["data"] as! NSArray
                    
                    for item in items {
                        let user = User()
                        user.loadUserInfo(item as! NSDictionary)
                        linked_businesses.append(user)
                    }
                }
                completion(linked_businesses)
            }else {
                completion(nil)
            }
        }
    }
    
    // Get information of item in collection
    func getItemInfor(_ collection: String,_ item_id: String, completion: @escaping (_ result: NSDictionary?) -> Void) {
        let url: String = "\(APIURL.item_infor)\(collection)/\(item_id)"
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
            
            if response.result.isSuccess {
                let data = response.result.value as! NSDictionary
                if data.value(forKey: "data") != nil {
                    let dic = data.value(forKey: "data") as! NSDictionary
                    completion(dic)
                }else {
                    completion(nil)
                }
            }else {
                completion(nil)
            }
        }
    }
    
    // Delete information of item in collection
    func deleteItem(_ collection: String,_ item_id: String, completion: @escaping (_ result: Bool?) -> Void) {
        let url: String = "\(APIURL.delete_item)\(collection)/\(item_id)"
        Alamofire.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
            
            if response.result.isSuccess {
//                let data = (response.result.value as! NSDictionary)["data"] as! NSDictionary
                completion(true)
            }else {
                completion(false)
            }
        }
    }
    
    // Insert new item in collection
    func insertItem(_ collection: String, _ params: NSDictionary, completion: @escaping (_ result: NSDictionary?) -> Void) {
        let url: String = "\(APIURL.insert_item)\(collection)"
        Alamofire.request(url, method: .post, parameters: params as? [String: Any], encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if response.result.isSuccess {
                if (response.result.value as! NSDictionary)["inserted"] != nil {
                    let dic = (response.result.value as! NSDictionary)["inserted"] as! NSDictionary
                    completion(dic)
//                    completion(dic.value(forKey: "_id") as? String)
                }else {
                    completion(nil)
                }
                
            }else {
                completion(nil)
            }
        }
    }
    
    // Update item in collection
    func updateItem(_ collection: String, _ params: NSDictionary, completion: @escaping (_ result: Bool?) -> Void){
        let url: String = "\(APIURL.update_item)\(collection)"
        Alamofire.request(url, method: .put, parameters: params as? [String: Any], encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if response.result.isSuccess {
//                let dic = (response.result.value as! NSDictionary)["data"] as! NSDictionary
                completion(true)
            }else {
                completion(false)
            }
        }
    }    
    
    func uploadImage(_ image: UIImage, completion: @escaping (_ imageURL: String?) -> Void) {
        let imageData = image.jpegData(compressionQuality: 0.8)! as Data
    
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        let currentTime = Date().timeIntervalSince1970 * 1000
    
        // Create a reference to the file you want to upload
        let riversRef = storageRef.child("images/\(currentTime).jpg")
    
        // Upload the file to the path "images/rivers.jpg"
        riversRef.putData(imageData, metadata: metaData) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // You can also access to download URL after upload.
            riversRef.downloadURL { (url, error) in
              guard let downloadURL = url else {
                // Uh-oh, an error occurred!
                return
              }
             completion(downloadURL.absoluteString as String)
            }
        
            
        }
    }
    
    func addMessage(_ message: Message, _ created_at: String) {
        db_root.child("Message").child(created_at).setValue(message.getChatDic())
    }
    
    func addBusinessMessage(_ message: Message, _ created_at: String) {
        db_root.child("BusinessMessage").child(created_at).setValue(message.getChatDic())
    }
    
    func get_messages_from_firebase(completion: @escaping (_ messages: [Message]?) -> Void) {
        db_root.child("Message").queryOrderedByKey().observe(DataEventType.value, with: {snapchat in
            var messages: [Message] = []
            for messageData in snapchat.children {
                let data = messageData as! DataSnapshot
                let orderDic = data.value as! NSDictionary
                let message = Message(value: orderDic)
                let predicate = NSPredicate(format: "created_at = %@", message.created_at! as NSDate)
                if RealmHelper.sharedInstance.realm.objects(Message.self).filter(predicate).count == 0 {
                    RealmHelper.sharedInstance.insert(message)
                    messages.append(message)
                }else {
                    for object in RealmHelper.sharedInstance.realm.objects(Message.self).filter(predicate) {
                        messages.append(object)
                        break
                    }
                }
            }
            
            messages = messages.sorted { message1, message2 in
                return message1.created_at!.compare(message2.created_at!) == .orderedAscending ? true : false
            }
            completion(messages)
        })
    }
    
    func get_businessmsg_from_firebase(completion: @escaping (_ messages: [Message]?) -> Void) {
        db_root.child("BusinessMessage").queryOrderedByKey().observe(DataEventType.value, with: {snapchat in
            var messages: [Message] = []
            for messageData in snapchat.children {
                let data = messageData as! DataSnapshot
                let orderDic = data.value as! NSDictionary
            
                let message = Message(value: orderDic)

                let predicate = NSPredicate(format: "created_at = %@", message.created_at! as NSDate)
                
                if RealmHelper.sharedInstance.realm.objects(Message.self).filter(predicate).count == 0 {
                    
                    RealmHelper.sharedInstance.insert(message)
                    messages.append(message)
                }else {
                    for object in RealmHelper.sharedInstance.realm.objects(Message.self).filter(predicate) {
                        messages.append(object)
                        break
                    }
                }
            }
            
            messages = messages.sorted { message1, message2 in
                return message1.created_at!.compare(message2.created_at!) == .orderedAscending ? true : false
            }
            completion(messages)
        })
    }
    
    func createCharge(_ id: String, budget: String, description: String, completion: @escaping (_ res: String?) -> Void) {
        let header = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Authorization": "Bearer \(secret_key)"
        ]
        let params: [String: Any] = [
            "amount": Int(Double(budget)! * 100.0),
            "currency": "usd",
            "source": id,
            "description": description
        ]
        Alamofire.request(APIURL.create_charge, method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: header).responseJSON { response in
            let info = response.result.value as! NSDictionary
            switch response.result {
                
            case .success:
                completion(nil)
                break
            case .failure( _):
                completion(info.value(forKey: "message") as? String ?? "Charge failed")
                break
            }
        }
    }
    
}
