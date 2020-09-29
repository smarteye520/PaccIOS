//
//  SearchCell.swift
//  PACC
//
//  Created by RSS on 7/24/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

protocol SearchCellDelegate {
    func gotoProfile(_ cell: SearchCell)
}

class SearchCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    var user: User? {
        didSet {
            profileImg.image = #imageLiteral(resourceName: "profile")
            if user?.profileimg != nil {
                profileImg.loadImageWithoutIndicator(urlString: user!.profileimg!)
            }
            lblName.text = user?.name
            lblType.text = user?.business_type
        }
    }
    
    var delegate: SearchCellDelegate?
    
    @IBAction func actionGotoProfile(_ sender: UIButton) {
        delegate?.gotoProfile(self)
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
