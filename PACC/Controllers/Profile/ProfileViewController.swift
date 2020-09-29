//
//  ProfileViewController.swift
//  PACC
//
//  Created by RSS on 4/18/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import DropDown
import MessageUI
import Cosmos
import LGSideMenuController

class ProfileViewController: BaseViewController {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var txtBio: UITextView!
    @IBOutlet weak var lblBusinessType: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnFollows: UIButton!
    @IBOutlet weak var lblHours: UILabel!
    @IBOutlet weak var prefersView: PrefersView!
    @IBOutlet weak var premiumImg: UIImageView!
    @IBOutlet weak var btnNewPosition: UIButton!
    @IBOutlet weak var personalRating: CosmosView!
    @IBOutlet weak var scrContent: UIScrollView!
    @IBOutlet weak var btnEditProfile: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet var buttons: [UIButton]!
    var sender_email: String?
    var pacc_positions: [String] = []
    var prevButton: Int = 100
    let positionDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.positionDropDown
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.setupMenuBarButton()
        self.initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionConnection(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ConnectionsVC") as! ConnectionsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onEditProfileClick(_ sender: Any) {
        let editProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileViewController
        editProfileVC.transitioningDelegate = self
        transitionNav(to: editProfileVC)
    }
    
    @IBAction func onBackClick(_ sender: Any) {
        self.appDelegate.makingRoot("enterApp")
    }
    
    @IBAction func actionSwitchView(_ sender: UIButton) {
        buttons[prevButton - 100].removeBottomLine()
        sender.drawBottomLine()
        prevButton = sender.tag
        initHeaderView(prevButton - 100)
    }
    
    @IBAction func btnActionSidemenu(_ sender: UIButton) {
        sideMenuController?.showLeftView(animated: true, completionHandler: nil)
    }
    
    @IBAction func actionPosition(_ sender: UIButton) {
        if !User.sharedInstance.isPatient! && User.sharedInstance.profileimg != nil && User.sharedInstance.profileimg! != ""{
            let alertController = UIAlertController(title: "Add new position", message: "Please input new position name.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (action : UIAlertAction!) -> Void in
            })
            
            let submitAction = UIAlertAction(title: "Create", style: .default, handler: {
                alert -> Void in
                let textField = alertController.textFields![0] as UITextField
                let param: NSDictionary = [
                    "creater": User.sharedInstance.id!,
                    "name": textField.text!
                ]
                API.sharedInstance.insertItem("PaccPosition", param, completion: { (dic) in
                    
                })
            })
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Position Name"
                textField.borderStyle = .roundedRect
            }
            
            alertController.addAction(submitAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            
            for field in alertController.textFields! as [UITextField] {
                field.superview?.superview?.layer.borderWidth = 2
                field.superview?.superview?.layer.borderColor = UIColor.clear.cgColor
                field.delegate = self
            }
        }else {
            self.view.endEditing(true)
            if self.appDelegate.positions.count == 0 {
                self.alertViewController(title: "Error", message: "There are no Positions yet...")
            }else {
                positionDropDown.show()
            }
        }
    }
    
    func initHeaderView(_ type: Int) {
        if type == 0 {
            prefersView.isFirstTab = true
            prefersView.initView()
        }else {
            prefersView.isFirstTab = false
            prefersView.initView()
        }
        if !User.sharedInstance.isPatient! {
           buttons[0].setTitle("Linked Employees", for: .normal)
           buttons[1].setTitle("Recents", for: .normal)
        }else{
           buttons[0].setTitle("Preferred Businesses", for: .normal)
           buttons[1].setTitle("Likes", for: .normal)
        }
    }
    
    func initView() {
        
        personalRating.isUserInteractionEnabled = false
        
        actionSwitchView(buttons[prevButton - 100])
        btnEditProfile.initLetterButtonUI(radius: 4)
        btnEditProfile.setButtonShadow()
        btnBack.setButtonShadow()

        prefersView.isFirstTab = true
        prefersView.initView()
        // Show User Profile Infor
        lblName.text = User.sharedInstance.name
        lblLocation.text = User.sharedInstance.location
        txtBio.text = User.sharedInstance.bio
        lblHours.alpha = 0.0
        if !User.sharedInstance.isPatient! {
            lblHours.alpha = 1.0
            lblBusinessType.text = User.sharedInstance.business_type
            lblHours.text = "\(User.sharedInstance.from ?? "00:00") : \(User.sharedInstance.to ?? "00:00")"
            if User.sharedInstance.is_premium == nil || !User.sharedInstance.is_premium! {
                self.btnNewPosition.alpha = 0.0
            }
        }else {
            self.btnNewPosition.setTitle("Select a Position", for: .normal)
        }
        if User.sharedInstance.profileimg != nil && User.sharedInstance.profileimg! != "" {
            self.profileImg.loadImageWithoutIndicator(urlString: User.sharedInstance.profileimg!)
        }
        if User.sharedInstance.is_premium != nil && User.sharedInstance.is_premium! {
            premiumImg.alpha = 1.0
        }
        
        if User.sharedInstance.isPatient! {
            self.pacc_positions.removeAll()
            for pos in appDelegate.positions {
                self.pacc_positions.append(pos.name!)
            }
            
            customizeDropDown(self)
            positionDropDown.anchorView = btnNewPosition
            positionDropDown.bottomOffset = CGPoint(x: 0, y: btnNewPosition.bounds.height)
            // You can also use localizationKeysDataSource instead. Check the docs.
            positionDropDown.dataSource = pacc_positions
            
            // Action triggered on selection
            positionDropDown.selectionAction = { [unowned self] (index, item) in
                self.showHUD()
                API.sharedInstance.getItemInfor("Business", self.appDelegate.positions[index].creater!, completion: { (business_dic) in
                    DispatchQueue.main.async {
                        self.hideHUD()
                        let business = User()
                        if business_dic != nil {
                            business.loadUserInfo(business_dic!)
                            self.sender_email = business.email
                            let mailComposeViewController = self.configuredMailComposeViewController()
                            if MFMailComposeViewController.canSendMail() {
                                self.present(mailComposeViewController, animated: true, completion: nil)
                            } else {
                                self.showSendMailErrorAlert()
                            }
                        }
                    }
                })
            }
        }
        
        API.sharedInstance.getAllItems("Rating") { (ratings) in
            DispatchQueue.main.async {
                if ratings != nil {
                    let rating_arr = ratings as! [Rating]
                    var rating: Double = 0
                    var count: Int = 0
                    for rating_instance in rating_arr {
                        if rating_instance.receiver == User.sharedInstance.id {
                            rating += rating_instance.rating!
                            count += 1
                        }
                        
                    }
                    self.personalRating.rating = count > 0 ? rating / Double(count) : 0
                }
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
}

extension ProfileViewController: MFMailComposeViewControllerDelegate, UITextFieldDelegate {
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([self.sender_email!])
        mailComposerVC.setSubject("Send A Position")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

