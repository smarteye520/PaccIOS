//
//  FromTo.swift
//  PACC
//
//  Created by RSS on 5/7/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

class FromTo: UIView {

    @IBOutlet weak var txtFrom: UITextField!
    @IBOutlet weak var txtTo: UITextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadNibName()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadNibName()
    }
    
    func loadNibName() {
        
        let view = Bundle.main.loadNibNamed("FromTo", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        view.backgroundColor = self.backgroundColor
        self.addSubview(view)
        
        let fromDatePickerView: UIDatePicker = UIDatePicker()
        fromDatePickerView.datePickerMode = UIDatePicker.Mode.time
        txtFrom.inputView = fromDatePickerView
        fromDatePickerView.addTarget(self, action: #selector(fromDatePickerValueChanged), for: UIControl.Event.valueChanged)
        
        let toDatePickerView: UIDatePicker = UIDatePicker()
        toDatePickerView.datePickerMode = UIDatePicker.Mode.time
        txtTo.inputView = toDatePickerView
        toDatePickerView.addTarget(self, action: #selector(toDatePickerValueChanged), for: UIControl.Event.valueChanged)
    }
    
    @objc func fromDatePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        txtFrom.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func toDatePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        txtTo.text = dateFormatter.string(from: sender.date)
    }

}
