//
//  MessageItem.swift
//  PACC
//
//  Created by RSS on 7/23/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

protocol MessageItemDelegate {
    func gotoContent(_ item: MessageItem)
}

class MessageItem: UIView {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblChat: UILabel!
    @IBOutlet weak var messageProfile: UIImageView!
    let PLACEHOLDER_IMG = UIImage(named: "ic_ProfileplaceHolder")
    var delegate: MessageItemDelegate?
    var user: User? {
        didSet {
            lblName.text = user?.name
            messageProfile.sd_imageIndicator = nil
            messageProfile.sd_setImage(with: URL(string: user!.profileimg ?? ""), placeholderImage: PLACEHOLDER_IMG, options: .lowPriority, completed: nil)
            self.messages = []
        }
    }
    var messages: [Message]?
    var all_messages: [Message]? {
        didSet {
            messages = []
            for message in all_messages! {
                if message.sender == user?.id || message.receiver == user?.id {
                    messages?.append(message)
                }
            }
            
            messages = messages?.sorted { message1, message2 in
                return message1.created_at!.compare(message2.created_at!) == .orderedAscending ? true : false
            }
            if messages!.count > 0 {
                switch messages![messages!.count - 1].type {
                case 0:
                    lblChat.text = messages![messages!.count - 1].content
                case 1:
                    lblChat.text = "Shared a photo"
                default:
                    lblChat.text = "---"
                }
            }else {
                lblChat.text = "---"
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
        let view = Bundle.main.loadNibNamed("MessageItem", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    @IBAction func actionGotoContent(_ sender: UIButton) {
        delegate?.gotoContent(self)
    }
    
}
