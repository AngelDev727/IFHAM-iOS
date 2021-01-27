//
//  CategoryModel.swift
//  IFHAM
//
//  Created by AngelDev on 6/1/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import Foundation
import SwiftyJSON

class CategoryModel {
    
    var row_id  = 0
    var title   = ""
    var short_name = ""
    var imgName = ""
    var kind    = ""
    var preview_video = ""
    
    init(title : String, imgName :String, kind: String) {
        
        self.title    = title
        self.imgName  = imgName
        self.kind     = kind
    }
    
    init(dict : JSON ) {

        self.row_id     = dict["row_id"].intValue
        
        if dict["uni_name"].exists() {
            /// university category
            self.title      = dict["uni_name"].stringValue
            self.short_name = dict["short_name"].stringValue
            self.imgName    = dict["uni_logo"].stringValue
            
        } else if dict["subject_name"].exists() {
            /// igcse category
            self.title      = dict["subject_name"].stringValue
            self.imgName    = dict["subject_logo"].stringValue
            
        } else if dict["book_name"].exists() {
            /// book solution  and test bank category
            self.title      = dict["book_name"].stringValue
            self.imgName    = dict["book_logo"].stringValue
            
        } else {
            // does not contain key
        }
    }
    
    init(dict : JSON, kind: String ) {

        self.row_id     = dict["row_id"].intValue
        self.kind       = kind
        
        if dict["uni_name"].exists() {
            /// university category
            self.title      = dict["uni_name"].stringValue
            self.short_name = dict["short_name"].stringValue
            self.imgName    = dict["uni_logo"].stringValue
            
        } else if dict["subject_name"].exists() {
            /// igcse category
            self.title      = dict["subject_name"].stringValue
            self.imgName    = dict["subject_logo"].stringValue
            
        } else if dict["book_name"].exists() {
            /// book solution  and test bank category
            self.title      = dict["book_name"].stringValue
            self.imgName    = dict["book_logo"].stringValue
            
        } else {
            // does not contain key
        }
        
        if dict["preview_video"].exists() {
            self.preview_video = dict["preview_video"].stringValue
            print("preview_video=======>", self.preview_video)
        }
    }
}
