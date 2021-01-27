//
//  UserModel.swift
//  IFHAM
//
//  Created by AngelDev on 5/30/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import Foundation

class UserModel {
    
    var user_id: Int    = 0
    var full_name       = ""
    var email           = ""
    var country_code    = ""
    var dialing_code    = ""
    var phone_num       = ""
    var photo_url       = ""
    var badge_count     = 0
    var promo_id        = 0
    var promo_code      = ""
    var expire_date     = ""
    
    var device_token: String {
        get {
            if deviceTokenString != "" {
                return deviceTokenString
            } else if let token = UserDefaults.standard.value(forKey: CONSTANT.KEY_TOKEN) {
                return token as! String
            }
            return ""
        }
    }
    
    // Clear save user credential
    func clearUserInfo() {
        
        user_id         = 0
        full_name       = ""
        email           = ""
        country_code    = ""
        dialing_code    = ""
        phone_num       = ""
        photo_url       = ""
        badge_count     = 0
        promo_id        = 0
        promo_code      = ""
        expire_date     = ""
        
//        UserDefault.setInt(key: PARAMS.ID, value: 0)
       
        UserDefaults.standard.set("", forKey: CONSTANT.KEY_NAME)
        UserDefaults.standard.set(0, forKey: CONSTANT.KEY_USERID)
        UserDefaults.standard.set("", forKey: CONSTANT.KEY_PHOTO)
        UserDefaults.standard.set("", forKey: CONSTANT.KEY_CCOUNTRY_CODE)
        UserDefaults.standard.set("", forKey: CONSTANT.KEY_DIALING_CODE)
        UserDefaults.standard.set("", forKey: CONSTANT.KEY_PHONE_NUM)
        UserDefaults.standard.set("", forKey: CONSTANT.KEY_PROMOCODE_ID)
        UserDefaults.standard.set("", forKey: CONSTANT.KEY_PROMOCODE)
        UserDefaults.standard.set("", forKey: CONSTANT.KEY_EXPIRE_DATE)
    }
}

var currentUser : UserModel? {
    didSet {
        if let user = currentUser {
            UserDefaults.standard.set(user.full_name, forKey: CONSTANT.KEY_NAME)
            UserDefaults.standard.set(user.user_id, forKey: CONSTANT.KEY_USERID)
            UserDefaults.standard.set(user.photo_url, forKey: CONSTANT.KEY_PHOTO)
            UserDefaults.standard.set(user.country_code, forKey: CONSTANT.KEY_CCOUNTRY_CODE)
            UserDefaults.standard.set(user.dialing_code, forKey: CONSTANT.KEY_DIALING_CODE)
            UserDefaults.standard.set(user.phone_num, forKey: CONSTANT.KEY_PHONE_NUM)
            UserDefaults.standard.set(user.promo_id, forKey: CONSTANT.KEY_PROMOCODE_ID)
            UserDefaults.standard.set(user.promo_code, forKey: CONSTANT.KEY_PROMOCODE)
            UserDefaults.standard.set(user.expire_date, forKey: CONSTANT.KEY_EXPIRE_DATE)
        }
    }
}
