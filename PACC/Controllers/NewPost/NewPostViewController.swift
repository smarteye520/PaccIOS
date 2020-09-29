//
//  NewPostViewController.swift
//  PACC
//
//  Created by RSS on 6/17/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import CropViewController

class NewPostViewController: BaseViewController {
    
    @IBOutlet weak var scrView: UIScrollView!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var imgPost: UIImageView!
    @IBOutlet weak var imgLoading: UIImageView!
    
    var user: User?
    var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    func initView() {
        imagePicker.delegate = self
        scrView.contentSize = CGSize(width: self.view.frame.width, height: 667)
        txtDescription.placeholder = "Post Comments"
    }
    @IBAction func btnActionSidemeny(_ sender: UIButton) {
        
        sideMenuController?.showLeftView(animated: true, completionHandler: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
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
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionPost(_ sender: UIButton) {
        
        if let str = checkFields(), str == "" {
            self.showHUD()
            var param: [String: Any] = [
                "name": txtName.text!,
                "description": txtDescription.text!,
                "poster": User.sharedInstance.id!,
                "poster_type": User.sharedInstance.business_type ?? "",
                "receiver": self.user?.id ?? ""
            ]
            API.sharedInstance.uploadImage(imgPost.image!) { (url) in
                DispatchQueue.main.async {
                    self.hideHUD()
                    if url != nil {
                        param.updateValue(url!, forKey: "image")
                        API.sharedInstance.insertItem("Discussion", param as NSDictionary) { (post_dic) in
                            DispatchQueue.main.async {
                                self.hideHUD()
                                if post_dic != nil {
                                    let discussion = Discussion(value: post_dic as Any)
                                    RealmHelper.sharedInstance.insert(discussion)
                                    let alertController = UIAlertController(title: "Would you also like to share this to the live feed?", message: "", preferredStyle: .alert)
                                    
                                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                                        (action : UIAlertAction!) -> Void in
                                        self.navigationController?.popViewController(animated: true)
                                    })
                                    
                                    let submitAction = UIAlertAction(title: "Post", style: .default, handler: {
                                        alert -> Void in
                                        let info: NSDictionary = [
                                            "_createdDate": Date().utcDate(),
                                            "type": 2,
                                            "sender": User.sharedInstance.id!,
                                            "senderType": User.sharedInstance.isPatient!,
                                            "content": "\(post_dic!["_id"] as? String ?? "")@@@\(post_dic!["name"] as? String ?? "")@@@\(post_dic!["description"] as? String ?? "")@@@\(url ?? "")"
                                        ]
                                        let message = Message(value: info)
                                        API.sharedInstance.addBusinessMessage(message, message.created_at!.localToUTC())
                                        self.navigationController?.popViewController(animated: true)
                                    })
                                    
                                    alertController.addAction(submitAction)
                                    alertController.addAction(cancelAction)
                                    self.present(alertController, animated: true, completion: nil)
                                    
                                }else {
                                    self.alertViewController(title: "Error", message: "Unfotunatelly post new discussion faild. Please try again later.")
                                }
                            }
                        }
                    }else {
                        self.alertViewController(title: "Error", message: "Uploading image failed. Please try again later.")
                    }
                }
            }
            
        }else {
            self.alertViewController(title: "Error", message: checkFields()!)
        }
        
    }
    
    func checkFields() -> String? {
        if txtName.text == "" {
            return "Please input Post Name."
        }
        if txtDescription.text == "" {
            return "Please input Description."
        }
        if imgPost.image == nil {
            return "Please input Post Picture."
        }
        return ""
    }
    
}

extension NewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//--- Crop image
    func presentCropViewController(_ profileImg : UIImage) {
        let image: UIImage = profileImg
        let  cropViewController = CropViewController(croppingStyle: .default, image: image)
        cropViewController.delegate = self
        self.present(cropViewController, animated: true, completion: nil)
    }
//--- End Crop image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage {
            picker.dismiss(animated:false, completion: nil)
            presentCropViewController(pickedImage)
        }else {
             picker.dismiss(animated:false, completion: nil)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}
//--- Crop image
extension NewPostViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.imgPost.image = image
        cropViewController.dismiss(animated: false, completion: nil)
    }

    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.imgPost.image = image
        cropViewController.dismiss(animated: true, completion: nil)
    }
}
//--- End Crop image
