//
//  TextViewAutoHeight.swift
//  PACC
//
//  Created by 111 on 5/1/20.
//  Copyright © 2020 HTK. All rights reserved.
//

import UIKit

class TextViewAutoHeight: UITextView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isScrollEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(updateHeight), name: UITextView.textDidChangeNotification, object: nil)
    }

    @objc func updateHeight() {
        // trigger your animation here
        var newFrame = frame
        
        let fixedWidth = frame.size.width
        let newSize = sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))

        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        self.frame = newFrame
    }
}
