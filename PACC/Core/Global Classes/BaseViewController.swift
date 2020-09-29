//
//  BaseViewController.swift
//  PACC
//
//  Created by RSS on 4/19/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import LGSideMenuController
import PassKit
import Stripe

class BaseViewController: UIViewController, NVActivityIndicatorViewable {
    let SupportedPaymentNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex]
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var product_desc: String = ""
    var product_budget: String = "0"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    //MARK: Side menu Controller

    func setupMenuBarButton(){
        
        let menuButtonImg = UIImageView(frame: CGRect(x: self.view.frame.width - 40, y: 35, width: 20, height: 20))
        menuButtonImg.image = #imageLiteral(resourceName: "menu")
        
        let menuButton = UIButton(frame: CGRect(x: self.view.frame.width - 50, y: 25, width: 40, height: 40))
        menuButton.addTarget(self, action: #selector(BaseViewController.showLGSideMenu(_:)), for: .touchUpInside)
        self.view.addSubview(menuButtonImg)
        self.view.addSubview(menuButton)
        
        if !(self is HomeViewController) {
            let homeImg = UIImageView(frame: CGRect(x: 25, y: 35, width: 25, height: 25))
            homeImg.image = UIImage(named: "home")
            
            let homeBtn = UIButton(frame: CGRect(x: 15, y: 20, width: 50, height: 50))
            homeBtn.addTarget(self, action: #selector(self.gotoHome), for: .touchUpInside)
            self.view.addSubview(homeImg)
            self.view.addSubview(homeBtn)
        }
        
    }
    
    @objc func gotoHome() {
        self.appDelegate.makingRoot("enterApp")
    }
    
    // MARK: - Open Side menu Controller
    @objc func showLGSideMenu(_ sender: UIBarButtonItem) {
        sideMenuController?.showLeftView(animated: true, completionHandler: nil)
    }
    
    //MARK: Gloabl Alert View Controller
    func alertViewController(title: String, message: String){
        let alert = UIAlertController(title: title.capitalized, message: message , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showHUD() {
        startAnimating(type: NVActivityIndicatorType.ballRotateChase, color: UIColor(red: 37/255, green: 132/255, blue: 63/255, alpha: 1), displayTimeThreshold: 0, minimumDisplayTime: 0)
    }
    
    func hideHUD() {
        stopAnimating()
    }
    
    func createToken(_ description: String, _ budget: String) {
        
        self.product_budget = budget
        self.product_desc = description
        
        let request = PKPaymentRequest()
        request.merchantIdentifier = merchant_id
        request.supportedNetworks = SupportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        
        request.paymentSummaryItems =
        [
            PKPaymentSummaryItem(label: description, amount: NSDecimalNumber(string: budget))
        ]
        
        
        if let paymentAuthorizationVC = PKPaymentAuthorizationViewController(paymentRequest: request) {
            paymentAuthorizationVC.delegate = self
            self.present(paymentAuthorizationVC, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(
                title: "The settlement method is not registered",
                message: "Would you like to register payment method now",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "YES", style: UIAlertAction.Style.default, handler: { action in
                if #available(iOS 8.3, *) {
                    PKPassLibrary().openPaymentSetup()
                }
            }))
            alertController.addAction(UIAlertAction(title: "NO", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
        
//        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
//        applePayController!.delegate = self
//        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: supportedPaymentNetworks) {
//            self.present((applePayController ?? nil)!, animated: true, completion: nil)
//        } else {
//
//        }
    }
    
    public func checkApplePayAvaliable() -> Bool {
        if !PKPaymentAuthorizationViewController.canMakePayments() {
            let alertController = UIAlertController(
                title: "error",
                message: "This device does not support Apple Pay",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
            return false
        }
        return true
    }
    
    public var supportedPaymentNetworks: [PKPaymentNetwork] {
        get {
            if #available(iOS 10.0, *) {
                return PKPaymentRequest.availableNetworks()
            } else {
                return [.visa, .masterCard, .amex]
            }
        }
    }
    
    public func checkPaymentNetworksAvaliable(usingNetworks networks: [PKPaymentNetwork]) {
        if !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: networks) {
            
        }
    }

}

extension BaseViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping ((PKPaymentAuthorizationStatus) -> Void)) {
        self.showHUD()
        STPAPIClient.shared().createToken(with: payment) { (token: STPToken?, error: Error?) in
            
            if let _ = error {
                self.hideHUD()
                // Present error to user...
                print(token?.tokenId ?? "")
                // Notify payment authorization view controller
                completion(.failure)
            }
            else {
                API.sharedInstance.createCharge(token!.tokenId, budget: self.product_budget, description: self.product_desc, completion: { (errMsg) in
                    DispatchQueue.main.async {
                        self.hideHUD()
                        if errMsg == nil {
                            if self is EditProfileViewController {
                                let vc = self as! EditProfileViewController
                                vc.btnUpgrade.alpha = 0.0
                                User.sharedInstance.is_premium = true
                                var collection = "Business"
                                if User.sharedInstance.isPatient != nil && User.sharedInstance.isPatient! {
                                    collection = "User"
                                }
                                API.sharedInstance.updateItem(collection, User.sharedInstance.getDic(), completion: { (success) in
                                    if success != nil && success! {
                                        print("Updated successfully")
                                    }else {
                                        print("Updated failed")
                                    }
                                })
                                self.alertViewController(title: "Success", message: "You are upgraded successfully!")
                            }else {
                                self.alertViewController(title: "Success", message: "Your request successfully charged!")
                            }
                        }else {
                            self.alertViewController(title: "Ooops!", message: errMsg!)
                        }
                    }
                })
                completion(.success)
            }
        }
    }
}

extension BaseViewController: UIViewControllerTransitioningDelegate {
    func transitionDissmiss(){
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window?.layer.add(transition, forKey: nil)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func transitionNav(to controller: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        view.window?.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(controller, animated: false)
    }
}
