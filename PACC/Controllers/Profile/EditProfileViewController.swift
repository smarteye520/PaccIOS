//
//  EditProfileViewController.swift
//  PACC
//
//  Created by RSS on 4/24/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import PassKit
import Stripe
import Cosmos
import CropViewController

class EditProfileViewController: BaseViewController {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var locationView: LocationView!
    @IBOutlet weak var txtBio: UITextView!
    @IBOutlet weak var phoneView: PhoneView!
    @IBOutlet weak var dobView: DobView!
    @IBOutlet weak var lblDB: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var businessView: UIView!
    @IBOutlet weak var lblBusinessType: UILabel!
    @IBOutlet weak var btView: UIView!
    @IBOutlet weak var businessTbl: UITableView!
    @IBOutlet weak var btnUpgrade: UIButton!
    @IBOutlet weak var btnChangePhoto: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var premiumImg: UIImageView!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var personalRating: CosmosView!
    @IBOutlet weak var submitRating: CosmosView!
    @IBOutlet weak var btnSubmitRating: UIButton!
    @IBOutlet weak var btnSendPost: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    var user: User?
    
    var existing_business: [User]?
    var businessType: [String] = ["Business Type", "Dispensary", "Grower/processor", "Physician", "Attorney", "Contractors", "Electricians", "Grow room design ", "Security", "Payroll", "Marketing", "Real estate", "Storefront", "Media/photography/videography", "Existing Businesses"]
    
    let add_discussion_queue = OperationQueue()
    var operations: [DiscussionCellOperation] = []
    
