//
//  HomeViewController.swift
//  PACC
//
//  Created by RSS on 7/4/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import PassKit
import Stripe

class HomeViewController: BaseViewController {

    @IBOutlet weak var scrHome: UIScrollView!
    @IBOutlet weak var txtSearch: SearchTextField!
    @IBOutlet weak var btnMenu: UIButton!
    var tableData: [Any] = []
    var businesses: [User]?
    var home_operation_queue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllUserItems()
        initView()
    }
    
    func initView() {
       // self.setupMenuBarButton()
        // Configure a custom search text field
        btnMenu.setButtonShadow()
        configureCustomSearchTextField()
        
        if User.sharedInstance.logged_in == nil || !User.sharedInstance.logged_in! {
            self.showHUD()
            API.sharedInstance.login(User.sharedInstance.email!, User.sharedInstance.password!) { (errMsg) in
                self.hideHUD()
                if errMsg == nil {
                    self.getProducts()
                    if User.sharedInstance.isPatient! {
                        API.sharedInstance.getPaccPositions(completion: { (positions) in
                            if positions != nil {
                                self.appDelegate.positions = positions!
                            }
                        })
                    }
                }else {
                    self.alertViewController(title: "Error", message: errMsg!)
                }
            }
        }else {
            self.getProducts()
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
                        businesses in
                        
                        // Stop loading indicator
                        self.txtSearch.stopLoadingIndicator()
                        DispatchQueue.main.async {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchResultVC") as! SearchResultViewController
                            vc.businesses = businesses!
                            vc.fromMessageView = false
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }
        } as (() -> Void)
    }
    fileprivate func getAllUserItems(){
        API.sharedInstance.getAllItems("Business") { (businesses) in
            if businesses != nil {
                for user in businesses! {
                    let business = user as! User
                }
            }
            API.sharedInstance.getAllItems("User"){ (users) in
                if users != nil {
                    for user in users! {
                        let cur_user = user as! User
                        }
                    }
                }
        }
    }
    fileprivate func filterAcronymInBackground(_ criteria: String, callback: @escaping (_ results: [User]?) -> Void) {
        
        API.sharedInstance.getAllItems("Business") { (businesses) in
            var all_users: [User] = []
            if businesses != nil {
                for user in businesses! {
                    let business = user as! User
                    if business.name?.range(of: criteria, options: .caseInsensitive) != nil {
                        all_users.append(business)
                    }
                }
            }
            API.sharedInstance.getAllItems("User", completion: { (users) in
                if users != nil {
                    for user in users! {
                        let cur_user = user as! User
                        if cur_user.name?.range(of: criteria, options: .caseInsensitive) != nil {
                            all_users.append(cur_user)
                        }
                    }
                }
                callback(all_users)
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(notifyreload), name:NSNotification.Name("userBlocked") , object: nil)
    }
    @objc func notifyreload() {
        
      // getProducts()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name("userBlocked"), object: nil)
    }
    @IBAction func btnActionSideMenu(_ sender: UIButton) {
         sideMenuController?.showLeftView(animated: true, completionHandler: nil)
    }
    
    func getProducts() {
        self.showHUD()
        tableData.removeAll()
        if RealmHelper.sharedInstance.realm.objects(Shop.self).count == 0 {
            API.sharedInstance.getAllItems("Products") { (products) in
                API.sharedInstance.getAllItems("Discussion") { (discussions) in
                    self.getAllBusinesses(discussions, products)
                }
            }
        }else {
            var discussions: [Any] = []
            var products: [Any] = []
            for discussion in RealmHelper.sharedInstance.realm.objects(Discussion.self) {
                discussions.append(discussion)
            }
            for product in RealmHelper.sharedInstance.realm.objects(Shop.self) {
                products.append(product)
            }
            self.getAllBusinesses(discussions, products)
        }
    }
    
    func getAllBusinesses(_ discussions: [Any]?, _ products: [Any]?) {
        API.sharedInstance.get_existing_businesses { (businesses) in
            self.hideHUD()
            self.businesses = businesses
            self.tableData.append(0)
            self.tableData.append(1)
            self.tableData.append(2)
            if discussions != nil {
                for i in 0 ..< discussions!.count {
                    
                    if(UserDefaults.standard.value(forKey: "blockeUsers") != nil){
                        let arrBlockedData = UserDefaults.standard.value(forKey: "blockeUsers") as! NSArray
                       
                        if(arrBlockedData.count != 0 ) {
                            if arrBlockedData.contains((discussions![i] as AnyObject).id!) {
                                print("yes")
                            }else {
                               self.tableData.append(discussions![i])
                            }
                        }else {
                             self.tableData.append(discussions![i])
                        }
                    }else {
                       self.tableData.append(discussions![i])
                    }
                    
                    if i == 1 {
                        break
                    }
                }
            }
            self.tableData.append(3)
            if products != nil {
                for i in 0 ..< products!.count {
                    self.tableData.append(products![i])
                    if i == 1 {
                        break
                    }
                }
            }
            self.reloadData()
        }
    }
    
    func reloadData() {
        
        var item: UIView?
        var origin_y: CGFloat = 0
        var last_item: UIView?
        
        for i in 0 ..< tableData.count {
            if last_item != nil {
                origin_y = last_item!.frame.origin.y + last_item!.frame.size.height
            }
            switch tableData[i] {
            case is Int:
                let data = tableData[i] as! Int
                switch data {
                case 0:
                    let view = UIView(frame: CGRect(x: 0, y: 0, width: self.scrHome.frame.width, height: 230))
                    view.backgroundColor = UIColor.white

                    let map = PaccMap(frame: CGRect(x: 0, y: 0, width: self.scrHome.frame.width , height: 230))
        
                    view.addSubview(map)
                    map.showBusinessesOnMap(self.businesses)
                    item = view
                case 1:
                    let view = UIView(frame: CGRect(x: 0, y: origin_y, width: self.scrHome.frame.width, height: self.scrHome.frame.width * 0.67 / 2))
                    let discussBtn = UIButton(frame: CGRect(x: 0, y: 0, width: self.scrHome.frame.width / 2, height: self.scrHome.frame.width * 0.67 / 2))
                    let discussImage = UIImageView(frame: CGRect(x: 6, y: 0, width: self.scrHome.frame.width / 2 - 9, height: self.scrHome.frame.width * 0.67 / 2))
                    let discussion_label = UILabel(frame: CGRect(x: 20, y: (self.scrHome.frame.width * 0.67 / 2 - 70) / 2 , width: self.scrHome.frame.width / 2 - 40, height: 70))
                    discussion_label.text = "Community Discussion"
                    discussion_label.font = UIFont.boldSystemFont(ofSize: 25)
                    discussion_label.textColor = UIColor.white
                    discussion_label.numberOfLines = 2
                    discussImage.contentMode = .scaleToFill
                    discussImage.image = #imageLiteral(resourceName: "discussion")
                    discussBtn.addTarget(self, action: #selector(self.gotoDiscussion), for: .touchUpInside)
                    let dispensaryBtn = UIButton(frame: CGRect(x: self.scrHome.frame.width / 2, y: 0, width: self.scrHome.frame.width / 2, height: self.scrHome.frame.width * 0.67 / 2))
                    let dispensaryImage = UIImageView(frame: CGRect(x: self.scrHome.frame.width / 2 + 3, y: 0, width: self.scrHome.frame.width / 2 - 9, height: self.scrHome.frame.width * 0.67 / 2))
                    dispensaryImage.contentMode = .scaleToFill
                    dispensaryImage.image = #imageLiteral(resourceName: "dispensary")
                    dispensaryBtn.addTarget(self, action: #selector(self.gotoDispensary), for: .touchUpInside)
                    let dispensary_label = UILabel(frame: CGRect(x: self.scrHome.frame.width / 2 + 20, y: (self.scrHome.frame.width * 0.67 / 2 - 70) / 2 , width: self.scrHome.frame.width / 2 - 20, height: 70))
                    dispensary_label.text = "Dispensary"
                    dispensary_label.font = UIFont.boldSystemFont(ofSize: 25)
                    dispensary_label.textColor = UIColor.white
                    
                    discussImage.setAdRadius()
                    dispensaryImage.setAdRadius()
                    view.addSubview(discussImage)
                    view.addSubview(dispensaryImage)
                    view.addSubview(discussion_label)
                    view.addSubview(dispensary_label)
                    view.addSubview(discussBtn)
                    view.addSubview(dispensaryBtn)
                    item = view
                case 2:
                    let label = UILabel(frame: CGRect(x: 10, y: origin_y, width: self.view.frame.width - 20, height: 60))
                    label.text = "Recent Posts by PACC"
                    label.font = UIFont.boldSystemFont(ofSize: 20)
                    item = label
                case 3:
                    let label = UILabel(frame: CGRect(x: 10, y: origin_y, width: self.view.frame.width - 20, height: 60))
                    label.text = "PACC Merchandise"
                    label.font = UIFont.boldSystemFont(ofSize: 20)
                    item = label
                default:
                    break
                }
                
            case is Shop:
                let cell = ShopCell(frame: CGRect(x: 0, y: origin_y, width: self.scrHome.frame.width, height: 160))
                cell.product = self.tableData[i] as? Shop
                if(cell.tag % 2 == 0) {
                cell.backgroundColor = UIColor.white
                } else{
                cell.backgroundColor = UIColor.blue
                }
                home_operation_queue.addOperation(ShopCellOperation(cell))
                cell.delegate = self
                item = cell
            case is Discussion:
                let cell = DiscussionCell(frame: CGRect(x: 0, y: origin_y, width: self.scrHome.frame.width, height: 350))
                cell.discussion = self.tableData[i] as? Discussion
                home_operation_queue.addOperation(DiscussionCellOperation(cell))
                    item = cell
            default:
                break
            }
            
            last_item = item
            self.scrHome.addSubview(item!)
            self.scrHome.contentSize = CGSize(width: 0, height: item!.frame.origin.y + item!.frame.size.height)
        }
    }
    
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gotoExplore() {
        appDelegate.makingRoot("Explore")
    }
    
    @objc func gotoDiscussion() {
        appDelegate.makingRoot("Discussion")
    }
    
    @objc func gotoDispensary() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "BusinessFeedVC") as! BusinessFeedViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension HomeViewController: ShopItemDelegate {
    
    func buyShopItem(_ cell: ShopCell) {
        if User.sharedInstance.is_premium != nil && User.sharedInstance.is_premium! {
            self.createToken("PACC Buy \(cell.shopCategory!.text!)", cell.shopPrice.text!)
        }else {
            self.createToken("PACC Upgrade", "20.0")
        }
    }
    
    
}
