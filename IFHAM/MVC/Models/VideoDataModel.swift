//
//  VideoDataModel.swift
//  IFHAM
//
//  Created by AngelDev on 6/1/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import SwiftyJSON

class VideoDataModel {
    
    var row_id          = 0
    var uni_id          = 0
    var subject_id      = 0
    var chapter_num     = 0
    var order_num       = 0
    var video_name      = ""
    var instructor_name = ""
    var video_url       = ""
    var video_price: Float = 0.0
    var video_time      = 0
    var is_paid         = 0
    var pay_type        = ""
    var kind            = ""
    
    init(dict : JSON, kind: String) {
        self.row_id         = dict["row_id"].intValue
        self.uni_id         = dict["uni_id"].intValue
        self.subject_id     = dict["subject_id"].intValue
        self.order_num      = dict["order_num"].intValue
        self.chapter_num    = dict["chapter_num"].intValue
        self.video_name     = dict["video_name"].stringValue
        self.instructor_name = dict["instructor_name"].stringValue
        self.video_url      = dict["video_url"].stringValue
        self.video_price    = dict["video_price"].floatValue
        self.video_time     = dict["video_time"].intValue
        self.is_paid        = dict["is_paid"].intValue
        self.pay_type       = dict["pay_type"].stringValue
        self.kind           = kind
    }
}
