//
//  DescribeViewController.swift
//  PACC
//
//  Created by RSS on 4/18/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import CropViewController
class DescribeViewController: BaseViewController {
    
    @IBOutlet weak var locationView: LocationView!
    @IBOutlet weak var txtBio: UITextView!
    @IBOutlet weak var profileImg: UIImageView!
    var imagePicker = UIImagePickerController()
    var tempImmage = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()

        locationView.vc = self
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnActionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionCreateAccount(_ sender: UIButton) {
        self.view.endEditing(true)
        checkFields()
        
        User.sharedInstance.bio = txtBio.text
        User.sharedInstance.location = locationView.txtLocation.text
        User.sharedInstance.lat = locationView.lat
        User.sharedInstance.long = locationView.long
        
        self.showHUD()
        //FIREBASE FUNCTION
        API.sharedInstance.uploadImage(profileImg.image!) { (imageURL) in
            
            User.sharedInstance.profileimg = imageURL
            
            //API FUNCTION
            API.sharedInstance.register { (errMsg) in
                DispatchQueue.main.async {
                    self.hideHUD()
                    if errMsg == nil {
                        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.makingRoot("enterApp")
                        
                    }else {
                        self.alertViewController(title: "Error", message: errMsg!)
                    }
                }
                
            }
        }
    }
    
    @IBAction func onPhoto(_ sender: UIButton) {
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
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .custom
            present(imagePicker, animated: true, completion: nil)
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
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }else{
            let alert  = UIAlertController(title: "Warning", message: "Photo Library is not available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkFields() {
        if locationView.txtLocation.text == "" {
            self.alertViewController(title: "Error", message: "Please input your location.")
            return
        }
    }
}


extension DescribeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//--- Crop image
    func presentCropViewController(_ profileImg : UIImage) {
        let image: UIImage = profileImg
        let cropViewController = CropViewController(croppingStyle: .circular, image: image)
        cropViewController.delegate = self
        self.present(cropViewController, animated: true, completion: nil)
    }
//--- End Crop image
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        picker.dismiss(animated: true) {
            self.presentCropViewController(image)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
//--- Crop image
extension DescribeViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.profileImg.image = image
        cropViewController.dismiss(animated: false, completion: nil)
    }
}
//--- End Crop image
