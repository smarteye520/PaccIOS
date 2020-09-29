//
//  PaccShop.swift
//  PACC
//
//  Created by RSS on 8/3/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

class PaccShop: UIScrollView {

    var operations: [ShopCellOperation] = []
    var products: [Shop] = []
    var item: ShopCell?
    var origin_y: CGFloat = 0
    var last_item: ShopCell?
    var items: [ShopCell] = []
    let add_shopitem_queue = OperationQueue()
    
    func reloadData() {
        self.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        for i in 0 ..< self.products.count {
            self.addShopItem(i)
        }
    }
    
    func addShopItem(_ cnt: Int) {
        if self.last_item != nil {
            self.origin_y = self.last_item!.frame.origin.y + self.last_item!.frame.size.height + 10
        }
        self.item = ShopCell(frame: CGRect(x: 0, y: self.origin_y, width: self.frame.width, height: 160))
        self.item?.delegate = self.findViewController() as! ShopViewController
        self.item?.product = products[cnt]
        self.last_item = self.item
        self.items.append(self.item!)
        self.addSubview(self.item!)
        self.contentSize = CGSize(width: 0, height: self.item!.frame.origin.y + self.item!.frame.size.height)
        operations.append(ShopCellOperation(item!))
        if cnt > 0 {
            operations[cnt].addDependency(operations[cnt - 1])
        }
        add_shopitem_queue.addOperation(operations[cnt])
        
    }

}


