//
//  SubjectModel.swift
//  IFHAM
//
//  Created by AngelDev on 6/3/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import SwiftyJSON

class SubjectModel {
    
    var row_id          = 0
    var subject_title   = ""
    var subject_img     = ""
    var preview_video   = ""
    var kind            = ""
    
    init(row_id: Int, subject_title: String, subject_img: String, kind: String) {
        
        self.row_id         = row_id
        self.subject_title  = subject_title
        self.subject_img    = subject_img
        self.kind           = kind
    }
    
    init(dict : JSON ) {
        self.row_id         = dict["row_id"].intValue
        self.subject_title  = dict["subject_title"].stringValue
        self.subject_img    = dict["subject_img"].stringValue
        self.preview_video  = dict["preview_video"].stringValue
        self.kind           = dict["kind"].stringValue
    }
}
