//
//  PaccComment.swift
//  PACC
//
//  Created by RSS on 6/17/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import RealmSwift

class PaccComment: UIScrollView {
    
    var item: CommentCell?
    var origin_y: CGFloat = 0
    var last_item: CommentCell?
    
    let add_comment_queue = OperationQueue()

    var comments = List<Comment>()
    var comment_cells: [CommentCell] = []
    
    func initView() {
        origin_y = 0
        last_item = nil
        self.delegate = self
        add_comment_queue.cancelAllOperations()
        comment_cells.removeAll()
        self.subviews.forEach { (view) in
            if view is CommentCell {
                view.removeFromSuperview()
            }
        }
        for comment in comments {
            self.addComment(comment, false)
        }
        var operations: [Operation] = []
        for i in 0 ..< comments.count {
            let operation = BlockOperation {
                DispatchQueue.main.async {
                    self.comment_cells[self.comments.count - i - 1].comment = self.comments[self.comments.count - i - 1]
                }
            }
            operations.append(operation)
            if i > 0 {
                operations[i].addDependency(operations[i - 1])
            }
            add_comment_queue.addOperation(operation)
        }
    }
    
    func addComment(_ comment: Comment, _ is_new: Bool) {
        if last_item != nil {
            origin_y = last_item!.frame.origin.y + last_item!.frame.size.height + 5
        }
        last_item?.layoutIfNeeded()
        var viewHeight = comment.content!.heightForView(UIFont.systemFont(ofSize: 15), self.frame.width)
        viewHeight = viewHeight > 55 ? viewHeight : 55
      
        item = CommentCell(frame: CGRect(x: 0, y: origin_y, width: self.frame.width, height: viewHeight))
        self.addSubview(item!)
        self.layoutIfNeeded()
      
        self.contentSize = CGSize(width: 0, height: item!.frame.origin.y + item!.frame.size.height)
        self.setContentOffset(CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height), animated: true)
        self.layoutIfNeeded()

        last_item = item
        if is_new {
            try! RealmHelper.sharedInstance.realm.write {
                item?.comment = comment
                self.comments.append(comment)
            }
        }else {
            self.comment_cells.append(item!)
        }
    }

}

extension PaccComment: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("suspended")
//        add_comment_queue.isSuspended = true
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        print("")
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("")
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("resumed")
//        add_comment_queue.isSuspended = false
    }
}
