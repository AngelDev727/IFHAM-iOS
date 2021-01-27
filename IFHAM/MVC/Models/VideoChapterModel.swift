//
//  VideoChapter.swift
//

import Foundation
import SwiftyJSON

class VideoChapterModel {
    
    var video_name      = ""
    var uni_id          = 0
    var subject_id      = 0
    var subject_logo    = ""
    var chapter_num     = 0
    var video_price : Float = 0.0
    var video_time      = 0
    var is_paid         = 0
    var pay_type        = ""
    var kind            = ""
    
    init(dict : JSON, kind: String) {
        
        self.video_name     = dict["video_name"].stringValue
        self.uni_id         = dict["uni_id"].intValue
        self.subject_id     = dict["subject_id"].intValue
        self.subject_logo   = dict["subject_logo"].stringValue
        self.chapter_num    = dict["chapter_num"].intValue
        self.video_price    = dict["video_price"].floatValue
        self.video_time     = dict["video_time"].intValue
        self.is_paid        = dict["is_paid"].intValue
        self.pay_type       = dict["pay_type"].stringValue
        self.kind           = kind
    }
}
