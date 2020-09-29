//
//  BorderButton.swift
//  PACC
//
//  Created by RSS on 4/19/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

class BorderButton: UIButton {

    override func awakeFromNib() {
        self.layer.cornerRadius = 5
        self.layer.borderColor = self.titleColor(for: .normal)?.cgColor
        self.layer.borderWidth = 2.0
    }

}
