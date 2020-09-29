//
//  SignInViewController.swift
//  PACC
//
//  Created by RSS on 4/18/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

class SignInViewController: BaseViewController {
    
    @IBOutlet weak var lblpatient: UILabel!
    @IBOutlet weak var lblbusiness: UILabel!
    @IBOutlet weak var viewPatientLine: UIView!
    @IBOutlet weak var viewBusinessLine: UIView!
    
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnSH: UIButton!
    
    var prevType: Int = 100

    override func viewDidLoad() {
        super.viewDidLoad()
       self.hideKeyboardWhenTappedAround() 
       User.sharedInstance.isPatient = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func actionSignIn(_ sender: UIButton) {
        self.view.endEditing(true)
        if verifyFields() == "" {
            self.showHUD()
            API.sharedInstance.login(txtEmail.text!, txtPassword.text!) { (errMsg) in
                DispatchQueue.main.async {
                    self.hideHUD()
                    if errMsg == nil {
                        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.makingRoot("enterApp")
                    }else {
                        self.alertViewController(title: "Erro", message: errMsg!)
                    }
                }
            }
            
        }else {
            self.alertViewController(title: "Error", message: verifyFields())
        }
    }
    
    @IBAction func actionHidden(_ sender: UIButton) {
        txtPassword.isSecureTextEntry = !txtPassword.isSecureTextEntry
        if txtPassword.isSecureTextEntry {
            btnSH.setImage(#imageLiteral(resourceName: "phidden"), for: .normal)
        }else {
            btnSH.setImage(#imageLiteral(resourceName: "pshow"), for: .normal)
        }
    }
    
    @IBAction func actionCreateAccount(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "BasicInfoVC") as! BasicInfoViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
//    @IBAction func actionChooseType(_ sender: UIButton) {
//
//        buttons[prevType - 100].setTitleColor(AppTheme.light_gray, for: .normal)
//        sender.setTitleColor(AppTheme.light_green, for: .normal)
//        if sender.tag == 100 {
//            User.sharedInstance.isPatient = true
//        }else {
//            User.sharedInstance.isPatient = false
//        }
//        prevType = sender.tag
//    }
    
    @IBAction func btnActionSelectType(_ sender: UIButton) {
        
        switch sender.tag {
        case 0: //Patient Clicked / Selected
            lblpatient.textColor = UIColor(hexString: "000000")
            lblbusiness.textColor = UIColor(hexString: "39813E")
            viewPatientLine.backgroundColor = UIColor(hexString: "39813E")
            viewBusinessLine.backgroundColor = UIColor(hexString: "DBE6DF")
            User.sharedInstance.isPatient = true
            break
        case 1: //Business Clicked / Selected
            lblpatient.textColor = UIColor(hexString: "39813E")
            lblbusiness.textColor = UIColor(hexString: "000000")
            viewPatientLine.backgroundColor = UIColor(hexString: "DBE6DF")
            viewBusinessLine.backgroundColor = UIColor(hexString: "39813E")
            User.sharedInstance.isPatient = false
            break
        default:
            break
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
        return ""
    }
}
