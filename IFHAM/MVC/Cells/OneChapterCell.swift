//
//  OneChapterCell.swift
//  IFHAM
//
//  Created by AngelDev on 6/4/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import AIFlatSwitch

class OneChapterCell: UITableViewCell {

    @IBOutlet weak var imgThumnail: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblChapther: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblPaid: EdgeInsetLabel!
    @IBOutlet weak var flatCheck: AIFlatSwitch!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    var entity: VideoChapterModel! {
        didSet {
            if entity.subject_logo.starts(with: "http") {
                imgThumnail.kf.setImage(with: URL(string: entity.subject_logo), placeholder: UIImage(named: "placeholder"))
            } else {
                if let img = UIImage(named: entity!.subject_logo) {
                    imgThumnail.image = img
                }
            }
            
            if entity.is_paid == 1 {
                lblPaid.text = "PAID"
                lblPaid.backgroundColor = CONSTANT.COLOR_LIGHT_PRIMARY
            } else if entity.video_price == 0 {
                lblPaid.text = "FREE"
                lblPaid.backgroundColor = CONSTANT.COLOR_LIGHT_PRIMARY
            } else {
                lblPaid.text = "\(entity.video_price)KWD"
                lblPaid.backgroundColor = CONSTANT.COLOR_YELLOW
            }
            lblTitle.text       = entity.video_name
            lblChapther.text    = "Chapter \(entity.chapter_num)"
            
            let sec = entity.video_time % 60
            let min = (entity.video_time - sec) / 60 % 60
            let hr = (entity.video_time - min * 60 - sec) / 3600
            
            lblTime.text  = String("0\(hr):".suffix(3) + "0\(min):".suffix(3) + "0\(sec)".suffix(2))
        }
    }

}
