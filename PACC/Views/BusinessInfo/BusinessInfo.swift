//
//  BusinessInfo.swift
//  PACC
//
//  Created by RSS on 6/8/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

class BusinessInfo: BaseView {

    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var type: UILabel!
    
    var user: User?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibName()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibName()
    }
    
    func loadNibName() {
        let view = Bundle.main.loadNibNamed("BusinessInfo", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        view.backgroundColor = UIColor.white
        self.addSubview(view)
        
    }

    @IBAction func actionGotoProfile(_ sender: UIButton) {
        let viewCon = self.findViewController() as! ExploreViewController
        let vc = viewCon.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileViewController
        vc.user = self.user
        viewCon.navigationController?.pushViewController(vc, animated: true)
    }
}
