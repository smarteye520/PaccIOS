//
//  MessageViewController.swift
//  PACC
//
//  Created by RSS on 4/18/18.
//  Copyright © 2018 HTK. All rights reserved.
//  Copyright © 2020 KSun

import UIKit
import RealmSwift
import DropDown
import IQKeyboardManagerSwift

class MessageViewController: BaseViewController {

    @IBOutlet weak var scrUser: UIScrollView!
    @IBOutlet weak var liveChatContainer: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var paccChat: PaccChat!
    @IBOutlet weak var btnImage: UIButton!
    @IBOutlet weak var textMessage: GrowingTextView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var bigImage: UIImageView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var txtSearch: SearchTextField!
    @IBOutlet weak var searchBaseView: BaseView!
    @IBOutlet weak var btnLiveChat: UIButton!
    @IBOutlet weak var chatInputView: UIView!
    @IBOutlet weak var keyboardViewHeight: NSLayoutConstraint!
    var prevButton: Int = 100
    var all_users: [User] = []
    var users_showing: [User] = []
    var users_nonShowing: [User] = []
    var all_messages: [Message] = []
    var receiver: User?
    var image: UIImage!
    var isInThisView: Bool = true
    var isKeyboardOn : Bool = false
    var import_message: Bool = false
    var recentMessageState: Bool = false
    
    var isSearchTextField : Bool!
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    let settingDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [self.settingDropDown]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.setupMenuBarButton()
        IQKeyboardManager.shared.enable = false
        initView()
        textMessage.delegate = self
        txtSearch.delegate = self
        isKeyboardOn = false
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !import_message {
            self.paccChat.add_message_queue.cancelAllOperations()
            isInThisView = false
        }
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        import_message = false
        isInThisView = true
        isSearchTextField = true
        textMessage.text = ""
        txtSearch.text = ""
        NotificationCenter.default.addObserver(self, selector: #selector(addUserToMessage),
            name: .addMessageUser, object: nil)
        
