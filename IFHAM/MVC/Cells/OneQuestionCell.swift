//
//  OneQuestionCell.swift
//  IFHAM
//
//  Created by AngelDev on 6/4/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import Kingfisher

class OneQuestionCell: UITableViewCell {
    
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var lblUserTypeAndName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblQuestion: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var entity: QuestionModel! {
        didSet {
            
            if entity.user_id > 0 {
                imgPhoto.kf.setImage(with: URL(string: entity.photo_url), placeholder: UIImage(named: "profile"))
                lblUserTypeAndName.textColor = CONSTANT.COLOR_LIGHT_PRIMARY
                lblUserTypeAndName.text = "Student: " + entity.user_name
            } else {
                imgPhoto.image = UIImage(named: "profile")
                lblUserTypeAndName.textColor = CONSTANT.COLOR_PRIMARY
                lblUserTypeAndName.text = "Teacher: " + entity.user_name
            }
            
            lblTime.text        = getDateStringFromTimeStamp("\(entity.timestamp)", toFormat: "MM dd, yyyy HH:mm")
            lblQuestion.text    = entity.question
            lblQuestion.numberOfLines = 0
            
            
        }
    }
}
