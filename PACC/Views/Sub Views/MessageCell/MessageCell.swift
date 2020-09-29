//
//  MessageCell.swift
//  PACC
//
//  Created by RSS on 6/12/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import RealmSwift

class MessageCell: UIView {

    @IBOutlet weak var senderProfile: UIImageView!
    @IBOutlet weak var receiverProfile: UIImageView!
    @IBOutlet weak var lblSender: UILabel!
    @IBOutlet weak var lblReceiver: UILabel!
    @IBOutlet weak var imgSender: UIImageView!
    @IBOutlet weak var imgReceiver: UIImageView!
    @IBOutlet weak var viewSender: UIView!
    @IBOutlet weak var viewReceiver: UIView!
    @IBOutlet weak var senderLoading: UIImageView!
    @IBOutlet weak var receiverLoading: UIImageView!
    @IBOutlet weak var senderPost: UIView!
    @IBOutlet weak var senderPostName: UILabel!
    @IBOutlet weak var senderPostContent: UILabel!
    @IBOutlet weak var receiverPost: UIView!
    @IBOutlet weak var receiverPostName: UILabel!
    @IBOutlet weak var receiverPostContent: UILabel!
    @IBOutlet weak var senderGradient: UIView!
    @IBOutlet weak var receiverGradient: UIView!
    @IBOutlet weak var lblSenderName: UILabel!
    
    var type: Int?
    
    var message: Message?
    
    func setMessageData() {
        
        if self.message?.type != 0 && self.message?.image != nil {
            if self.message?.sender == User.sharedInstance.id && self.message?.senderType == NSNumber(value: User.sharedInstance.isPatient!).intValue {
                self.imgReceiver.image = UIImage(data: self.message!.image!)
                self.receiverLoading.image = nil
            }else {
                self.imgSender.image = UIImage(data: self.message!.image!)
                self.senderLoading.image = nil
            }
        }

    }
    
    func setProfile() {
        if self.message?.sender == User.sharedInstance.id && self.message?.senderType == NSNumber(value: User.sharedInstance.isPatient!).intValue {
            self.receiverProfile.image = UIImage(data: self.message!.sender_profile!)
        }else {
            self.senderProfile.image = UIImage(data: self.message!.sender_profile!)  
        }
    }
    
