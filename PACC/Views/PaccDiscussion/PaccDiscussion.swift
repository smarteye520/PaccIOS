//
//  PaccDiscussion.swift
//  PACC
//
//  Created by RSS on 8/3/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

class PaccDiscussion: UIScrollView {

    let add_discussion_queue = OperationQueue()
    
    var real_data: [Discussion] = []
    var item: DiscussionCell?
    var origin_y: CGFloat = 0
    var last_item: DiscussionCell?
    var items : [DiscussionCell] = []
    var operations: [DiscussionCellOperation] = []
    
    func reloadData() {
        origin_y = 0
        item = nil
        last_item = nil
        self.add_discussion_queue.cancelAllOperations()
        self.operations.forEach { (operation) in
            operation.cancel()
        }
        self.operations.removeAll()
        
        self.alpha = 1.0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0.0
        }) {(finished) in
            UIView.animate(withDuration: 0.5, animations: {
                self.subviews.forEach({ (view) in
                    view.removeFromSuperview()
                })
                for i in 0 ..< self.real_data.count {
                    
                    self.addDiscussionItem(i)
                }
                self.alpha = 1.0
            })
        }
        
    }
    
    func addDiscussionItem(_ cnt: Int) {
        if self.last_item != nil {
            self.origin_y = self.last_item!.frame.origin.y + self.last_item!.frame.size.height + 10
        }
        print(self.real_data[cnt])
        print(self.item)
        self.item = DiscussionCell(frame: CGRect(x: 0, y: self.origin_y, width: self.frame.width, height: 350))
        self.item?.discussion = self.real_data[cnt]
        self.last_item = self.item
        self.items.append(self.item!)
        self.addSubview(self.item!)
        self.contentSize = CGSize(width: 0, height: self.item!.frame.origin.y + self.item!.frame.size.height)
        operations.append(DiscussionCellOperation(item!))
        if cnt > 0 {
            operations[cnt].addDependency(operations[cnt - 1])
        }
        add_discussion_queue.addOperation(operations[cnt])
    }

}
