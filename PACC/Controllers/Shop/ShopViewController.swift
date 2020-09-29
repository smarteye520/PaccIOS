//
//  ShopViewController.swift
//  PACC
//
//  Created by RSS on 4/18/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import RealmSwift
import PassKit
import Stripe

class ShopViewController: BaseViewController {
    
    @IBOutlet weak var scrShop: PaccShop!
    @IBOutlet weak var btnBack: UIButton!
    var isInThisView: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnBack.setButtonShadow()
        isInThisView = true
        self.getProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isInThisView = false
        if self.scrShop != nil {
            self.scrShop.add_shopitem_queue.cancelAllOperations()
            self.scrShop.operations.forEach { (operation) in
                operation.cancel()
            }
        }
    }
    
    @IBAction func btnHomeAction(_ sender: Any) {
        self.appDelegate.makingRoot("enterApp")

    }
    
    @IBAction func btnMenuAction(_ sender: Any) {
        sideMenuController?.showLeftView(animated: true, completionHandler: nil)
    }
    
    
    func getProducts() {
        self.showHUD()
        API.sharedInstance.getAllItems("Products") { (products) in
            DispatchQueue.main.async {
                self.hideHUD()
                self.scrShop.products.removeAll()
                for product in RealmHelper.sharedInstance.realm.objects(Shop.self) {
                    self.scrShop.products.append(product)
                }
                self.scrShop.reloadData()
            }
        }
    }
}

extension ShopViewController: ShopItemDelegate {
    
    func buyShopItem(_ cell: ShopCell) {
        if User.sharedInstance.is_premium != nil && User.sharedInstance.is_premium! {
            self.createToken("PACC Buy \(cell.shopCategory!.text!)", cell.shopPrice.text!)
        }else {
            self.createToken("PACC Upgrade", "20.0")
        }
    }
    
}

