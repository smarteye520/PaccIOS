//
//  Extension.swift
//  PACC
//
//  Created by RSS on 4/19/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

struct UI {
    static let TAP_BAR_HEIGHT: CGFloat = 60
    static let COMMON_BUTTON_HEIGHT = 40
    static var SCREEN_WIDTH: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static let ROW_HEIGHT: CGFloat = 40
    
    static let HORZ_MARGIN: CGFloat = 20
}

extension UIButton {
    func drawBottomLine() {
        let bottomLine: UIView = UIView(frame: CGRect(x: 0, y: self.frame.height - 3, width: self.frame.width, height: 3))
        bottomLine.tag = 1000
        bottomLine.backgroundColor = AppTheme.light_green
        self.addSubview(bottomLine)
    }
    
    func removeBottomLine() {
        self.subviews.forEach {
            if $0.tag == 1000 {
                $0.removeFromSuperview()
            }
        }
    }
}

extension UITextField {
    func isValidEmail() -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a@objc -z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self.text)
    }
}

extension NSDictionary {
    func toString() -> String {
        var resultStr = ""
        self.forEach { (key, value) in
            resultStr += "\(key)=\(value)&"
        }
        resultStr.remove(at: resultStr.endIndex)
        return resultStr
    }
}

extension UIView {
    func fadeIn(completion: @escaping (_ finished: Bool?) -> Void) {
        self.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        self.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 1.0
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion:{(finished : Bool)  in
            completion(finished)
        })
    }
    
    func fadeOut(completion: @escaping (_ finished: Bool?) -> Void) {
        UIView.animate(withDuration: 0.25, animations: {
            self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            completion(finished)
        })
    }
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}

extension String {
    func heightForView(_ font:UIFont, _ width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = self
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func utcToLocal() -> Date {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: self)
        dateFormatter.timeZone = TimeZone.current
        
        let str = dateFormatter.string(from: dt!)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        return dateFormatter.date(from: str)!
    }
}

extension Date {
    func localToUTC() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let str = dateFormatter.string(from: self)
        
        dateFormatter.timeZone = TimeZone.current
        let dt = dateFormatter.date(from: str)
        
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        return dateFormatter.string(from: dt!)
    }
    func utcDate() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        return dateFormatter.string(from: self)
    }
}

extension UITextView: UITextViewDelegate {
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.count > 0
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = self.text.count > 0
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
    
}

extension UIImageView{
    
    func loadImageWithCache(urlString  : String){
        self.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.sd_setImage(with: URL(string: urlString))
    }
    
    func loadImageWithoutIndicator(urlString  : String) {
        self.sd_imageIndicator = nil
        self.sd_setImage(with: URL(string: urlString))
    }
}

extension UIImage {
    
    func cropToBounds(width: CGFloat, height: CGFloat) -> UIImage?
    {
        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x:0,
                              y:0,
                              width:width,
                              height:height)
        
        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = self.cgImage?.cropping(to:cropZone)
            else {
                return nil
        }
        
        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
    
}
