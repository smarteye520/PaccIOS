//
//  BasicInfoViewController.swift
//  PACC
//
//  Created by RSS on 4/18/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import DLRadioButton

class BasicInfoViewController: BaseViewController {

    @IBOutlet weak var btnPatient : UIButton!
    @IBOutlet weak var imgPaient: UIImageView!
    @IBOutlet weak var imgBusiness: UIImageView!
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPWD: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        btnPatient.isSelected  = true
    }
    
    @IBAction func btnActionPatientClicked(_ sender: UIButton) {
        imgPaient.image = #imageLiteral(resourceName: "ic_checked")
        imgBusiness.image = #imageLiteral(resourceName: "ic_unchecked")
        btnPatient.isSelected  = true
    }
    
    @IBAction func btnActionBusinessClicked(_ sender: UIButton) {
        imgBusiness.image = #imageLiteral(resourceName: "ic_checked")
        imgPaient.image = #imageLiteral(resourceName: "ic_unchecked")
        btnPatient.isSelected  = false
    }
    
    @IBAction func btnActionBack(_ sender: UIButton) {
    self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnPasswordVisible(_ sender: UIButton) {
        if(sender.tag == 0){ //FOR PASSWORD
            if(!sender.isSelected){
                sender.isSelected = true
                txtPassword.isSecureTextEntry = false
            }else {
                sender.isSelected = false
                txtPassword.isSecureTextEntry = true
            }
        }else {
            if(!sender.isSelected){ //FOR CONFIRM PASSWORD
                sender.isSelected = true
                txtConfirmPWD.isSecureTextEntry = false
            }else {
                sender.isSelected = false
                txtConfirmPWD.isSecureTextEntry = true
            }
        }
    }
    
    @IBAction func actionNext(_ sender: UIButton) {
        
        if verifyFields() == "" {
            
            User.sharedInstance.email = txtEmail.text
            User.sharedInstance.password = txtPassword.text
            
            if btnPatient.isSelected {
                User.sharedInstance.isPatient = true
            }else {
                User.sharedInstance.isPatient = false
            }
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "BusinessInfoVC") as! BusinessInfoViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            self.alertViewController(title: "Error", message: verifyFields())
        }
        
    }
    
    
    func verifyFields() -> String {
        
        if txtEmail.text == "" {
            return "Please input Email."
        }
        
        if txtPassword.text == "" {
            return "Please input Password."
        }
        
        if !txtEmail.isValidEmail() {
            return "Please input correct email address."
        }
        if txtPassword.text!.count < 6 {
            return "Password length must have 6 characters or more. Please input correctly."
        }
        if txtPassword.text != txtConfirmPWD.text {
            return "Password does not match. Please input correct password."
        }
        return ""
    }

}
