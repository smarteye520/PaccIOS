//
//  PrefersItem.swift
//  PACC
//
//  Created by RSS on 5/7/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

class PrefersItem: UIView {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblBusinessType: UILabel!
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var lblPostTitle: UILabel!
    @IBOutlet weak var lblPostDescription: UILabel!
    @IBOutlet weak var feedImg: UIImageView!
    
    var discussion: Discussion?
    var user: User?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadNibName(_ likeMan: String, _ postTitle: String) {
        let view = Bundle.main.loadNibNamed("PrefersItem", owner: self, options: nil)?[2] as! UIView
        view.frame = self.bounds
        view.backgroundColor = self.backgroundColor
        self.addSubview(view)
        self.lblLikes.text = "Title: \(likeMan), Description: (\(postTitle))"
    }
    
    func loadNibName(_ title: String) {
        let view = Bundle.main.loadNibNamed("PrefersItem", owner: self, options: nil)?[1] as! UIView
        view.frame = self.bounds
        view.backgroundColor = self.backgroundColor
        self.addSubview(view)
        self.lblTitle.text = title
    }
    
    func loadNibName(_ user: User) {
        let view = Bundle.main.loadNibNamed("PrefersItem", owner: self, options: nil)?[0] as! UIView
        view.frame = self.bounds
        view.backgroundColor = self.backgroundColor
        self.addSubview(view)
        self.lblName.text = user.name
        self.lblBusinessType.text = user.business_type
        self.user = user
        if user.profileimg != nil && user.profileimg != "" {
            ImageLoader.sharedLoader.imageForUrl(urlString: user.profileimg!) { (image, url) in
                self.imgProfile.image = image
            }
        }
    }
    
    func loadNibName(_ post: Discussion) {
        let view = Bundle.main.loadNibNamed("PrefersItem", owner: self, options: nil)?[3] as! UIView
        view.frame = self.bounds
//        view.backgroundColor = self.backgroundColor
        self.addSubview(view)
        self.lblPostTitle.text = post.name
        self.lblPostDescription.text = post.descript
//        DispatchQueue.global(qos: .background).async {
            ImageLoader.sharedLoader.imageForUrl(urlString: post.image!, completionHandler: { (image, url) in
                self.feedImg.image = image //?.cropToBounds(width: self.feedImg.frame.width, height: self.feedImg.frame.height) 
            })
//        }
        self.discussion = post
    }

    @IBAction func actionGotoProfileView(_ sender: UIButton) {
        if self.findViewController() is ProfileViewController {
            let viewCon = self.findViewController() as? ProfileViewController
            let vc = viewCon?.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileViewController
            vc.user = self.user
            viewCon?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func actionGotoDiscussionView(_ sender: UIButton) {
        if self.findViewController() is ProfileViewController {
            let viewCon = self.findViewController() as? ProfileViewController
            let vc = viewCon?.storyboard?.instantiateViewController(withIdentifier: "CommentPostVC") as! CommentPostViewController
            vc.discussion = self.discussion
            viewCon?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
