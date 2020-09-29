//
//  LeftViewController.swift
//  PACC
//
//  Created by RSS on 7/2/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import LGSideMenuController
import DropDown

class LeftViewController: UIViewController {

    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var lblName: UILabel!
//    @IBOutlet weak var btnDropDown: UIButton!
    @IBOutlet weak var premiumImg: UIImageView!
    
//    let settingDropDown = DropDown()
//    lazy var dropDowns: [DropDown] = {
//        return [
//            self.settingDropDown
//        ]
//    }()
    
    var arrTitle = ["Home","Shop","Discussions","Messages", "Explore", "Profile","Log out"]
    var arrImages = [ #imageLiteral(resourceName: "ic_Home") ,#imageLiteral(resourceName: "ic_shop") , #imageLiteral(resourceName: "ic_discussion'") , #imageLiteral(resourceName: "ic_Massage") ,  #imageLiteral(resourceName: "ic_explore") , #imageLiteral(resourceName: "ic_profile"), #imageLiteral(resourceName: "Log out.png") ]

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Show User Profile Infor
//        User.sharedInstance.loadUserInfo(UserDefaults.standard.object(forKey: "User.sharedInstance.loadUserInfo") as! NSDictionary)
        lblName.text = User.sharedInstance.name
        if User.sharedInstance.profileimg != nil && User.sharedInstance.profileimg! != "" {
            ImageLoader.sharedLoader.imageForUrl(urlString: User.sharedInstance.profileimg!) { (image, url) in
                DispatchQueue.main.async {
                    self.btnProfile.setImage(image, for: .normal)
                }
            }
        }
        if User.sharedInstance.is_premium != nil && User.sharedInstance.is_premium! {
            premiumImg.alpha = 1.0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnProfileAction(_ sender: Any) {
        let LGSideMenu: LGSideMenuController? = (parent as? LGSideMenuController)
        let obj: ProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileVC") as! ProfileViewController
        
        let navController = UINavigationController(rootViewController: obj)
        LGSideMenu?.rootViewController = navController
        LGSideMenu?.hideLeftView(animated: true, completionHandler: nil)
    }
    func initView() {

    }
//    func customizeDropDown(_ sender: AnyObject) {
//        DropDown.setupDefaultAppearance()
//
//        dropDowns.forEach {
//            $0.cellNib = UINib(nibName: "DropDownCell", bundle: Bundle(for: DropDownCell.self))
//            $0.cellHeight = 35
//            $0.customCellConfiguration = nil
//        }
//    }
    
//    @IBAction func actionClickDropmenu(_ sender: UIButton) {
//        self.view.endEditing(true)
//        settingDropDown.show()
//    }


}

extension LeftViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SidemenuTC", for: indexPath) as! SidemenuTC
        cell.lblTitle.text = arrTitle[indexPath.row]
        cell.imgMenu.image = arrImages[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let LGSideMenu: LGSideMenuController? = (parent as? LGSideMenuController)
        if(indexPath.row == 0){
            
            let obj: HomeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
            
            let navController = UINavigationController(rootViewController: obj)
            LGSideMenu?.rootViewController = navController
            LGSideMenu?.hideLeftView(animated: true, completionHandler: nil)
        }
        else if (indexPath.row == 1){
            
            let obj: ShopViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShopVC") as! ShopViewController
            
            let navController = UINavigationController(rootViewController: obj)
            LGSideMenu?.rootViewController = navController
            LGSideMenu?.hideLeftView(animated: true, completionHandler: nil)
        }
        else if (indexPath.row == 2){
            let obj: DiscussionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DiscussionVC") as! DiscussionViewController
            
            let navController = UINavigationController(rootViewController: obj)
            LGSideMenu?.rootViewController = navController
            LGSideMenu?.hideLeftView(animated: true, completionHandler: nil)
        }
        else if (indexPath.row == 3){
            let obj: MessageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessageVC") as! MessageViewController
            
            let navController = UINavigationController(rootViewController: obj)
            LGSideMenu?.rootViewController = navController
            LGSideMenu?.hideLeftView(animated: true, completionHandler: nil)
        }
        else if (indexPath.row == 4){
            let obj: ExploreViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ExploreVC") as! ExploreViewController
            
            let navController = UINavigationController(rootViewController: obj)
            LGSideMenu?.rootViewController = navController
            LGSideMenu?.hideLeftView(animated: true, completionHandler: nil)
        }
        else if (indexPath.row == 5){
            let obj: ProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileVC") as! ProfileViewController
            
            let navController = UINavigationController(rootViewController: obj)
            LGSideMenu?.rootViewController = navController
            LGSideMenu?.hideLeftView(animated: true, completionHandler: nil)
        }
        else if (indexPath.row == 6){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                          appDelegate.deleteUser()
                          User.sharedInstance.initialize()
                          appDelegate.makingRoot("initial")
            LGSideMenu?.hideLeftView(animated: true, completionHandler: nil)
        }
    }
}
