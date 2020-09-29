//
//  PaccChat.swift
//  PACC
//
//  Created by RSS on 6/13/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

class PaccChat: UIScrollView {

    var messages: [Message]?
    var type: Int?
    
    var item: MessageCell?
    var origin_y: CGFloat = 0
    var last_item: MessageCell?
    
    var message_cells: [MessageCell] = []
    var operations: [ImageDownloadOperation] = []
    
    let add_message_queue = OperationQueue()
    
    func initView() {
        self.subviews.forEach { (view) in
            if view is MessageCell {
                view.removeFromSuperview()
            }
        }
        self.delegate = self
        message_cells.removeAll()
        origin_y = 0
        last_item = nil
        self.showsVerticalScrollIndicator = false
        add_message_queue.cancelAllOperations()
        self.operations.removeAll()
        if messages != nil {
            for message in messages! {
                self.add_message(message, false)
            }
            
            for i in 0 ..< messages!.count {
                self.message_cells[self.messages!.count - i - 1].message = self.messages?[self.messages!.count - i - 1]
                self.message_cells[self.messages!.count - i - 1].initCell()
                let cell = self.message_cells[self.messages!.count - i - 1]
                self.operations.append(ImageDownloadOperation(cell))
                if i > 0 {
                    self.operations[i].addDependency(self.operations[i - 1])
                }
                add_message_queue.addOperation(self.operations[i])
            }
        }
    }
    
    
    func add_message(_ message: Message, _ is_new: Bool) {
        let MIN_HEIGHT = message.sender != User.sharedInstance.id ? MIN_HEIGHT2 : MIN_HEIGHT1
        if last_item != nil {
            origin_y = last_item!.frame.origin.y + last_item!.frame.size.height + 5
        }
        if message.type == 0 {
            var viewHeight = message.content!.heightForView(UIFont.systemFont(ofSize: 15), self.frame.width - 175)
            viewHeight = CGFloat(Float(viewHeight) > MIN_HEIGHT ? Float(viewHeight + 25) : MIN_HEIGHT)
            item = MessageCell(frame: CGRect(x: 0, y: origin_y, width: self.frame.width, height: viewHeight))
            if message.sender == User.sharedInstance.id && message.senderType == NSNumber(value: User.sharedInstance.isPatient!).intValue {
                item?.loadNibName(1)
            }else {
                item?.loadNibName(0)
            }
        }else if message.type == 1 {
            let max_value = message.width > message.height ? message.width : message.height
            if max_value < MAX_VALUE {
                let viewHeight = MAX_VALUE
                let width = message.width * MAX_VALUE / message.height
                
                if message.sender == User.sharedInstance.id && message.senderType == NSNumber(value: User.sharedInstance.isPatient!).intValue {
                    item = MessageCell(frame: CGRect(x: self.frame.width - CGFloat(width) - 156, y: origin_y, width: CGFloat(width) + 156, height: CGFloat(viewHeight + 100)))
                    item?.loadNibName(1)
                }else {
                    item = MessageCell(frame: CGRect(x: 0, y: origin_y, width: CGFloat(width) + 156, height: CGFloat(viewHeight + 100)))
                    item?.loadNibName(0)
                }
            }else {
                let height = message.height > MAX_VALUE ? MAX_VALUE : message.height
                var width = message.width * MAX_VALUE / message.height
                width = height > MIN_HEIGHT ? width : width * MIN_HEIGHT / height
                
                if message.sender == User.sharedInstance.id && message.senderType == NSNumber(value: User.sharedInstance.isPatient!).intValue {
                    item = MessageCell(frame: CGRect(x: self.frame.width - CGFloat(width) - 156, y: origin_y, width: CGFloat(width + 156), height: CGFloat(height + 100)))
                    item?.loadNibName(1)
                }else {
                    item = MessageCell(frame: CGRect(x: 0, y: origin_y, width: CGFloat(width) + 156, height: CGFloat(height + 100)))
                    item?.loadNibName(0)
                }
            }
        }else {
            item = MessageCell(frame: CGRect(x: 0, y: origin_y, width: self.frame.width, height: 200))
            
            if message.sender == User.sharedInstance.id && message.senderType == NSNumber(value: User.sharedInstance.isPatient!).intValue {
                item?.loadNibName(1)
            }else {
                item?.loadNibName(0)
            }
        }
        last_item = item
        self.addSubview(item!)
        self.contentSize = CGSize(width: 0, height: item!.frame.origin.y + item!.frame.size.height + 5)
        self.setContentOffset(CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height), animated: true)
        
        if is_new {
            item?.message = message
            item?.initCell()
            if self.messages == nil {
                self.messages = []
            }
            self.messages?.append(message)
            
            self.operations.append(ImageDownloadOperation(item!))
            add_message_queue.addOperation(self.operations[self.operations.count - 1])
            if operations.count > 1 {
                self.operations[self.operations.count - 1].addDependency(self.operations[self.operations.count - 2])
            }
            
            if message.sender == User.sharedInstance.id {
                if type == 0 {
                    if message.type == 0 {
                        API.sharedInstance.insertItem("Message", message.getMessageDic()) { (errMsg) in
                            if errMsg != nil {
                                print(errMsg!)
                            }
                        }
                    }else {
                        API.sharedInstance.uploadImage(UIImage(data: message.image!)!) { (imgURL) in
                            message.content = imgURL
                            API.sharedInstance.insertItem("Message", message.getMessageDic()) { (errMsg) in
                                
                            }
                        }
                    }
                }else {
                    if message.type == 0 {
                        if self.findViewController() is MessageViewController {
                            API.sharedInstance.addMessage(message, message.created_at!.localToUTC())
                        }else {
                            API.sharedInstance.addBusinessMessage(message, message.created_at!.localToUTC())
                        }
                        
                    }else {
                        if(message.image != nil) {
                            API.sharedInstance.uploadImage(UIImage(data: message.image!)!) { (imgURL) in
                           message.content = imgURL
                           if self.findViewController() is MessageViewController {
                               API.sharedInstance.addMessage(message, message.created_at!.localToUTC())
                           }else {
                               API.sharedInstance.addBusinessMessage(message, message.created_at!.localToUTC())
                           }
                       }
                        }
                       
                        
                    }
                }
            }
        }else {
            self.message_cells.append(item!)
        }
        
    }
}

extension PaccChat: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("suspended")
        add_message_queue.isSuspended = true
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        print("")
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("")
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("resumed")
        add_message_queue.isSuspended = false
    }
}
