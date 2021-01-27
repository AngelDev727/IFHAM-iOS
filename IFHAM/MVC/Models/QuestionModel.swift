//
//  QuestionModel.swift
//  IFHAM
//
//  Created by AngelDev on 6/4/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import SwiftyJSON

class QuestionModel {
    var row_id      = 0
    var user_id     = 0 // if user_id == 0 user is admin, else user
    var user_name   = ""
    var photo_url   = ""
    var timestamp   = 0
    var question    = ""
    var kind        = ""
    
    init(row_id: Int, user_id: Int, user_name: String, photo_url: String, timestamp: Int, question: String) {
        
        self.row_id     = row_id
        self.user_id    = user_id
        self.user_name  = user_name
        self.photo_url  = photo_url
        self.timestamp  = timestamp
        self.question   = question
    }
    
    init(dict : JSON, kind: String) {
        
        self.row_id         = dict["row_id"].intValue
        self.user_id        = dict["user_id"].intValue
        self.photo_url      = dict["photo_url"].stringValue
        self.user_name      = dict["full_name"].stringValue
        self.timestamp      = dict["created_date"].intValue
        self.question       = dict["question"].stringValue
        self.kind           = kind
    }
}
