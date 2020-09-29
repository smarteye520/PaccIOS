//
//  AppDelegate.swift
//  PACC
//
//  Created by RSS on 4/17/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift
import Stripe
import LGSideMenuController
import RealmSwift
import MessageUI

 var arrmutablData = [String]()
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , MFMailComposeViewControllerDelegate{
   
    var window: UIWindow?
    var storyboard: UIStoryboard?
    var LGSideMenu: LGSideMenuController?
    var positions: [PaccPos] = []

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setDefaultRealm()
        
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        UIApplication.shared.statusBarStyle = .lightContent
        /// Google Map Service
        GMSServices.provideAPIKey("AIzaSyApXwoyliuRaxKpVNAdZsp1VSTCCz6TTFI")
        GMSPlacesClient.provideAPIKey("AIzaSyApXwoyliuRaxKpVNAdZsp1VSTCCz6TTFI")

        STPPaymentConfiguration.shared().publishableKey = live_key
        STPPaymentConfiguration.shared().appleMerchantIdentifier = merchant_id
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().backgroundColor = UIColor.clear
        UINavigationBar.appearance().barTintColor =  UIColor.clear
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 19.0) ,NSAttributedString.Key.foregroundColor:UIColor.white]
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@"])
            mail.setSubject("Bla")
            mail.setMessageBody("<b>Blabla</b>", isHTML: true)
            self.window?.rootViewController?.present(mail, animated: true, completion: nil)
        } else {
            print("Cannot send mail")
            // give feedback to the user
        }
    
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        if loadUser() {
            self.makingRoot("enterApp")
        }else {
            self.makingRoot("initial")
        }
        
        return true
    }

 
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Cancelled")
        case MFMailComposeResult.saved.rawValue:
            print("Saved")
        case MFMailComposeResult.sent.rawValue:
            print("Sent")
        case MFMailComposeResult.failed.rawValue:
            print("Error: \(String(describing: error?.localizedDescription))")
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func loadUser() -> Bool {
        if UserDefaults.standard.object(forKey: "Email") == nil {
            return false
        }
        User.sharedInstance.email = UserDefaults.standard.object(forKey: "Email") as? String
        User.sharedInstance.password = UserDefaults.standard.object(forKey: "Password") as? String
        User.sharedInstance.isPatient = UserDefaults.standard.object(forKey: "Is_Patient") as? Bool
        return true
    }
    
    func saveUser() {
        UserDefaults.standard.set(User.sharedInstance.email!, forKey: "Email")
        UserDefaults.standard.set(User.sharedInstance.password!, forKey: "Password")
        UserDefaults.standard.set(User.sharedInstance.isPatient!, forKey: "Is_Patient")
        UserDefaults.standard.synchronize()
    }
    
    func deleteUser() {
        UserDefaults.standard.removeObject(forKey: "Email")
        UserDefaults.standard.removeObject(forKey: "Password")
        UserDefaults.standard.removeObject(forKey: "Is_Patient")
    }
    
    func setDefaultRealm() {
        var config = Realm.Configuration()
        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("pacc.realm")
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
//        RealmHelper.sharedInstance.remove_all_items(Message.self)
    }
    
    func makingRoot(_ strRoot: String) {
        var rootVC: UIViewController?
        var naviCon: UINavigationController?
        storyboard = UIStoryboard(name: "Main", bundle: nil)
        if strRoot == "initial" {
            RealmHelper.sharedInstance.empty_realm_db()
            rootVC = storyboard?.instantiateViewController(withIdentifier: "SignInVC") as? SignInViewController
            naviCon = UINavigationController(rootViewController: rootVC!)
        }else if strRoot == "enterApp" {
            rootVC = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController
            naviCon = UINavigationController(rootViewController: rootVC!)
        }else if strRoot == "Explore" {
            rootVC = storyboard?.instantiateViewController(withIdentifier: "ExploreVC") as? ExploreViewController
            naviCon = UINavigationController(rootViewController: rootVC!)
        }else if strRoot == "Discussion" {
            rootVC = storyboard?.instantiateViewController(withIdentifier: "DiscussionVC") as? DiscussionViewController
            naviCon = UINavigationController(rootViewController: rootVC!)
        }
        
        let leftViewController: LeftViewController = storyboard!.instantiateViewController(withIdentifier: "LeftVC") as! LeftViewController
        
        self.LGSideMenu = LGSideMenuController(rootViewController: naviCon, leftViewController: leftViewController, rightViewController: nil)
        self.LGSideMenu?.isLeftViewSwipeGestureEnabled = false
        self.LGSideMenu?.leftViewPresentationStyle = .slideAbove
        self.LGSideMenu?.rootViewLayerShadowRadius = 15.0
        self.LGSideMenu?.leftViewWidth = self.window!.layer.frame.width - 50
        self.window?.rootViewController = self.LGSideMenu
        
        window?.makeKeyAndVisible()
        UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: { _ in })
        
    }


}

