//
//  BusinessInfoViewController.swift
//  PACC
//
//  Created by RSS on 4/18/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import SwiftPhoneNumberFormatter

class BusinessInfoViewController: BaseViewController {

    @IBOutlet weak var lblEGDate: UILabel!
    @IBOutlet weak var txtTo: UITextField!
    @IBOutlet weak var txtFrom: UITextField!
    @IBOutlet weak var viewFromTO: UIView!
    @IBOutlet weak var txtContactNo: UITextField!
    @IBOutlet weak var txtDOB: UITextField!
    @IBOutlet weak var txtFullName: UITextField!
    
    
    @IBOutlet weak var txtName1: UITextField!
    @IBOutlet weak var txtName2: UITextField!
    @IBOutlet weak var dobView: DobView!
    @IBOutlet weak var phoneView1: PhoneView!
    @IBOutlet weak var phoneView2: PhoneView!
    @IBOutlet weak var fromTo: FromTo!
    @IBOutlet weak var businessTbl: UITableView!
    @IBOutlet weak var patientScr: UIScrollView!
    @IBOutlet weak var businessScr: UIScrollView!
    @IBOutlet weak var businessView: UIView!
    @IBOutlet weak var lblBusiness: UILabel!
    
    var businessType: [String] = ["Business Type", "Dispensary", "Grower/processor", "Physician", "Attorney", "Contractors", "Electricians", "Grow room design ", "Security", "Payroll", "Marketing", "Real estate", "Storefront", "Media/photography/videography", "Existing Businesses"]
    var existing_business: [User]?
    
    var datePicker = UIDatePicker()
    var timePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timePicker.datePickerMode = .time
        self.txtFrom.inputView = self.timePicker
        self.txtTo.inputView = self.timePicker
        self.hideKeyboardWhenTappedAround()
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnActionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func actionDescribe(_ sender: UIButton) {
        
        checkFields()
        let vc = storyboard?.instantiateViewController(withIdentifier: "DescribeVC") as! DescribeViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionCreateAccont(_ sender: UIButton) {
        
        checkFields()
        
        self.showHUD()
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
    
    func initView() {
//        businessView.alpha = 0.0
//        businessView.layer.cornerRadius = 8
//        businessView.layer.borderColor = AppTheme.light_green.cgColor
//        businessView.clipsToBounds = true
//        businessView.layer.borderWidth = 1
//
//        businessTbl.allowsSelection = false
//        businessTbl.separatorStyle = .none
        
        if User.sharedInstance.isPatient! {
//            patientScr.alpha = 1.0
//            businessScr.alpha = 0.0
            self.txtDOB.placeholder = "Date Of Birth"
            self.datePicker.datePickerMode = .date
            self.txtDOB.inputView = self.datePicker
            self.viewFromTO.isHidden = true
        }else {
//            patientScr.alpha = 0.0
//            businessScr.alpha = 1.0
            self.txtDOB.placeholder = "Choose Business Type"
            self.viewFromTO.isHidden = false
            self.lblEGDate.isHidden = true
        }
    }
    
    func checkFields() {
        
        if User.sharedInstance.isPatient! {
            
            if self.txtFullName.text!.trimmingCharacters(in: .whitespaces) == "" {
                self.alertViewController(title: "Error", message: "Please input Name")
                return
            }
            else if self.txtDOB.text!.trimmingCharacters(in: .whitespaces) == "" {
                self.alertViewController(title: "Error", message: "Please input Date Of Birth")
                return
            }
            else if self.txtContactNo.text!.trimmingCharacters(in: .whitespaces) == "" {
                self.alertViewController(title: "Error", message: "Please input Contact Number")
                return
            }
          
        }else {
         
            if self.txtFullName.text!.trimmingCharacters(in: .whitespaces) == "" {
                self.alertViewController(title: "Error", message: "Please input Name")
                return
            }
            else if self.txtDOB.text!.trimmingCharacters(in: .whitespaces) == "" {
                self.alertViewController(title: "Error", message: "Please Select Bussiness Type")
                return
            }
            else if self.txtContactNo.text!.trimmingCharacters(in: .whitespaces) == "" {
                self.alertViewController(title: "Error", message: "Please input Contact Number")
                return
            }
            else if self.txtFrom.text!.trimmingCharacters(in: .whitespaces) == "" {
                self.alertViewController(title: "Error", message: "Please Select From Time")
                return
            }
            else if self.txtTo.text!.trimmingCharacters(in: .whitespaces) == "" {
                self.alertViewController(title: "Error", message: "Please Select To TIme")
                return
            }
        }
        
        
        if User.sharedInstance.isPatient! {
            User.sharedInstance.name = self.txtFullName.text
            User.sharedInstance.phonenum = self.txtContactNo.text
            User.sharedInstance.dob = self.txtDOB.text
        }else {
            User.sharedInstance.name = self.txtFullName.text
            User.sharedInstance.phonenum = self.txtContactNo.text
            User.sharedInstance.business_type = self.txtDOB.text
            User.sharedInstance.from = self.txtFrom.text
            User.sharedInstance.to = self.txtTo.text
        }
    }
    
//    @IBAction func actionChooseBusiness(_ sender: UIButton) {
//
//        if existing_business == nil {
//            self.showHUD()
//            API.sharedInstance.get_existing_businesses { (users) in
//                DispatchQueue.main.async {
//                    self.hideHUD()
//                    self.existing_business = users
//                    for user in users! {
//                        self.businessType.append(user.name!)
//                    }
//                    self.businessTbl.reloadData()
//                    self.openBusinessView()
//                }
//            }
//        }else {
//            self.openBusinessView()
//        }
//    }
    
    func getBussinessType(){
        self.showHUD()
        API.sharedInstance.get_existing_businesses { (users) in
            DispatchQueue.main.async {
                self.hideHUD()
                self.existing_business = users
                if let userList = users {
                    for user in userList {
                        self.businessType.append(user.name!)
                    }
                }
                self.businessTbl.reloadData()
                self.openBusinessView()
            }
        }
    }
    
    func openBusinessView() {
        //self.businessView.alpha = 1.0
        self.view.endEditing(true)
        self.businessView.isHidden = false
        self.businessView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            
            self.businessView.transform = CGAffineTransform(translationX: 0, y: 0)
            self.view.layoutIfNeeded()
            
        }, completion: { (finished: Bool) in
            // something
        })
    }
    
