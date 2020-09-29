//
//  DiscussionCategory.swift
//  PACC
//
//  Created by RSS on 5/28/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

protocol DCDelegate {
    func sort(_ type: Int)
}

class DiscussionCategory: UIView {
    
    @IBOutlet var buttons: [UIButton]!
    var prevBtn: Int = 0
    var delegate: DCDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibName()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibName()
    }
    
    func loadNibName() {
        let view = Bundle.main.loadNibNamed("DiscussionCategory", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        view.backgroundColor = UIColor.white
        self.addSubview(view)
        
        self.onCategory(buttons[prevBtn])
        
    }
    
    @IBAction func onCategory(_ sender: UIButton) {
        self.buttons[prevBtn].setTitleColor(UIColor.darkGray, for: .normal)
        sender.setTitleColor(AppTheme.light_green, for: .normal)
        prevBtn = sender.tag
        self.fadeOut { (success) in
            
        }
        delegate?.sort(prevBtn)
    }
    

}
