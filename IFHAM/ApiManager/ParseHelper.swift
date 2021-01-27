//
//  ParseHelper.swift
//  IFHAM
//
//  Created by AngelDev on 6/23/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import SwiftyJSON

class ParseHelper {
    
    static func parseUser(_ userObject: JSON) -> UserModel {
        
        let user = UserModel()
        
        user.user_id        = userObject["row_id"].intValue
        user.full_name      = userObject["full_name"].stringValue
        user.email          = userObject["email"].stringValue
        user.country_code   = userObject["country_code"].stringValue
        user.dialing_code   = "+" + userObject["dialing_code"].stringValue
        user.phone_num      = userObject["phone_num"].stringValue
        user.photo_url      = userObject["photo_url"].stringValue
        user.badge_count    = userObject["badge_count"].intValue
        user.promo_id       = userObject["device_type"].intValue
        user.promo_code     = userObject["promo_code"].stringValue
        user.expire_date    = userObject["expire_date"].stringValue

        return user
    }
    
}
