//
//  UIButtonExtensions.swift
//  EZSwiftExtensions
//
//  Created by Goktug Yilmaz on 15/07/15.
//  Copyright (c) 2015 Goktug Yilmaz. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
//import SDWebImage

extension UIButton {
	/// EZSwiftExtensions

	// swiftlint:disable function_parameter_count
	public convenience init(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, target: AnyObject, action: Selector) {
		self.init(frame: CGRect(x: x, y: y, width: w, height: h))
		addTarget(target, action: action, for: UIControl.Event.touchUpInside)
	}
	// swiftlint:enable function_parameter_count
	/// EZSwiftExtensions
	public func setBackgroundColor(_ color: UIColor, forState: UIControl.State) {
		UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
		UIGraphicsGetCurrentContext()?.setFillColor(color.cgColor)
		UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
		let colorImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		self.setBackgroundImage(colorImage, for: forState)
	}
    public func initLetterButtonUI(radius: Int){
        self.cornerRadius = CGFloat(radius)
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(hexValue: 0x979797).withAlphaComponent(0.4).cgColor
        self.setTitleColor(UIColor.white, for: .normal)
        self.backgroundColor = UIColor(hexValue: 0x0B691C).withAlphaComponent(0.8)
    }
    public func setButtonShadow(){
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.35).cgColor
        self.layer.shadowOffset = CGSize(width: 0.3, height: 0.3)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}
#endif
