//
//  ShopCell.swift
//  PACC
//
//  Created by RSS on 7/5/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

protocol ShopItemDelegate {
    func buyShopItem(_ cell: ShopCell)
}

class ShopCell: UIView {

    @IBOutlet weak var shopProfile: UIImageView!
    @IBOutlet weak var shopCategory: UILabel!
    @IBOutlet weak var shopPrice: UILabel!
    
    var index: Int?
    
    var product: Shop? {
        didSet {
            self.shopPrice.text = "$\(self.product?.price ?? 0)"
            self.shopCategory.text = self.product?.name
        }
    }
    
    var delegate: ShopItemDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibName()

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibName()

    }
    
    func loadNibName() {
        let view = Bundle.main.loadNibNamed("ShopCell", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        
        shopProfile.setPostRadius(10)
        let thickness: CGFloat = 1.0
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x:15, y: self.frame.size.height - thickness, width: self.frame.size.width - 30, height:thickness)
        bottomBorder.backgroundColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        self.layer.addSublayer(bottomBorder)
    }
    
    @IBAction func actionBuyItem(_ sender: UIButton) {
        delegate?.buyShopItem(self)
    }

}

class ShopCellOperation: Operation {
    let cell: ShopCell?
    var is_finished: Bool = false
    init(_ cell: ShopCell) {
        self.cell = cell
    }
    override func main() {
        let product = self.cell?.product
        DispatchQueue.main.async {
            if product?.image != nil {
                SDWebImageDownloader.shared.downloadImage(with: URL(string: product!.image!), options: .lowPriority, progress: nil, completed: {(image, data, error, success) in
                    if data != nil && !self.is_finished {
                        DispatchQueue.main.async {
                            try! RealmHelper.sharedInstance.realm.write {
                                product?.imgData = data
                            }
                            self.cell?.shopProfile.image = UIImage(data: product!.imgData!) //?.cropToBounds(width: self.cell!.shopProfile.frame.width, height: self.cell!.shopProfile.frame.height)
                        }
                    }
                })
            }
        }
        
    }
    override func cancel() {
        self.is_finished = true
    }
}
