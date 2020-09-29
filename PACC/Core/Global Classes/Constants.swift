//
//  Constants.swift
//  PACC
//
//  Created by RSS on 4/19/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit

let merchant_id: String = "merchant.com.ahl.pacccom" // "merchant.com.ahl.PACC.ApplePaySwag" merchant.com.ahl.pacccom
let live_key = "pk_live_KMoTjopZRxkz6Fb5b8W0l2pJ"
let secret_key = "sk_live_SmGGQ878EBhLrLvL59HJhDsU"
let MAX_VALUE: Float = 200
let MIN_HEIGHT1: Float = 60
let MIN_HEIGHT2: Float = 96

struct AppTheme {
    static let light_green: UIColor = UIColor(red: 127 / 255.0, green: 187 / 255.0, blue: 152 / 255.0, alpha: 1.0)
    static let light_gray: UIColor = UIColor(red: 230 / 255.0, green: 230 / 255.0, blue: 230 / 255.0, alpha: 1.0)
    static let white: UIColor = UIColor.white
}
struct Constant {
    struct UI {
        static let TAP_BAR_HEIGHT: CGFloat = 60
        static let COMMON_BUTTON_HEIGHT = 40
        static var SCREEN_WIDTH: CGFloat {
            return UIScreen.main.bounds.width
        }
        
        static let ROW_HEIGHT: CGFloat = 40
        
        static let HORZ_MARGIN: CGFloat = 20
    }
}

struct APIURL {
    private static var Base: String {
        get {
            return "https://www.pennsylvaniacannabisconnection.com"
        }
    }
    static let fir_db: String = "https://pacc-dc3ea.firebaseio.com/"
    static let fir_storage: String = "gs://pacc-dc3ea.appspot.com/"
    static let login: String = "\(Base)/_functions-dev/login/"
    static let register: String = "\(Base)/_functions-dev/register/"
    static let list_collection: String = "\(Base)/_functions-dev/list/"  // {collectionname}
    static let item_infor: String = "\(Base)/_functions-dev/item_infor/"  //{collectionname}/{itemid}
    static let delete_item: String = "\(Base)/_functions-dev/item_delete/"  //{collectionname}/{itemid}
    static let update_item: String = "\(Base)/_functions-dev/item_update/"
    static let insert_item: String = "\(Base)/_functions-dev/item_insert/"  //{collectionname}
         // New apis
    static let followers: String = "\(Base)/_functions-dev/followers/"  // {following}
    static let followings: String = "\(Base)/_functions-dev/followings/"  // {follower}
    static let linked_business: String = "\(Base)/_functions-dev/linked_businesses/" // {linked_business}
    static let existing_business: String = "\(Base)/_functions-dev/existing_business/" // {current_business}
    static let create_charge: String = "https://api.stripe.com/v1/charges"
}

