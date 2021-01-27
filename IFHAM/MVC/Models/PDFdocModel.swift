//
//  PDFdocModel.swift
//  IFHAM
//
//  Created by AngelDev on 6/2/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import Foundation
import SwiftyJSON

class PDFdocModel {
    
    var row_id          = 0
    var doc_title       = ""
    var chapter_num     = 0
    var doc_url         = ""
    var subject_id      = 0
    var subject_logo    = ""
    var subject_name    = ""
    var subject_shortname = ""
    var kind            = ""
    
    init(dict : JSON, kind: String) {

        self.row_id         = dict["row_id"].intValue
        self.doc_title      = dict["doc_title"].stringValue
        self.chapter_num    = dict["chapter_num"].intValue
        self.doc_url        = dict["doc_url"].stringValue
        self.subject_id     = dict["book_id"].intValue
        self.subject_logo   = dict["book_logo"].stringValue
        self.subject_name   = dict["book_name"].stringValue
        self.subject_shortname   = dict["chapter_name"].stringValue
        self.kind           = kind
    }
}
