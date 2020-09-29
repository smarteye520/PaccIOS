//
//  ConnectionsViewController.swift
//  PACC
//
//  Created by RSS on 4/18/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

class ConnectionsViewController: BaseViewController {
    
    @IBOutlet weak var conTable: UITableView!
    @IBOutlet var buttons: [UIButton]!
    
    var isFollowing: Bool = true
    var prevButton: Int = 100
    var isDispensary: Bool = false
    
    var allUsers: [User] = []
    var allFollows: [Connection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        if User.sharedInstance.isPatient! {
            actionFollow(buttons[prevButton - 100])
        }else{
            prevButton = 101
            actionFollow(buttons[prevButton - 100])
        }
        
        conTable.allowsSelection = false
        conTable.separatorStyle = .none
        conTable.showsVerticalScrollIndicator = false
        conTable.register(UINib(nibName: "ConnectionCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        getAllConnections()
    }
    
    func getAllConnections() {
        
        var collection: String = ""
        if User.sharedInstance.isPatient! {
            collection = "Business"
        }else {
            collection = "User"
        }
        self.showHUD()
        API.sharedInstance.getAllItems(collection) { (result) in
            if User.sharedInstance.isPatient! && self.isDispensary {
                for user in result as! [User] {
                    if user.business_type == "Dispensary" {
                        self.allUsers.append(user)
                    }
                }
            }else {
                self.allUsers = result as! [User]
            }
            API.sharedInstance.getFollows(completion: { (connections) in
                if connections != nil {
                    self.allFollows = connections!
                }
                DispatchQueue.main.async {
                    self.hideHUD()
                    self.conTable.reloadData()
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func actionFollow(_ sender: UIButton) {
        if prevButton < 0 {
            return
        }
        buttons[prevButton - 100].removeBottomLine()
        sender.drawBottomLine()
        prevButton = -1
    }
}

extension ConnectionsViewController: UITableViewDelegate, UITableViewDataSource, ConnectionCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ConnectionCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ConnectionCell
        if cell.user == nil || cell.user != allUsers[indexPath.row] {
            cell.user = allUsers[indexPath.row]
            cell.id = getFollow(allUsers[indexPath.row])
            cell.delegate = self
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func getFollow(_ user: User) -> String? {
        for follow in allFollows {
            if User.sharedInstance.isPatient! {
                if follow.following == user.id {
                    return follow.id
                }
            }else {
                if follow.follower == user.id {
                    return follow.id
                }
            }
        }
        return nil
    }
    
    func actionFollow(_ isFollow: Bool, _ params: NSDictionary?, _ cell: ConnectionCell) {
        if isFollow {
            self.showHUD()
            API.sharedInstance.insertItem("Connections", params!) { (dic) in
                DispatchQueue.main.async {
                    self.hideHUD()
                }
                if dic != nil {
                    cell.isFollow = !cell.isFollow!
                    let connection = Connection()
                    connection.loadConnectionInfo(dic!)
                    self.allFollows.append(connection)
                }
                
            }
        }else {
            self.showHUD()
            API.sharedInstance.deleteItem("Connections", cell.id!) { (success) in
                DispatchQueue.main.async {
                    self.hideHUD()
                }
                if success! {
                    cell.isFollow = !cell.isFollow!
                    var tmp_followers : [Connection] = []
                    for follower in self.allFollows {
                        if follower.id != cell.id {
                            tmp_followers.append(follower)
                        }
                    }
                    self.allFollows = tmp_followers
                }
            }
        }
    }
    
    func actionViewProfile(_ cell: ConnectionCell) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileViewController
        vc.user = cell.user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}


