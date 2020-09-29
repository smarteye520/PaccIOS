//
//  CommentCell.swift
//  PACC
//
//  Created by RSS on 6/17/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

class CommentCell: UIView {

    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    
    var comment: Comment? {
        didSet {
           
            self.lblComment.text = self.comment?.content
        
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd"
            self.lblDay.text = dateFormatter.string(from: self.comment!.created_at!)
            dateFormatter.dateFormat = "HH:mm a"
            self.lblTime.text = dateFormatter.string(from: self.comment!.created_at!)
            self.layoutIfNeeded()
            API.sharedInstance.getItemInfor("User", self.comment!.commenter!) { (dic) in
                if dic != nil {
                    let patient = User()
                    patient.loadUserInfo(dic!)
                    if patient.profileimg != nil {
                        self.profile.loadImageWithoutIndicator(urlString: patient.profileimg!)
                    }
                }
            }
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadNibName()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibName()
    }
    func loadNibName() {
        let view = Bundle.main.loadNibNamed("CommentCell", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }

}