        // For avoiding that the text cursor disappears behind the keyboard, adjust the text for it
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIWindow.keyboardDidShowNotification, object: nil)
              
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func btnActionMenu(_ sender: UIButton) {
        sideMenuController?.showLeftView(animated: true, completionHandler: nil)
    }
    
    @IBAction func btnActionSendMessage(_ sender: UIButton) {
        self.sendMessage(textMessage.text!, 0)
        textMessage.text = ""
    }
    @IBAction func actionSwitchView(_ sender: UIButton) {
           buttons[prevButton - 100].removeBottomLine()
           sender.drawBottomLine()
           prevButton = sender.tag
           initHeaderView(prevButton - 100)
    }
    @IBAction func actionBack(_ sender: UIButton) {
       if recentMessageState == true {
            initHeaderView(0)
            searchBaseView.alpha = 1.0
       }else{
           self.appDelegate.makingRoot("enterApp")
       }
   }
       
   @IBAction func actionPhoto(_ sender: UIButton) {
       self.view.endEditing(true)
       
       let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
       alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
           self.openCamera()
       }))
       
       alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
           self.openGallary()
       }))
       
       alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
       
       if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
           if let popoverController = alert.popoverPresentationController {
               let barButtonItem = UIBarButtonItem(customView: sender)
               popoverController.barButtonItem = barButtonItem
           }
       }
       
       self.present(alert, animated: true, completion: nil)
   }
    // MARK: - Notifications Handling
    @objc private func addUserToMessage(_ notification: Notification) {
        var item: MessageItem?
        var last_item: MessageItem?
        var offset_y: CGFloat = 0
        
        let addedUser = notification.userInfo!["addUserInfoKey"] as! User
        self.users_nonShowing.remove(addedUser)
        self.users_showing.append(addedUser)
        
        for i in 0 ..< users_showing.count {
            if last_item != nil {
                offset_y = last_item!.frame.origin.y + last_item!.frame.height
            }
           item = MessageItem(frame: CGRect(x: 0, y: offset_y, width: self.scrUser.frame.width, height: 80))

            if(UserDefaults.standard.value(forKey: "blockeUsers") != nil){
                let arrBlockedData = UserDefaults.standard.value(forKey: "blockeUsers") as! NSArray
                if(arrBlockedData.count != 0 ) {
                    if arrBlockedData.contains(self.all_users[i].id!) {
                        print("yes")
                    }else {
                        item?.user = self.users_showing[i]
                    }
                }
            }else {
                item?.user = self.users_showing[i]
            }

            item?.delegate = self
            item?.all_messages = self.all_messages
            last_item = item
            self.scrUser.addSubview(item!)
            self.scrUser.contentSize = CGSize(width: 0, height: last_item!.frame.origin.y + last_item!.frame.height)
            self.scrUser.layoutIfNeeded()
//            recentMessageState = true
            gotoContent(last_item!)
        }
        
    }
    func initView() {
        btnBack.setButtonShadow()
        scrUser.showsVerticalScrollIndicator = false
        actionSwitchView(buttons[prevButton - 100])
        configureCustomSearchTextField()
 // Drop down
        customizeDropDown(self)
        settingDropDown.anchorView = btnLiveChat
        settingDropDown.bottomOffset = CGPoint(x: 0, y: btnLiveChat.bounds.height)
        settingDropDown.width = btnLiveChat.bounds.width
        settingDropDown.dataSource = [
            "Business",
            "User"
        ]
        settingDropDown.selectionAction = { [unowned self] (index, item) in
            switch index {
            case 0:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileViewController
                
                vc.isfROMsIDEmenu = true
                self.present(vc, animated: true, completion: nil)
            case 1:
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.deleteUser()
                User.sharedInstance.initialize()
                appDelegate.makingRoot("initial")
            default:
                break
            }
        }
    }
    
    func customizeDropDown(_ sender: AnyObject) {
        DropDown.setupDefaultAppearance()
        dropDowns.forEach {
            $0.cellNib = UINib(nibName: "DropDownCell", bundle: Bundle(for: DropDownCell.self))
            $0.cellHeight = 35
            $0.customCellConfiguration = nil
        }
    }
    
    fileprivate func configureCustomSearchTextField() {
        // Set theme - Default: light
        txtSearch.theme = SearchTextFieldTheme.lightTheme()
        // Update data source when the user stops typing
        txtSearch.userStoppedTypingHandler = {
            if let criteria = self.txtSearch.text {
                if criteria.count > 0 {
                    
                    // Show loading indicator
                    self.txtSearch.showLoadingIndicator()
                    
                    self.filterAcronymInBackground(criteria) {
                        user in
                        // Stop loading indicator
                        self.txtSearch.stopLoadingIndicator()
                        DispatchQueue.main.async {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchResultVC") as! SearchResultViewController
                            vc.businesses = user!
                            vc.fromMessageView = true
                            self.navigationController?.pushViewController(vc, animated: true)
                            self.view.endEditing(true)
                        }
                    }
                }
            }
        } as (() -> Void)
    }
    
    fileprivate func filterAcronymInBackground(_ criteria: String, callback: @escaping (_ results: [User]?) -> Void) {
        var searched_users: [User] = []
        if self.users_nonShowing != nil {
            for user in self.users_nonShowing {
                if user.name?.range(of: criteria, options: .caseInsensitive) != nil {
                    searched_users.append(user)
                }
            }
        }
        callback(searched_users)
    }
    
    func get_messages_from_wix() {
        self.showHUD()
        var collection_name: String = "User"
        if User.sharedInstance.isPatient! {
            collection_name = "Business"
        }
        API.sharedInstance.getAllItems(collection_name) { (users) in
            API.sharedInstance.getAllItems("Message", completion: { (messages) in
                self.hideHUD()
                self.all_users.removeAll()
                self.all_messages.removeAll()
                if users != nil && users!.count > 0 {
                    self.all_users = users! as! [User]
                }
                if messages != nil && messages!.count > 0 {
                    for message in messages!
                    {
                        let messageElement = message as! Message
                        if messageElement.sender == User.sharedInstance.id || messageElement.receiver == User.sharedInstance.id {
                            self.all_messages.append(messageElement)
                        }
                    }
                }
                if self.all_messages.count > 0 {
                    self.users_nonShowing = self.all_users
                    for user in self.all_users{
                        for message in self.all_messages {
                            if message.sender == user.id || message.receiver == user.id {
                                self.users_nonShowing.remove(user)
                                self.users_showing.append(user)
                                break
                            }
                        }
                    }
                }
                self.reloadAllUsers()
            })
        }
    }
    func reloadAllUsers() {
        var item: MessageItem?
        var last_item: MessageItem?
        var offset_y: CGFloat = 0

        for i in 0 ..< users_showing.count {
            if last_item != nil {
                offset_y = last_item!.frame.origin.y + last_item!.frame.height
            }
           item = MessageItem(frame: CGRect(x: 0, y: offset_y, width: self.scrUser.frame.width, height: 80))

            if(UserDefaults.standard.value(forKey: "blockeUsers") != nil){
                let arrBlockedData = UserDefaults.standard.value(forKey: "blockeUsers") as! NSArray
                if(arrBlockedData.count != 0 ) {
                    if arrBlockedData.contains(self.all_users[i].id!) {
                        print("yes")
                    }else {
                        item?.user = self.users_showing[i]
                    }
                }
            }else {
                item?.user = self.users_showing[i]
            }

            item?.delegate = self
            item?.all_messages = self.all_messages
            last_item = item
            self.scrUser.addSubview(item!)
            self.scrUser.contentSize = CGSize(width: 0, height: last_item!.frame.origin.y + last_item!.frame.height)
            self.scrUser.layoutIfNeeded()
        }
    }
    
    func get_messages_from_firebase() {
        self.showHUD()
        API.sharedInstance.get_messages_from_firebase { (messages) in
            self.hideHUD()
            if !self.isInThisView {
                return
            }
            if self.paccChat.messages == nil {
            }
            if messages != nil && messages!.count > 0 && self.paccChat.messages == nil {
                self.paccChat.type = 1
                self.paccChat.messages = messages!
                self.paccChat.initView()
            }
            if messages != nil && self.paccChat.messages != nil && messages!.count > self.paccChat.messages!.count {
                for i in self.paccChat.messages!.count ..< messages!.count {
                    self.paccChat.add_message(messages![i], true)
                }
            }
        }
    }
    func initHeaderView(_ type: Int) {
        self.paccChat.add_message_queue.cancelAllOperations()
        self.paccChat.messages = nil
        self.paccChat.initView()
        if type == 0 {
            scrUser.alpha = 1.0
            liveChatContainer.alpha = 0.0
            searchBaseView.alpha = 1.0
            self.tabBarController?.tabBar.isHidden = false
            if self.all_users.count == 0 {
                self.get_messages_from_wix()
            }
            recentMessageState = false
        }else {
            scrUser.alpha = 0.0
            liveChatContainer.alpha = 1.0
            searchBaseView.alpha = 0.0
            self.tabBarController?.tabBar.isHidden = true
            self.get_messages_from_firebase()
//
//            self.view.endEditing(true)
//            settingDropDown.show()
            
            recentMessageState = false
        }
        if type == 2 {
            nameView.alpha = 1.0
            lblMessage.alpha = 0.0
        }else {
            lblMessage.alpha = 1.0
            nameView.alpha = 0.0
        }
    }

   
    
    func openCamera()
    {
        import_message = true
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary()
    {
        import_message = true
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func sendMessage(_ content: String, _ type: Int) {
        
        var messageDic: [String: Any] = [
            "_createdDate": Date().utcDate(),
            "type": type
        ]
        if self.paccChat.type == 0 {
            messageDic.updateValue(receiver?.isPatient ?? true, forKey: "receiverType")
            messageDic.updateValue(receiver?.id ?? "", forKey: "receiver")
        }
        
        messageDic.updateValue(User.sharedInstance.isPatient!, forKey: "senderType")
        messageDic.updateValue(User.sharedInstance.id!, forKey: "sender")
        
        if type == 1 {
            messageDic.updateValue(self.image.pngData()!, forKey: "image")
            messageDic.updateValue(self.image.size.width, forKey: "width")
            messageDic.updateValue(self.image.size.height, forKey: "height")
        }else {
            messageDic.updateValue(content, forKey: "content")
        }
        
        let message = Message(value: messageDic)
        
        self.paccChat.add_message(message, true)
        self.textMessage.text = ""
        self.view.endEditing(true)
    }
    
    
//        func customizeDropDown(_ sender: AnyObject) {
//            DropDown.setupDefaultAppearance()
//
//            dropDowns.forEach {
//                $0.cellNib = UINib(nibName: "DropDownCell", bundle: Bundle(for: DropDownCell.self))
//                $0.cellHeight = 35
//                $0.customCellConfiguration = nil
//            }
//        }
//
//        @IBAction func actionClickDropmenu(_ sender: UIButton) {
//            self.view.endEditing(true)
//            settingDropDown.show()
//        }
    
      // MARK: - Notifications
    @objc func keyboardWasShown(notification: Notification) {
        if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?
            CGRect {
            if isKeyboardOn {
                return
            }
            
            UIView.animate(withDuration: 0.3) {
                if self.isSearchTextField == true {
                     self.view.frame.origin.y = 0
                }else{
                     self.view.frame.origin.y -= keyboardSize.height
                }
                
                self.isKeyboardOn = true
            }
        }
    }
    @objc func keyboardWillHide(notification: Notification) {
          UIView.animate(withDuration: 0.3) {
              self.view.frame.origin.y = 0
              self.isKeyboardOn = false

          }
    }
}

extension MessageViewController: MessageItemDelegate {
    
    func gotoContent(_ item: MessageItem) {
        nameView.alpha = 1.0
        searchBaseView.alpha = 0.0
        lblMessage.alpha = 0.0
        scrUser.alpha = 0.0
        liveChatContainer.alpha = 1.0
        self.tabBarController?.tabBar.isHidden = true
        self.paccChat.type = 0
        self.paccChat.messages = item.messages
        self.paccChat.initView()
        self.receiver = item.user
        lblName.text = item.lblName.text
        
        self.recentMessageState = true
    }
    
}

extension MessageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
        self.sendMessage("", 1)
        dismiss(animated:true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension Notification.Name {
    static let addMessageUser = Notification.Name("AddMessageUser")
}

extension MessageViewController : UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.isSearchTextField = false
    }
      
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
      if text == "\n" {
          textView.resignFirstResponder()
          return false
      }
      return true
    }
}
extension MessageViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
        self.isSearchTextField = true
    }
}