    func closeBusinessView() {
        //self.businessView.alpha = 1.0
        self.businessView.isHidden = true
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            self.businessView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
            self.view.layoutIfNeeded()
            
        }, completion: { (finished: Bool) in
            
        })
    }
    
}
extension BusinessInfoViewController: UITextFieldDelegate{
    //MARK: TEXTFIELD DELEGATE METHOD
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if User.sharedInstance.isPatient! {
            if(textField == self.txtDOB){
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "23-MMM-yyyy"
                self.txtDOB.text = dateformatter.string(from: self.datePicker.date)
            }
        }else {
     
            if(textField == self.txtDOB){
            }
            else if(textField == self.txtFrom){
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "HH:mm"
                self.txtFrom.text = dateformatter.string(from: self.timePicker.date)
            }
            else if(textField == self.txtTo){
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "HH:mm"
                self.txtTo.text = dateformatter.string(from: self.timePicker.date)
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if User.sharedInstance.isPatient! {
            
        }else{
            
            if(textField == self.txtDOB){
                self.getBussinessType()
            }else{
                self.closeBusinessView()
            }
            
        }
    }
}
extension BusinessInfoViewController: UITableViewDelegate, UITableViewDataSource, ItemCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessType.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 || indexPath.row == 14 {
            let cell = businessTbl.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! TitleCell
            cell.lblTitle.text = businessType[indexPath.row]
            return cell
        }else {
            let cell = businessTbl.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemCell
            cell.lblBusiness.text = businessType[indexPath.row]
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func onSelect(_ cell: ItemCell) {
        txtDOB.text = cell.lblBusiness.text
        let indexPath = businessTbl.indexPath(for: cell)
        if indexPath!.row > 14 {
            User.sharedInstance.linked_business = existing_business![indexPath!.row - 15].id
        }
        self.closeBusinessView()
    }
}

class TitleCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
}

protocol ItemCellDelegate {
    func onSelect(_ cell: ItemCell)
}

class ItemCell: UITableViewCell {
    
    @IBOutlet weak var lblBusiness: UILabel!
    var delegate: ItemCellDelegate?
    
    @IBAction func actionSelect(_ sender: UIButton) {
        delegate?.onSelect(self)
    }
}
