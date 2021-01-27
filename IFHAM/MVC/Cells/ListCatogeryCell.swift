//
//  CatogeryCell.swift
//  IFHAM
//
//  Created by AngelDev on 6/1/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import Kingfisher

class ListCatogeryCell: UICollectionViewCell {
    
    @IBOutlet weak var imgUniLogo: UIImageView!
    @IBOutlet weak var txvUniName: UITextView!
    
    var entity : CategoryModel! {
        didSet{
            if entity.imgName.starts(with: "http") {
                imgUniLogo.kf.setImage(with: URL(string: entity.imgName), placeholder: UIImage(named: "placeholder"))
            } else {
                if let img = UIImage(named: entity.imgName) {
                    imgUniLogo.image = img
                }
            }
            
            txvUniName.text = entity.title
        }
    }
}
