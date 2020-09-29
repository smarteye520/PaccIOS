//
//  ConnectionCell.swift
//  PACC
//
//  Created by RSS on 7/24/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

protocol ConnectionCellDelegate {
    func actionFollow(_ isFollow: Bool, _ params: NSDictionary?, _ cell : ConnectionCell)
    func actionViewProfile(_ cell : ConnectionCell)
}

class ConnectionCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblBusinessType: UILabel!
    @IBOutlet weak var btnFollow: BorderButton!
    
    var delegate: ConnectionCellDelegate?
    
    var user: User? {
        didSet {
            profileImg.image = #imageLiteral(resourceName: "profile")
            if user?.profileimg != nil && user?.profileimg != "" {
                self.profileImg.loadImageWithoutIndicator(urlString: user!.profileimg!)
            }
            self.lblName.text = user?.name
            self.lblBusinessType.text = user?.business_type == nil ? "---" : user?.business_type
        }
    }
    
    var id: String? {
        didSet {
            self.isFollow = self.id == nil ? false : true
        }
    }
    
    var isFollow: Bool? {
        didSet {
            if isFollow! {
                btnFollow.backgroundColor = AppTheme.light_green
                btnFollow.setTitle("Following", for: .normal)
            }else {
                if !User.sharedInstance.isPatient! {
                    btnFollow.alpha = 0.0
                }
                btnFollow.backgroundColor = AppTheme.white
                btnFollow.setTitle("Follow", for: .normal)
            }
        }
    }
    
    @IBAction func actionFollow(_ sender: BorderButton) {
        if !User.sharedInstance.isPatient! {
            return
        }
        
        var params: NSDictionary?
        if !self.isFollow! {
            params = [
                "follower": User.sharedInstance.id!,
                "following": user!.id!
            ]
        }
        delegate?.actionFollow(!self.isFollow!, params, self)
        
    }
    
    @IBAction func actionViewProfile(_ sender: UIButton) {
        delegate?.actionViewProfile(self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
