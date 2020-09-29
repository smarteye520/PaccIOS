//
//  PhoneView.swift
//  PACC
//
//  Created by RSS on 4/25/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import SwiftPhoneNumberFormatter

class PhoneView: UIView {

    @IBOutlet weak var txtPhone: PhoneFormattedTextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadNibName()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadNibName()
    }
    
    func loadNibName() {
        let view = Bundle.main.loadNibNamed("PhoneView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        view.backgroundColor = self.backgroundColor
        self.addSubview(view)
        
        txtPhone.config.defaultConfiguration = PhoneFormat(phoneFormat: "### (###)-####", regexp: "^1\\d*$")
        txtPhone.prefix = "+1 "
    }

}
