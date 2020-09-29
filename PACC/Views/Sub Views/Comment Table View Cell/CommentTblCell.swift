//
//  CommentTblCell.swift
//  PACC
//
//  Created by Naman Swadia on 17/11/19.
//  Copyright © 2019 HTK. All rights reserved.
//

import UIKit

class CommentTblCell: UITableViewCell {

    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
