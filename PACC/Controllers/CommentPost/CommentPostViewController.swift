//
//  CommentPostViewController.swift
//  PACC
//
//  Created by RSS on 6/17/18.
//  Copyright © 2018 HTK. All rights reserved.
//  Copyright © 2020 KSI. Updated

import UIKit
import SKPhotoBrowser
class CommentPostViewController: BaseViewController {
    
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var imgPost: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var txtComment: GrowingTextView!
    @IBOutlet weak var scrComment: PaccComment!
    @IBOutlet weak var lblReadArticle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnFavorite: UIButton!
    @IBOutlet weak var lblPoster: UILabel!
    @IBOutlet weak var scrContent: UIScrollView!
    @IBOutlet weak var lblDescription: UITextView!
    @IBOutlet weak var ViewComment: UIView!
    var discussion: Discussion?
    
    @IBOutlet weak var tblComment: UITableView!
    @IBOutlet weak var txtCommentHeight: NSLayoutConstraint!
    @IBOutlet weak var commetViewHeight: NSLayoutConstraint!
    
    var isKeyboardon : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
   
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imgPost.isUserInteractionEnabled = true
        imgPost.addGestureRecognizer(tapGestureRecognizer)
        
        if scrComment.comments.count != 0 {
          let lastIndexPath = IndexPath(row: scrComment.comments.count - 1, section: 0)
          let lastCellPosition = tblComment.rectForRow(at: lastIndexPath)
          tblComment.scrollRectToVisible(lastCellPosition, animated: true)
        }
        self.txtComment.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ViewComment.layer.borderColor = UIColor.lightGray.cgColor
        ViewComment.layer.borderWidth = 1
        ViewComment.layer.cornerRadius = 6
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIWindow.keyboardDidShowNotification, object: nil)
                    
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
@objc func keyboardWasShown(notification: Notification) {

   if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?
       CGRect {
       if isKeyboardon {
           return
       }
       
       UIView.animate(withDuration: 0.3) {
           self.view.frame.origin.y -= (keyboardSize.height)
           self.isKeyboardon = true
//            DispatchQueue.main.async {
//                if self.scrComment.comments.count > 0 {
//                    self.tblComment.scrollToRow(at: IndexPath(row: self.scrComment.comments.count - 1, section: 0), at: .bottom, animated: true)
//                }
//            }
           }
       }
   }
   @objc func keyboardWillHide(notification: Notification) {
         UIView.animate(withDuration: 0.3) {
             self.view.frame.origin.y = 0
             self.isKeyboardon = false
//             DispatchQueue.main.async {
//               if self.scrComment.comments.count > 0 {
//                   self.tblComment.scrollToRow(at: IndexPath(row: self.scrComment.comments.count - 2, section: 0), at: .bottom, animated: true)
//               }
//            }
         }
   }
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        // 1. create URL Array
        var images = [SKPhoto]()
        let photo = SKPhoto.photoWithImageURL( self.discussion!.image!)
        photo.shouldCachePhotoURLImage = false // you can use image cache by true(NSCache)
        images.append(photo)
        
        // 2. create PhotoBrowser Instance, and present.
        let browser = SKPhotoBrowser(photos: images)
        browser.initializePageIndex(0)
        present(browser, animated: true, completion: {})
    }

    func initView() {
        scrContent.contentSize = CGSize(width: 0, height: 100)
        lblName.text = discussion?.name
        lblDate.text = "Posted on --/--/----"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        if discussion != nil {
            lblDate.text = "Posted on \(dateFormatter.string(from: discussion!.created_at!))"
        }
        if discussion?.favorites != nil {
            for favorite in discussion!.favorites {
                if favorite == User.sharedInstance.id {
                    btnFavorite.setImage(#imageLiteral(resourceName: "favorite"), for: .normal)
                    break
                }
            }
        }
        lblDescription.text = discussion?.descript
        
        if discussion?.image != nil {
            ImageLoader.sharedLoader.imageForUrl(urlString: self.discussion!.image!) { (image, url) in
                DispatchQueue.main.async {
                    self.imgPost.image = image //?.cropToBounds(width: self.imgPost.frame.width, height: self.imgPost.frame.height)
                }
            }
        }
        
        let collection: String = User.sharedInstance.isPatient! ? "User" : "Business"
        API.sharedInstance.getItemInfor(collection, self.discussion!.poster!) { (userDic) in
            DispatchQueue.main.async {
                if userDic != nil {
                    let user = User()
                    user.loadUserInfo(userDic!)
                    self.lblPoster.text = "Posted from \(user.name ?? "")"
                }
            }
        }
        
        if User.sharedInstance.isPatient! && User.sharedInstance.is_premium != nil && User.sharedInstance.is_premium! {
        }else {

        }
        scrComment.comments = discussion!.comments
        tblComment.reloadData()
        if scrComment.comments.count > 0 {
            let indexPath = NSIndexPath(row: scrComment.comments.count - 1, section: 0)
            self.tblComment.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
        }
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnActionSend(_ sender: UIButton) {
       
        guard !txtComment.text!.isEmpty else {
            self.alertViewController(title: "Error", message: "Comment cannot be empty")
            return
        }
        
        let info: NSDictionary = [
            "id": User.sharedInstance.id!,
            "content": txtComment.text!,
            "created_at": Date().utcDate()
        ]
        let comment = Comment(value: info)
        self.scrComment.addComment(comment, true)
        self.view.endEditing(true)
        self.txtComment.text = ""
        API.sharedInstance.updateItem("Discussion", discussion!.getDic()) { (success) in
            DispatchQueue.main.async {
                if !success! {
                    self.alertViewController(title: "Error", message: "Sorry, comment on post failed. Please try again later.")
                }else{
                    self.tblComment.reloadData()
                    let indexPath = NSIndexPath(row: self.scrComment.comments.count - 1, section: 0)
                    self.tblComment.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    @IBAction func actionBack(_ sender: UIButton) {
        self.scrComment.add_comment_queue.cancelAllOperations()
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension CommentPostViewController: UITextViewDelegate {
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//
//    }
}

extension CommentPostViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if scrComment.comments.count != 0 {
             return scrComment.comments.count
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblComment.dequeueReusableCell(withIdentifier: "CommentTblCell", for: indexPath) as! CommentTblCell
       
         cell.lblComment.text = self.scrComment.comments[indexPath.row].content
             
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "MM/dd"
          cell.lblDay.text = dateFormatter.string(from: self.scrComment.comments[indexPath.row].created_at!)
          dateFormatter.dateFormat = "HH:mm a"
          cell.lblTime.text = dateFormatter.string(from: self.scrComment.comments[indexPath.row].created_at!)
            DispatchQueue.main.async {
                if User.sharedInstance.isPatient != false{
                    API.sharedInstance.getItemInfor("User", self.scrComment.comments[indexPath.row].commenter!) { (dic) in
                         if dic != nil {
                             let patient = User()
                             patient.loadUserInfo(dic!)
                             if patient.profileimg != nil {
                                 cell.profile.loadImageWithoutIndicator(urlString: patient.profileimg!)
                             }
                            if patient.name != nil{
                                cell.lblName.text = patient.name
                            }else{
                                cell.lblName.text = ""
                            }
                        }
                    }
                }else{
                    API.sharedInstance.getItemInfor("Business", self.scrComment.comments[indexPath.row].commenter!) { (dic) in
                         if dic != nil {
                             let patient = User()
                             patient.loadUserInfo(dic!)
                             if patient.profileimg != nil {
                                 cell.profile.loadImageWithoutIndicator(urlString: patient.profileimg!)
                             }
                            if patient.name != nil{
                                cell.lblName.text = patient.name
                            }else{
                                cell.lblName.text = ""
                            }
                        }
                    }
                }

          }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

