//
//  PrefersView.swift
//  PACC
//
//  Created by RSS on 5/7/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

class PrefersView: UIScrollView, UIScrollViewDelegate {
    
    var viewCon: ProfileViewController?
    
    var prefers: [User]?
    var likes: [User]?
    var linked_employees: [User]?
    var discussions: [Discussion]?
    
    var scrView: UIScrollView?
    var scrFrame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var pageControl: UIPageControl?
    
    var count = 0

    var isFirstTab: Bool = true
    func initView() {
        count = 0
        self.prefers = []
        self.likes = []
        self.linked_employees = []
        self.discussions = []
        
        self.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        self.showsVerticalScrollIndicator = false
        if User.sharedInstance.isPatient! {
            API.sharedInstance.getFollows(completion: { (connections) in
                self.prefers = []
                if connections != nil && connections?.count != 0 {
                    self.viewCon = self.findViewController() as? ProfileViewController
                    self.viewCon?.btnFollows.setTitle("\(connections!.count)", for: .normal)
                    var local_count = 0
                    for i in 0 ..< connections!.count {
                        API.sharedInstance.getItemInfor("Business", connections![i].following!, completion: { (itemInfo) in
                            local_count += 1
                            if itemInfo != nil {
                                let user = User()
                                user.loadUserInfo(itemInfo!)
                                self.prefers?.append(user)
                            }
                            if local_count == connections!.count {
                                self.count += 1
                                if self.count == 2 {
                                    self.loadPrefersLikes()
                                }
                            }
                        })
                    }
                }else {
                    self.count += 1
                    if self.count == 2 {
                        self.loadPrefersLikes()
                    }
                }
            })
        }else {
            API.sharedInstance.get_linked_businesses { (users) in
                self.count += 1
                self.linked_employees = []
                if users != nil && users?.count != 0 {
                    self.linked_employees = users
                }
                if self.count == 2 {
                    self.loadLinkedBusinesses()
                }
            }
        }
        self.discussions = []
        if RealmHelper.sharedInstance.realm.objects(Discussion.self).count == 0 {
            API.sharedInstance.getAllItems("Discussion") { (discussions) in
                self.count += 1
                var discussion_arr: [Discussion] = []
                if discussions != nil && discussions?.count != 0 {
                    for discussion in discussions as! [Discussion] {
                        if discussion.receiver == nil || discussion.receiver == "" || discussion.receiver == User.sharedInstance.id {
                            discussion_arr.append(discussion)
                        }
                    }
                    self.initDiscussion(discussion_arr)
                }else {
                    self.initDiscussion(discussion_arr)
                }
            }
        }else {
            self.count += 1
            var discussions: [Discussion] = []
            for discussion in RealmHelper.sharedInstance.realm.objects(Discussion.self) {
                if discussion.receiver == nil || discussion.receiver == "" || discussion.receiver == User.sharedInstance.id {
                    discussions.append(discussion)
                }
            }
            self.initDiscussion(discussions)
        }
        
    }
    
    func initDiscussion(_ discussions: [Discussion]) {
        if User.sharedInstance.isPatient! {
            for discussion in discussions {
                for favorite in discussion.favorites {
                    if favorite == User.sharedInstance.id {
                        self.discussions?.append(discussion)
                    }
                }
            }
        }else {
            self.discussions = discussions
        }
        if User.sharedInstance.isPatient! {
            if self.count == 2 {
                self.loadPrefersLikes()
            }
        }else {
            if self.count == 2 {
                self.loadLinkedBusinesses()
            }
        }
    }
    func loadLinkedBusinesses() {
        var item: PrefersItem?
        var origin_y: CGFloat = 0
        var origin_x: CGFloat = 0
        var last_item: PrefersItem?
        
        self.subviews.forEach { (view) in
           view.removeFromSuperview()
        }
        // Linked employees
        if isFirstTab == true{
            scrView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 110))
            scrView?.showsHorizontalScrollIndicator = false
            self.addSubview(scrView!)
            self.contentSize = CGSize(width: 0, height: 110)
            
            for i in 0 ..< linked_employees!.count {
                if last_item != nil {
                    origin_x = last_item!.frame.origin.x + 125
                }
                item = PrefersItem(frame: CGRect(x: origin_x, y: 50, width: 120, height: 110))
                item?.loadNibName(linked_employees![i])
                last_item = item
                self.scrView?.addSubview(item!)
                self.scrView?.contentSize = CGSize(width: item!.frame.origin.x + item!.frame.size.width, height: 110)
            }
        }// Recent Posts
        else{
            last_item = nil
            origin_y = 0
            for i in 0 ..< self.discussions!.count {
                if last_item != nil {
                    origin_y = last_item!.frame.origin.y + last_item!.frame.size.height + 10
                }

                item = PrefersItem(frame: CGRect(x: 0, y: origin_y, width: self.frame.width, height: 150))
                item?.loadNibName(self.discussions![i])
                last_item = item
                self.addSubview(item!)
                self.contentSize = CGSize(width: 0, height: item!.frame.origin.y + item!.frame.size.height + 10)
                if i > 4 {
                    break
                }
            }
        }
    }
    
    func loadPrefersLikes() {
        var item: PrefersItem?
        var origin_y: CGFloat = 0
        var origin_x: CGFloat = 0
        var last_item: PrefersItem?
//        configurePageControl()
        // Prefers
        self.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        if isFirstTab == true{
            scrView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 110))
            scrView?.showsHorizontalScrollIndicator = false
            self.addSubview(scrView!)
            self.contentSize = CGSize(width: 0, height: 110)
            
            for i in 0 ..< prefers!.count {
                if last_item != nil {
                    origin_x = last_item!.frame.origin.x + 125
                }
                item = PrefersItem(frame: CGRect(x: origin_x, y: 0, width: 120, height: 110))
                item?.loadNibName(prefers![i])
                last_item = item
                self.scrView?.addSubview(item!)
                self.scrView?.contentSize = CGSize(width: item!.frame.origin.x + item!.frame.size.width, height: 110)
            }
        } //Likes
        else{
             origin_y = 0
             last_item = nil
             for i in 0 ..< self.discussions!.count {
                 if last_item != nil {
                     origin_y = last_item!.frame.origin.y + last_item!.frame.size.height + 10
                 }
                 item = PrefersItem(frame: CGRect(x: 0, y: origin_y, width: self.frame.width, height: 150))
                 item?.loadNibName(self.discussions![i])
                 
                 last_item = item
                 self.addSubview(item!)
                 self.contentSize = CGSize(width: 0, height: item!.frame.origin.y + item!.frame.size.height + 10)
             }
        }
    }
    
    func configurePageControl() {
        self.pageControl = UIPageControl(frame: CGRect(x: 0, y: 90, width: self.frame.width, height: 20))
        self.pageControl?.numberOfPages = prefers!.count
        self.pageControl?.currentPage = 0
        self.pageControl?.tintColor = UIColor.red
        self.pageControl?.pageIndicatorTintColor = UIColor.lightGray
        self.pageControl?.currentPageIndicatorTintColor = AppTheme.light_green
        self.addSubview(pageControl!)
    }
    
    @objc func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl!.currentPage) * scrView!.frame.size.width
        scrView?.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl?.currentPage = Int(pageNumber)
    }

}
