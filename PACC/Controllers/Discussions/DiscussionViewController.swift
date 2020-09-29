//
//  DiscussionViewController.swift
//  PACC
//
//  Created by RSS on 5/27/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import RealmSwift

class DiscussionViewController: BaseViewController {
    
    @IBOutlet weak var scrDiscussion: PaccDiscussion!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var btnNewPost: UIButton!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var viewCategory: UIView!
    @IBOutlet weak var btnBack: UIButton!
    
    var discussions: [Discussion] = []
    var isInThisView: Bool = false
    var category: DiscussionCategory?
    var refreshControl: UIRefreshControl!
    var isGoingToDetail: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnBack.setButtonShadow()
        isInThisView = true
        if User.sharedInstance.is_premium != nil && User.sharedInstance.is_premium! && !User.sharedInstance.isPatient! {
            self.btnNewPost.alpha = 1.0
        }else {
            self.btnNewPost.alpha = 0.0
        }
        scrDiscussion.alwaysBounceVertical = true
        scrDiscussion.bounces  = true
        scrDiscussion.refreshControl = UIRefreshControl()
        scrDiscussion.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    @objc func didPullToRefresh() {

      print("Refersh")

     // For End refrshing
     refreshControl?.endRefreshing()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         NotificationCenter.default.addObserver(self, selector: #selector(notifyreload), name:NSNotification.Name("userBlocked") , object: nil)
        discussions = []
        category = DiscussionCategory(frame: CGRect(x: (self.view.frame.width - 200), y: self.viewCategory.layer.frame.origin.y + 60, width: 160, height: 218))
               category?.alpha = 0.0
               category?.delegate = self
               self.view.addSubview(category!)
               self.getDiscussions()
    }
    
    @objc func notifyreload() {
       getDiscussions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("userBlocked"), object: nil)
        if self.scrDiscussion != nil {
            self.scrDiscussion.add_discussion_queue.cancelAllOperations()
            self.scrDiscussion.operations.forEach { (operation) in
                operation.cancel()
            }
        }
        isInThisView = false
    }
    
    @IBAction func btnActionMenu(_ sender: UIButton) {
         sideMenuController?.showLeftView(animated: true, completionHandler: nil)
    }
    
    func getDiscussions() {
        self.discussions.removeAll()
        self.showHUD()
        API.sharedInstance.getAllItems("Discussion") { (discussions) in
            DispatchQueue.main.async {
                self.hideHUD()
                self.discussions.removeAll()
                for discussion in RealmHelper.sharedInstance.realm.objects(Discussion.self) {
                    if discussion.receiver == nil || discussion.receiver == "" || discussion.receiver == User.sharedInstance.id{
                        if(UserDefaults.standard.value(forKey: "blockeUsers") != nil){
                            let arrBlockedData = UserDefaults.standard.value(forKey: "blockeUsers") as! NSArray
                            if(arrBlockedData.count != 0 ) {
                                if arrBlockedData.contains(discussion.id!) {
                                    print("yes")
                                }else {
                                    self.discussions.append(discussion)
                                }
                            }
                        }else {
                             self.discussions.append(discussion)
                        }
                    }
                }
                self.sort(0)
            }
        }
    }
    
    @IBAction func actionShowCategory(_ sender: UIButton) {
        if category?.alpha == 0 {
            category?.fadeIn(completion: { (success) in
            })
        }else {
            category?.fadeOut(completion: { (success) in
            })
        }
    }
    
    @IBAction func actionNewPost(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewPostVC") as! NewPostViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnaActionMenu(_ sender: UIButton) {
    }
    
    @IBAction func btnActionHome(_ sender: UIButton) {
        self.appDelegate.makingRoot("enterApp")
    }
    
    
}

extension DiscussionViewController: DCDelegate {
    
    func sort(_ type: Int) {
        switch type {
        case 0:
            lblCategory.text = "Show Recent"
            self.scrDiscussion.real_data = self.discussions
            self.scrDiscussion.reloadData()
        case 1:
            lblCategory.text = "Show Favorites"
            self.scrDiscussion.real_data.removeAll()
            for discussion in self.discussions {
                for favorite in discussion.favorites {
                    if favorite == User.sharedInstance.id {
                        self.scrDiscussion.real_data.append(discussion)
                    }
                }
            }
            self.scrDiscussion.reloadData()
        case 2:
            lblCategory.text = "Show Legal"
            self.scrDiscussion.real_data.removeAll()
            for discussion in self.discussions {
                if discussion.poster_type == "Legal" {
                    self.scrDiscussion.real_data.append(discussion)
                }
            }
            self.scrDiscussion.reloadData()
        case 3:
            lblCategory.text = "Show Physician"
            self.scrDiscussion.real_data.removeAll()
            for discussion in self.discussions {
                if discussion.poster_type == "Physician" {
                    self.scrDiscussion.real_data.append(discussion)
                }
            }
            self.scrDiscussion.reloadData()
        case 4:
            lblCategory.text = "Show Dispensary"
            self.scrDiscussion.real_data.removeAll()
            for discussion in self.discussions {
                if discussion.poster_type == "Dispensary" {
                    self.scrDiscussion.real_data.append(discussion)
                }
            }
            self.scrDiscussion.reloadData()
        case 5:
            lblCategory.text = "Show Other"
            self.scrDiscussion.real_data.removeAll()
            for discussion in self.discussions {
                if discussion.poster_type != "Legal" && discussion.poster_type != "Physician" && discussion.poster_type != "Dispensary" {
                    self.scrDiscussion.real_data.append(discussion)
                }
            }
            self.scrDiscussion.reloadData()
        default:
            break
        }
    }
    
}

