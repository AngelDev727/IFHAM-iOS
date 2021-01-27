//
//  OnePDFCell.swift
//  IFHAM
//
//  Created by AngelDev on 6/3/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit

class OnePDFCell: UITableViewCell {
    
    @IBOutlet weak var imgBookLogo: UIImageView!
    @IBOutlet weak var lblChapterNum: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    var entity: PDFdocModel! {
        didSet {
            if entity.subject_logo.starts(with: "http") {
                imgBookLogo.kf.setImage(with: URL(string: entity.subject_logo), placeholder: UIImage(named: "placeholder"))
            } else {
                if let img = UIImage(named: entity!.subject_logo) {
                    imgBookLogo.image = img
                }
            }
            
            lblChapterNum.text  = "Chapter \(entity.chapter_num)"
            lblPrice.text       = entity.doc_title
        }
    }
}
