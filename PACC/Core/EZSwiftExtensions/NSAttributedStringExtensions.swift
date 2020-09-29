//
//  NSAttributedStringExtensions.swift
//  EZSwiftExtensions
//
//  Created by Lucas Farah on 18/02/16.
//  Copyright (c) 2016 Lucas Farah. All rights reserved.
//
import Foundation
import UIKit

#if os(iOS) || os(tvOS)
    
    extension NSAttributedString {
        /// EZSE: Adds bold attribute to NSAttributedString and returns it
        
        #if os(iOS)
        
        public func bold() -> NSAttributedString {
            guard let copy = self.mutableCopy() as? NSMutableAttributedString else { return self }
            
            let range = (self.string as NSString).range(of: self.string)
            copy.addAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)], range: range)
            return copy
        }
        
        #endif
        
        /// EZSE: Adds underline attribute to NSAttributedString and returns it
        public func underline() -> NSAttributedString {
            guard let copy = self.mutableCopy() as? NSMutableAttributedString else { return self }
            
            let range = (self.string as NSString).range(of: self.string)
            copy.addAttributes([NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: range)
            return copy
        }
        
        #if os(iOS)
        
        /// EZSE: Adds italic attribute to NSAttributedString and returns it
        public func italic() -> NSAttributedString {
            guard let copy = self.mutableCopy() as? NSMutableAttributedString else { return self }
            
            let range = (self.string as NSString).range(of: self.string)
            copy.addAttributes([NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)], range: range)
            return copy
        }
        
        /// EZSE: Adds strikethrough attribute to NSAttributedString and returns it
        public func strikethrough() -> NSAttributedString {
            guard let copy = self.mutableCopy() as? NSMutableAttributedString else { return self }
            
            let range = (self.string as NSString).range(of: self.string)
            let attributes = [
                NSAttributedString.Key.strikethroughStyle: NSNumber(value: NSUnderlineStyle.single.rawValue as Int)]
            copy.addAttributes(attributes, range: range)
            
            return copy
        }
    
        #endif
        
        /// EZSE: Adds color attribute to NSAttributedString and returns it
        public func color(_ color: UIColor) -> NSAttributedString {
            guard let copy = self.mutableCopy() as? NSMutableAttributedString else { return self }
            
            let range = (self.string as NSString).range(of: self.string)
            copy.addAttributes([NSAttributedString.Key.foregroundColor: color], range: range)
            return copy
        }
        
        
        func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
            let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
            let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
            return boundingBox.height
        }
    }
    
    /// EZSE: Appends one NSAttributedString to another NSAttributedString and returns it
    public func += (left: inout NSAttributedString, right: NSAttributedString) {
        let ns = NSMutableAttributedString(attributedString: left)
        ns.append(right)
        left = ns
    }
    
#endif
extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String, size: CGFloat = 15) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: size)]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        return self
    }
    @discardableResult func color(_ text: String, color: UIColor = .black, isBold: Bool = false, size: CGFloat = 15) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: isBold ? UIFont.boldSystemFont(ofSize: size): UIFont.systemFont(ofSize: size), .foregroundColor : color]
        let normalString = NSMutableAttributedString(string:text, attributes: attrs)
        append(normalString)
        return self
    }
    @discardableResult func normal(_ text: String, size: CGFloat = 15) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: size)]
        let normalString = NSMutableAttributedString(string:text, attributes: attrs)
        append(normalString)
        return self
    }
    @discardableResult func image(_ image: UIImage, offsetY: CGFloat) -> NSMutableAttributedString {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        imageAttachment.bounds = CGRect(x: 0.0, y: offsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height);
        let imageString = NSAttributedString(attachment: imageAttachment)
        append(imageString)
        return self
    }
}