    var item: DiscussionCell?
    var last_item: DiscussionCell?
    var offset_y: CGFloat = 525
    var discussion_arr: [Discussion] = []
    var isfROMsIDEmenu = false
    var imagePicker = UIImagePickerController()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        imagePicker.delegate = self
    }
    
    func initView() {
        
        btnUpgrade.initLetterButtonUI(radius: 10)
        btnUpgrade.setButtonShadow()
        btnBack.setButtonShadow()
        self.personalRating.rating = 0
        self.btnSubmitRating.alpha = 0.0
        
      //  scrView.contentSize = CGSize(width: self.view.frame.width, height: 530)
        locationView.vc = self
        businessView.alpha = 0.0
        businessView.layer.cornerRadius = 8
        businessView.layer.borderColor = AppTheme.light_green.cgColor
        businessView.clipsToBounds = true
        businessView.layer.borderWidth = 1
        user?.isPatient = user?.isPatient ?? false
        if user == nil {
            user = User.sharedInstance
            btnSendPost.alpha = 0.0
            btnUpgrade.alpha = 1.0
        }else{
            if user?.isPatient == true {
                btnSendPost.alpha = 0.0
            }else{
                btnSendPost.alpha = 1.0
            }
            btnUpgrade.alpha = 0.0
        }
        
        
        self.showHUD()
        API.sharedInstance.getAllItems("Rating") { (ratings) in
            DispatchQueue.main.async {
                self.hideHUD()
                if ratings != nil {
                    let rating_arr = ratings as! [Rating]
                    var is_exist: Bool = false
                    var rating: Double = 0
                    var count: Int = 0
                    for rating_instance in rating_arr {
                        if rating_instance.receiver == self.user?.id {
                            rating += rating_instance.rating!
                            count += 1
                            if rating_instance.sender == User.sharedInstance.id {
                                is_exist = true
                            }
                        }
                        
                    }
                    self.personalRating.rating = count > 0 ? rating / Double(count) : 0
                    if !is_exist && User.sharedInstance.id != self.user?.id {
                        
                        self.btnSubmitRating.alpha = 1.0
                    }
                }else {
                    if User.sharedInstance.id != self.user?.id  {
                        self.btnSubmitRating.alpha = 1.0
                    }
                }
                if self.user?.id != User.sharedInstance.id {
                    self.showPosts()
                }
            }
        }
        
        txtName.text = self.user?.name
        locationView.txtLocation.text = self.user?.location
        locationView.lat = self.user!.lat!
        locationView.long = self.user!.long!
        txtBio.text = self.user?.bio
        phoneView.txtPhone.text = self.user?.phonenum
        
        if self.user!.isPatient! {
            dobView.alpha = 1.0
            btView.alpha = 0.0
            dobView.txtDOB.text = self.user?.dob
        }else {
            dobView.alpha = 0.0
            btView.alpha = 1.0
           // lblDB.text = "Business Type"
            lblDB.text = "Type"
            lblBusinessType.text = self.user?.business_type
        }
        
        if self.user?.profileimg != nil && self.user?.profileimg != "" {
            self.profileImg.loadImageWithoutIndicator(urlString: self.user!.profileimg!)
        }
        
        if self.user?.is_premium != nil && self.user!.is_premium! {
            btnUpgrade.isHidden = true
            premiumImg.alpha = 1.0
        }else {
            btnUpgrade.isHidden = false
            premiumImg.alpha = 0.0
        }
        
        
        if self.user?.id != User.sharedInstance.id {
            self.personalRating.isUserInteractionEnabled = true
            btnUpgrade.isHidden = true
            txtName.isUserInteractionEnabled = false
            txtBio.isUserInteractionEnabled = false
            locationView.txtLocation.isUserInteractionEnabled = false
            phoneView.txtPhone.isUserInteractionEnabled = false
            dobView.txtDOB.isUserInteractionEnabled = false
            btnChangePhoto.isHidden = true
            btnDone.isHidden = true
        }else{
            self.personalRating.isUserInteractionEnabled = false
        }
        
      btnUpgrade.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBackClick(_ sender: Any) {
        if self.navigationController != nil {
          transitionDissmiss()
        }else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func actionDone(_ sender: UIButton) {
        self.user?.name = txtName.text
        self.user?.long = locationView.long
        self.user?.lat = locationView.lat
        self.user?.location = locationView.txtLocation.text
        self.user?.phonenum = phoneView.txtPhone.text
        self.user?.bio = txtBio.text
        self.user?.dob = dobView.txtDOB.text
        self.user?.business_type = lblBusinessType.text
        
        self.showHUD()
        
        API.sharedInstance.uploadImage(profileImg.image!) { (imageURL) in
            self.user?.profileimg = imageURL
            var collection: String = ""
            if self.user!.isPatient! {
                collection = "User"
            }else {
                collection = "Business"
            }
            API.sharedInstance.updateItem(collection, self.user!.getDic(), completion: { (success) in
                if success! {
                    DispatchQueue.main.async {
                        self.hideHUD()
                        if self.navigationController != nil {
                            self.transitionDissmiss()
                        }else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func actionChooseBusiness(_ sender: UIButton) {
        
        if user?.id == User.sharedInstance.id {
            if existing_business == nil {
                self.showHUD()
                API.sharedInstance.get_existing_businesses { (users) in
                    DispatchQueue.main.async {
                        self.hideHUD()
                        self.existing_business = users
                        for user in users! {
                            self.businessType.append(user.name!)
                        }
                        self.businessTbl.reloadData()
                        self.openBusinessView()
                    }
                }
            }else {
                self.openBusinessView()
            }
        }
        
    }
    
    func showPosts() {
        self.showHUD()
        API.sharedInstance.getAllItems("Discussion") { (discussions) in
            self.hideHUD()
            self.discussion_arr.removeAll()
            if discussions != nil && discussions?.count != 0 {
                for discussion in discussions as! [Discussion] {
                    if discussion.receiver == self.user?.id {
                        self.discussion_arr.append(discussion)
                    }
                }
                for i in 0 ..< self.discussion_arr.count {
                    self.addDiscussionItem(i)
                }
            }
        }
    }
    
    func addDiscussionItem(_ cnt: Int) {
        if last_item != nil {
            offset_y = last_item!.frame.origin.y + last_item!.frame.height
        }
        item?.discussion = discussion_arr[cnt]
        last_item = item
        if(item != nil) {
            operations.append(DiscussionCellOperation(item!))
            if cnt > 0 {
                operations[cnt].addDependency(operations[cnt - 1])
            }
            add_discussion_queue.addOperation(operations[cnt])
        }
    }
    
    func openBusinessView() {
        self.businessView.alpha = 1.0
        self.businessView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            
            self.businessView.transform = CGAffineTransform(translationX: 0, y: 0)
            self.view.layoutIfNeeded()
            
        }, completion: { (finished: Bool) in
            // something
        })
    }
    
    func closeBusinessView() {
        self.businessView.alpha = 1.0
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            
            self.businessView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
            self.view.layoutIfNeeded()
            
        }, completion: { (finished: Bool) in
            self.businessView.alpha = 0.0
        })
    }
    
    @IBAction func onPhoto(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        // Add the actions
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
    
    @IBAction func actionUpgrade(_ sender: UIButton) {
        self.createToken("PACC Upgrade", "20.0")
    }
    
    @IBAction func actionSendPost(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewPostVC") as! NewPostViewController
        if self.user?.id != User.sharedInstance.id {
            vc.user = self.user
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionViewRating(_ sender: UIButton) {
        self.ratingView.fadeIn { (success) in
        }
    }
    
    @IBAction func actionSubmitRating(_ sender: UIButton) {
        let param: NSDictionary = [
            "sender": User.sharedInstance.id!,
            "receiver": user!.id!,
            "rating": submitRating.rating
        ]
        API.sharedInstance.insertItem("Rating", param) { (rating_dic) in
            
        }
        ratingView.fadeOut { (success) in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    @IBAction func btnActionSidemenu(_ sender: UIButton) {
        if(isfROMsIDEmenu){
             self.dismiss(animated: true, completion: nil)
        }
        else {
              sideMenuController?.showLeftView(animated: true, completionHandler: nil)
        }
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//--- Crop image
    func presentCropViewController(_ profileImg : UIImage) {
        let image: UIImage = profileImg
        let cropViewController = CropViewController(croppingStyle: .circular, image: image)
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
extension EditProfileViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.profileImg.image = image
        cropViewController.dismiss(animated: false, completion: nil)
    }
}
//--- End Crop image
extension EditProfileViewController: UITableViewDelegate, UITableViewDataSource, ItemCellDelegate {
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
        lblBusinessType.text = cell.lblBusiness.text
        let indexPath = businessTbl.indexPath(for: cell)
        if indexPath!.row > 14 {
            self.user?.linked_business = existing_business![indexPath!.row - 15].id
        }
        self.closeBusinessView()
    }
}