    func initCell() {
        if self.message?.type == 0 {
            if self.message?.sender == User.sharedInstance.id && self.message?.senderType == NSNumber(value: User.sharedInstance.isPatient!).intValue {
                self.viewReceiver.isHidden = false
                self.imgReceiver.isHidden = true
                self.receiverPost.isHidden = true
                self.receiverGradient.isHidden = true
                self.lblReceiver.text = self.message?.content
                self.receiverLoading.image = nil
            }else {
                self.viewSender.isHidden = false
                self.lblSender.text = self.message?.content
                self.imgSender.isHidden = true
                self.senderLoading.image = nil
                self.senderPost.isHidden = true
                self.senderGradient.isHidden = true
            }
        }else if self.message?.type == 1 {
            if self.message?.sender == User.sharedInstance.id && self.message?.senderType == NSNumber(value: User.sharedInstance.isPatient!).intValue {
                self.viewReceiver.isHidden = true
                self.imgReceiver.isHidden = false
                self.receiverPost.isHidden = true
                self.receiverGradient.isHidden = true
            }else {
                self.viewSender.isHidden = true
                self.imgSender.isHidden = false
                self.senderPost.isHidden = true
                self.senderGradient.isHidden = true
            }
        }else {
            let post_cont_arr = self.message!.content!.components(separatedBy: "@@@")
            if self.message?.sender == User.sharedInstance.id && self.message?.senderType == NSNumber(value: User.sharedInstance.isPatient!).intValue {
                self.viewReceiver.isHidden = true
                self.imgReceiver.isHidden = false
                self.receiverLoading.image = nil
                self.receiverPostName.text = post_cont_arr.count>1 ? post_cont_arr[1] : ""
                self.receiverPostContent.text = post_cont_arr.count > 2 ? post_cont_arr[2] : ""
            }else {
                self.viewSender.isHidden = true
                self.imgSender.isHidden = false
                self.senderLoading.image = nil
                self.senderPostName.text = post_cont_arr.count>1 ? post_cont_arr[1] : ""
                self.senderPostContent.text = post_cont_arr.count > 2 ? post_cont_arr[2] : ""
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadNibName(_ type: Int) {
        let view = Bundle.main.loadNibNamed("MessageCell", owner: self, options: nil)?[type] as! UIView
        view.frame = self.bounds
        view.backgroundColor = self.backgroundColor
        self.addSubview(view)
        self.type = type
    }
    
    @IBAction func actionGotoProfile(_ sender: UIButton) {
        let vc = self.findViewController() is BusinessFeedViewController ? self.findViewController() as! BusinessFeedViewController : self.findViewController() as! MessageViewController
        let viewCon = vc.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileViewController
        let collection = self.message!.senderType == 0 ? "Business" : "User"
        vc.showHUD()
        API.sharedInstance.getItemInfor(collection, self.message!.sender!) { (userDic) in
            DispatchQueue.main.async {
                vc.hideHUD()
                if userDic != nil {
                    let user = User()
                    user.loadUserInfo(userDic!)
                    viewCon.user = user
                    vc.navigationController?.pushViewController(viewCon, animated: true)
                }
            }
        }
        
    }
    
    @IBAction func gotoCommentDiscussion(_ sender: UIButton) {
        if self.findViewController() is BusinessFeedViewController {
            let vc = self.findViewController() as! BusinessFeedViewController
            switch message?.type {
            case 2:
                vc.showHUD()
                let post_cont_arr = message!.content!.components(separatedBy: "@@@")
                let discussion_id = post_cont_arr[0]
                API.sharedInstance.getItemInfor("Discussion", discussion_id) { (discussion_dic) in
                    DispatchQueue.main.async {
                        vc.hideHUD()
                        if discussion_dic != nil {
                            let viewCon = vc.storyboard?.instantiateViewController(withIdentifier: "CommentPostVC") as! CommentPostViewController
                            viewCon.discussion = Discussion(value: discussion_dic as Any)
                            vc.navigationController?.pushViewController(viewCon, animated: true)
                        }
                    }
                }
            case 1:
                if self.message?.image != nil {
                    let imageInfo = JTSImageInfo()
                    imageInfo.image = UIImage(data: self.message!.image!)
                    imageInfo.referenceRect = vc.bigImage.frame
                    imageInfo.referenceView = vc.bigImage.superview
                    imageInfo.referenceContentMode = vc.bigImage.contentMode
                    imageInfo.referenceCornerRadius = vc.bigImage.layer.cornerRadius
                    
                    let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.image, backgroundStyle: JTSImageViewControllerBackgroundOptions.scaled)
                    
                    imageViewer?.show(from: vc, transition: JTSImageViewControllerTransition.fromOriginalPosition)
                }else {
                    vc.alertViewController(title: "Ooops!", message: "Image still loading. Please wait a bit.")
                }
                
            default:
                break
            }
        }
        
        if self.findViewController() is MessageViewController && self.message?.type == 1 {
            let vc = self.findViewController() as! MessageViewController
            if self.message?.image != nil {
                let imageInfo = JTSImageInfo()
                imageInfo.image = UIImage(data: self.message!.image!)
                imageInfo.referenceRect = vc.bigImage.frame
                imageInfo.referenceView = vc.bigImage.superview
                imageInfo.referenceContentMode = vc.bigImage.contentMode
                imageInfo.referenceCornerRadius = vc.bigImage.layer.cornerRadius
                
                let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.image, backgroundStyle: JTSImageViewControllerBackgroundOptions.scaled)
                
                imageViewer?.show(from: vc, transition: JTSImageViewControllerTransition.fromOriginalPosition)
            }else {
                vc.alertViewController(title: "Ooops!", message: "Image still loading. Please wait a bit.")
            }
        }
        
    }
}


class ImageDownloadOperation: Operation {
    let cell: MessageCell?
    init(_ cell: MessageCell) {
        self.cell = cell
    }
    override func main() {
        let message = self.cell?.message
        
        var collection = "Business"
        DispatchQueue.main.async {
            if message!.senderType == NSNumber(value: true).intValue {
                collection = "User"
            }
            
            API.sharedInstance.getItemInfor(collection, message!.sender!) { (userDic) in
                if userDic != nil {
                    let user = User()
                    user.loadUserInfo(userDic!)
                    DispatchQueue.main.async {
                        if user.id != User.sharedInstance.id {
                            self.cell?.lblSenderName.text = user.name?.capitalized
                        }
                    }
                    
                    SDWebImageDownloader.shared.downloadImage(with: URL(string: user.profileimg!), options: .lowPriority, progress: nil) { (image, data, error, success) in
                        if data != nil {
                            DispatchQueue.main.async {
                                try! RealmHelper.sharedInstance.realm.write {
                                    message?.sender_profile = data
                                }
                                self.cell?.setProfile()
                            }
                        }
                        if message?.type == 1 || message?.type == 2 {
                            if message?.image == nil {
                                var imgURL = message!.content!
                                if message?.type == 2 {
                                    let post_cont_arr = message!.content!.components(separatedBy: "@@@")
                                    imgURL = post_cont_arr.count > 3 ? post_cont_arr[3] : ""
                                }
                                SDWebImageDownloader.shared.downloadImage(with: URL(string: imgURL), options: .lowPriority, progress: nil, completed: {(image, data, error, success) in
                                    if data != nil {
                                        DispatchQueue.main.async {
                                            try! RealmHelper.sharedInstance.realm.write {
                                                message?.image = data
                                            }
                                            self.cell?.setMessageData()
                                        }
                                    }                                    
                                    self.cancel()
                                })
                            }else {
                                self.cell?.setMessageData()
                                self.cancel()
                            }
                        }
                    }
                }
            }
        }
        
    }
}


