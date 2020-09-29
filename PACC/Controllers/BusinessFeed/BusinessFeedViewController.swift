//
//  BusinessFeedViewController.swift
//  PACC
//
//  Created by RSS on 9/12/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

class BusinessFeedViewController: BaseViewController {
    
    @IBOutlet weak var scrChat: PaccChat!
    @IBOutlet weak var txtMessage: UITextField!
    @IBOutlet weak var msgContainer: UIView!
    @IBOutlet weak var bigImage: UIImageView!
    
    @IBOutlet weak var heightbtn: NSLayoutConstraint!
    var image: UIImage!
    var isInThisView: Bool = true
    var import_message: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if User.sharedInstance.isPatient != nil && !User.sharedInstance.isPatient! && User.sharedInstance.is_premium != nil && User.sharedInstance.is_premium! {
            msgContainer.alpha = 1.0
            
            heightbtn.constant = 60
            scrChat.frame = CGRect(x: self.scrChat.frame.origin.x, y: self.scrChat.frame.origin.y, width: self.scrChat.frame.width, height: self.scrChat.frame.height - 70)
            scrChat.layoutIfNeeded()
        }else {
            heightbtn.constant = 0
            msgContainer.alpha = 0.0
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !import_message {
            self.scrChat.add_message_queue.cancelAllOperations()
            isInThisView = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        import_message = false
        isInThisView = true
        self.scrChat.messages = []
        self.get_businessmsg_from_firebase()
    }
    
    func get_businessmsg_from_firebase() {
        self.showHUD()
        API.sharedInstance.get_businessmsg_from_firebase { (messages) in
            self.hideHUD()
            if !self.isInThisView {
                return
            }
            guard let messages = messages else { return }
            if self.scrChat.messages == nil {
            }
            if messages.count > 0 && self.scrChat.messages == nil {
                self.scrChat.type = 1
                self.scrChat.messages = messages
                self.scrChat.initView()
            }
            if self.scrChat.messages != nil && messages.count > self.scrChat.messages!.count {
                for i in self.scrChat.messages!.count ..< messages.count {
                    self.scrChat.add_message(messages[i], true)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnActionSendMsg(_ sender: UIButton) {
        self.sendMessage(txtMessage.text!, 0)
        txtMessage.text = ""
    }
    
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
        
        guard !txtMessage.text!.isEmpty else {
            self.alertViewController(title: "Error", message: "Please Write Something")
            return
        }
        
        var messageDic: [String: Any] = [
            "_createdDate": Date().utcDate(),
            "type": type
        ]
        
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
        
        self.scrChat.add_message(message, true)
        self.txtMessage.text = ""
        self.view.endEditing(true)
    }

}

extension BusinessFeedViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       
        return true
    }
}

extension BusinessFeedViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
        self.sendMessage("", 1)
        dismiss(animated:true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
