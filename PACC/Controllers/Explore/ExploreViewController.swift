//
//  ExploreViewController.swift
//  PACC
//
//  Created by RSS on 5/27/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import DropDown
import GoogleMaps

class ExploreViewController: BaseViewController {

    @IBOutlet weak var paccMap: PaccMap!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var dropDownImg: UIImageView!
    @IBOutlet weak var btnCategoryTitle: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    var businessInfo: BusinessInfo?
    
    let businessType: [String] = [
        "Physicians",
        "Dispensary",
        "Grower/processor",
        "Attorney",
        "Contractors",
        "Electricians",
        "Grow room design",
        "Security",
        "Payroll",
        "Marketing",
        "Real Estate",
        "Storefront",
        "Media/photography/videography"
    ]
    
    let categoryDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.categoryDropDown
        ]
    }()
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.setupMenuBarButton()
       NotificationCenter.default.addObserver(self, selector: #selector(markBusiness), name: .mapBusinessInfoSendNotification, object: nil)
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func markBusiness(_ notification: Notification){
        let mapBusinessInfo = notification.userInfo!["BusinessInfo"] as! BusinessInfo
        self.businessInfo?.alpha = mapBusinessInfo.alpha
        self.businessInfo?.profile.loadImageWithoutIndicator(urlString: mapBusinessInfo.user!.profileimg!)
        self.businessInfo?.user = mapBusinessInfo.user
        self.businessInfo?.name.text = mapBusinessInfo.user?.name
        self.businessInfo?.type.text = mapBusinessInfo.user?.business_type

        self.btnCategoryTitle.setTitle(self.businessInfo?.type.text, for: .normal)
        self.paccMap.showBusinessesOnMap((self.businessInfo?.type.text)!,(self.businessInfo?.name.text)!)
    }
    @IBAction func btnHomeAction(_ sender: Any) {
          self.appDelegate.makingRoot("enterApp")
    }
    
    @IBAction func btnMenuAction(_ sender: Any) {
        sideMenuController?.showLeftView(animated: true, completionHandler: nil)
    }
    
    @IBAction func actionChangeCategory(_ sender: UIButton) {
        self.view.endEditing(true)
        categoryDropDown.show()
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.dropDownImg.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        }, completion: { (finished) -> Void in
        })
    }
    
    func initView() {
        btnBack.setButtonShadow()
        customizeDropDown(self)
        categoryDropDown.anchorView = btnCategory
        categoryDropDown.bottomOffset = CGPoint(x: 0, y: btnCategory.bounds.height)
        
        businessInfo = BusinessInfo(frame: CGRect(x: (self.view.frame.width - 250) / 2, y: self.view.frame.height - 100, width: 250, height: 80))
        self.view.addSubview(businessInfo!)
        businessInfo?.alpha = 0.0
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        categoryDropDown.dataSource = businessType
        
        // Action triggered on selection
        categoryDropDown.selectionAction = { [unowned self] (index, item) in
            
            self.btnCategoryTitle.setTitle(self.businessType[index], for: .normal)
            self.businessInfo?.alpha = 0.0
            self.paccMap.showBusinessesOnMap(self.businessType[index])
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.dropDownImg.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi*2))

            }, completion: { (finished) -> Void in
            })
        }
        self.paccMap.setMapStyle()
        self.paccMap.showBusinessesOnMap(self.businessType[0])
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
