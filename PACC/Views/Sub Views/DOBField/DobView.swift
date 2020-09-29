//
//  DobView.swift
//  PACC
//
//  Created by RSS on 4/25/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

class DobView: UIView {

    @IBOutlet weak var txtDOB: UITextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadNibName()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadNibName()
    }
    
    func loadNibName() {
        
        let view = Bundle.main.loadNibNamed("DobView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        view.backgroundColor = self.backgroundColor
        self.addSubview(view)
        
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        txtDOB.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: UIControl.Event.valueChanged)
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        txtDOB.text = dateFormatter.string(from: sender.date)
    }

}
