//
//  BusinessView.swift
//  PACC
//
//  Created by RSS on 4/25/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

class BusinessView: UIView {

    let businessType = ["Dispensary", "Grower/processor", "Physician", "Attorney", "Contractors", "Electricians", "Grow room design ", "Security", "Payroll", "Marketing", "Real estate", "Storefront", "Media/photography/videography"]
    
    @IBOutlet weak var txtBusinessType: UITextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadNibName()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadNibName()
    }
    
    func loadNibName() {
        let view = Bundle.main.loadNibNamed("BusinessView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        view.backgroundColor = self.backgroundColor
        self.addSubview(view)
        
        let btPicker = UIPickerView()
        btPicker.delegate = self
        txtBusinessType.inputView = btPicker
    }

}

extension BusinessView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return businessType.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return businessType[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtBusinessType.text = businessType[row]
    }
    
}
