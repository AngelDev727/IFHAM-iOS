//
//  OneVideoCell.swift
//  IFHAM
//
//  Created by AngelDev on 6/2/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import Kingfisher
import AIFlatSwitch

class OneVideoCell: UITableViewCell {

    @IBOutlet weak var viwContainer: UIView!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var flatCheck: AIFlatSwitch!
    @IBOutlet weak var lblPaid: EdgeInsetLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    var entity: VideoDataModel! {
        didSet {
            let orderStr    = "\(entity.chapter_num)" + "0\(entity.order_num)".suffix(2)
            lblTitle.text   = entity.video_name + ", " + orderStr
            lblNumber.text  = "\(entity.order_num)"
            
            let sec = entity.video_time % 60
            let min = (entity.video_time - sec) / 60 % 60
            let hr = (entity.video_time - min * 60 - sec) / 3600
            
//            lblTime.text        = "\(hr) : \(min) : \(sec)"
            lblTime.text  = String("0\(hr):".suffix(3) + "0\(min):".suffix(3) + "0\(sec)".suffix(2))
            lblPaid.isHidden = true
            
            if entity.is_paid == 1 {
                lblPaid.text = "PAID"
                lblPaid.backgroundColor = CONSTANT.COLOR_LIGHT_PRIMARY
            } else if entity.video_price == 0 {
                lblPaid.text = "FREE"
                lblPaid.backgroundColor = CONSTANT.COLOR_LIGHT_PRIMARY
            } else {
                lblPaid.text = "\(entity.video_price) KWD"
                lblPaid.backgroundColor = CONSTANT.COLOR_YELLOW
            }
                
        }
    }
}
