//
//  LocationView.swift
//  PACC
//
//  Created by RSS on 4/25/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import GooglePlaces

class LocationView: UIView {

    @IBOutlet weak var txtLocation: UITextField!
    
    var vc: UIViewController = UIViewController()
    
    var lat: Double = 0.0
    var long: Double = 0.0
    var location: String = ""
    // Declare variables to hold address form values.
    var street_number: String = ""
    var route: String = ""
    var neighborhood: String = ""
    var locality: String = ""
    var administrative_area_level_1: String = ""
    var country: String = ""
    var postal_code: String = ""
    var postal_code_suffix: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadNibName()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadNibName()
    }
    
    func loadNibName() {
        let view = Bundle.main.loadNibNamed("LocationView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        view.backgroundColor = self.backgroundColor
        self.addSubview(view)
    }
    
}

extension LocationView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == txtLocation {
            DispatchQueue.main.async {
                self.endEditing(true)
            }
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self

            // Specify the place data types to return.
            let fields: GMSPlaceField = GMSPlaceField(rawValue:UInt(GMSPlaceField.name.rawValue) |
                        UInt(GMSPlaceField.placeID.rawValue) |
                        UInt(GMSPlaceField.coordinate.rawValue) |
                        GMSPlaceField.addressComponents.rawValue |
                        GMSPlaceField.formattedAddress.rawValue)!
            autocompleteController.placeFields = fields
            // Specify a filter.
            let filter = GMSAutocompleteFilter()
            filter.type = .address
            autocompleteController.autocompleteFilter = filter

            // Display the autocomplete view controller.
            vc.present(autocompleteController, animated: true, completion: nil)
        }
    }
}


extension LocationView: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {

    var address: String = ""
    self.lat = place.coordinate.latitude
    self.long = place.coordinate.longitude
    place.addressComponents?.forEach { addrComp in
        if addrComp.type == "postal_town"{
            address += addrComp.name
        }
        if addrComp.type == "locality" {
            if address != "" {
                address += ", "
            }
            address += addrComp.name
        }
        if addrComp.type == "postal_code" {
            if address != "" {
                address += ", "
            }
            address += addrComp.name
        }
    }
    print("Place name \(address)")
    if address == "" {
        address = place.name ?? ""
    }
    txtLocation.text = address
    vc.dismiss(animated: true, completion: nil)
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    vc.dismiss(animated: true, completion: nil)
  }

  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }

  func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }

}


//extension LocationView: UITextFieldDelegate, GMSPlacePickerViewControllerDelegate {
//func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
//    viewController.dismiss(animated: true, completion: nil)
//
//    var address: String = ""
//    self.lat = place.coordinate.latitude
//    self.long = place.coordinate.longitude
//    place.addressComponents?.forEach { addrComp in
//        if addrComp.type == "postal_town"{
//            address += addrComp.name
//        }
//        if addrComp.type == "locality" {
//            if address != "" {
//                address += ", "
//            }
//            address += addrComp.name
//        }
//        if addrComp.type == "postal_code" {
//            if address != "" {
//                address += ", "
//            }
//            address += addrComp.name
//        }
//    }
//    print("Place name \(address)")
//    if address == "" {
//        address = place.name ?? ""
//    }
//    txtLocation.text = address
//}
