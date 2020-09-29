//
//  DiscussionCell.swift
//  PACC
//
//  Created by RSS on 7/5/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import MessageUI

class DiscussionCell: UIView , MFMailComposeViewControllerDelegate {

    @IBOutlet weak var heightCell: NSLayoutConstraint!
    @IBOutlet weak var discussionProfile: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var btnFavorite: UIButton!
    @IBOutlet weak var posterImg: UIImageView!
    @IBOutlet weak var posterName: UILabel!
    
    @IBOutlet weak var btnRemover: UIButton!
    var discussion: Discussion? {
        didSet {
            self.lblTitle.text = self.discussion?.name
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            self.lblDateTime.text = "Posted on \(dateFormatter.string(from: self.discussion!.created_at!))"
        //    self.btnFavorite.setImage(#imageLiteral(resourceName: "favorite-inactive"), for: .normal)
            if self.discussion?.favorites != nil {
                for favorite in self.discussion!.favorites {
                    if favorite == User.sharedInstance.id {
                      //  self.btnFavorite.setImage(#imageLiteral(resourceName: "favorite"), for: .normal)
                        break
                    }
                }
            }
            API.sharedInstance.getItemInfor("Business", discussion!.poster!) { (userDic) in
                DispatchQueue.main.async {
                    if userDic != nil {
                        let user = User()
                        user.loadUserInfo(userDic!)
                        self.posterName.text = user.name
                        if user.profileimg != nil {
                            self.posterImg.loadImageWithoutIndicator(urlString: user.profileimg!)
                        }
                    }
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibName()
        self.subviews[0].subviews[0].setPostRadius(15)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibName()
    }
    
    func loadNibName() {
        let view = Bundle.main.loadNibNamed("DiscussionCell", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    @IBAction func actionFavorite(_ sender: UIButton) {
        guard let id = User.sharedInstance.id else {
            return
        }
        let favorites_arr = discussion?.favorites
        let is_favorite: Bool = favorites_arr?.index(of: id) == nil ? false : true
        if is_favorite {
           // btnFavorite.setImage(#imageLiteral(resourceName: "favorite-inactive"), for: .normal)
            try! RealmHelper.sharedInstance.realm.write {
                let temp_arr = favorites_arr!
                temp_arr.remove(at: Int((favorites_arr?.index(of: User.sharedInstance.id!))!))
                discussion?.favorites = temp_arr
            }
        }else {
          //  btnFavorite.setImage(#imageLiteral(resourceName: "favorite"), for: .normal)
            try! RealmHelper.sharedInstance.realm.write {
                favorites_arr?.append(User.sharedInstance.id!)
                discussion?.favorites = favorites_arr!
            }
        }
        let vc = findViewController() as! BaseViewController
        vc.showHUD()
        API.sharedInstance.updateItem("Discussion", discussion!.getDic()) { (success) in
            DispatchQueue.main.async {
                vc.hideHUD()
                if !success! {
                    vc.alertViewController(title: "Error", message: "Sorry, favorite on this post failed. Please try again later.")
                }
            }
        }
    }
    
    @IBAction func actionGotoComment(_ sender: UIButton) {
        let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "CommentPostVC") as! CommentPostViewController
        vc.discussion = self.discussion
        if self.findViewController() is DiscussionViewController {
            let viewCon = self.findViewController() as! DiscussionViewController
            viewCon.isGoingToDetail = true
        }
        self.findViewController()?.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func btnActionDelete(_ sender: UIButton) {
  
        
        let alert = UIAlertController(title: "", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Report", style: .default , handler:{ (UIAlertAction)in
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["pennsylvaniacannabisconnection@gmail.com"])
                mail.setMessageBody("<p>Please Enter Description</p>", isHTML: true)
                mail.popoverPresentationController?.sourceView = self
                mail.popoverPresentationController?.sourceRect = sender.frame
                 self.findViewController()?.present(mail, animated: true, completion: nil)
            } else {
                // show failure alert
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Block", style: .default , handler:{ (UIAlertAction)in
            self.heightCell.constant = 0
            self.isHidden = true
            self.layoutIfNeeded()
           
          
            arrmutablData.append(self.discussion?.id! ?? "")
            
            UserDefaults.standard.set(arrmutablData, forKey: "blockeUsers")
           
           NotificationCenter.default.post(name: NSNotification.Name("userBlocked"), object: nil)
           let alerts = UIAlertController(title: "Alert", message: "User Blocked Successfully", preferredStyle: .alert)
            alerts.addAction(image: nil, title: "Ok", color: UIColor.black, style: .cancel, isEnabled: true, handler: nil)
            alerts.popoverPresentationController?.sourceView = self
            alerts.popoverPresentationController?.sourceRect = sender.frame
            self.findViewController()?.present(alerts, animated: true, completion: nil)
           
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        alert.popoverPresentationController?.sourceView = self
        alert.popoverPresentationController?.sourceRect = sender.frame
        self.findViewController()?.present(alert, animated: true, completion:nil)
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

class DiscussionCellOperation: Operation {
    let cell: DiscussionCell?
    var is_finished: Bool = false
    init(_ cell: DiscussionCell) {
        self.cell = cell
    }
    override func main() {
        let discussion = self.cell?.discussion
        DispatchQueue.main.async {
            if discussion?.image != nil {
                SDWebImageDownloader.shared.downloadImage(with: URL(string: discussion!.image!), options: .lowPriority, progress: nil, completed: {(image, data, error, success) in
                    if data != nil && !self.is_finished {
                        DispatchQueue.main.async {
                            try! RealmHelper.sharedInstance.realm.write {
                                discussion?.imgData = data
                            }
                            self.cell?.discussionProfile.image = UIImage(data: discussion!.imgData!) //?.cropToBounds(width: self.cell!.discussionProfile.frame.width, height: self.cell!.discussionProfile.frame.height)
                        }
                    }
                })
            }
        }
    }
    
    override func cancel() {
        self.is_finished = true
    }
    
   
}
