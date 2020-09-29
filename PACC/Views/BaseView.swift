//
//  BaseView.swift
//  Nickel Ride
//
//  Created by RSS on 4/22/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

class BaseView: UIView {
    
    var vc: UIViewController?
    
    override func layoutSubviews() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 5.0
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: -2, height: 2)
        self.layer.shadowRadius = 5.0
        self.layer.shadowPath = UIBezierPath(rect: self.layer.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = true ? UIScreen.main.scale : 1
        self.vc = self.findViewController()
    }

}
