//
//  MFPaymentCell.swift
//  IFHAM
//
//  Created by AngelDev on 7/2/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import MFSDK

import Kingfisher

class MFPaymentCell: UICollectionViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var paymentMethodImageView: UIImageView!
    @IBOutlet weak var paymentMethodNameLabel: UILabel!
    
    //MARK:- Methods
    func configure(paymentMethod: MFPaymentMethod, selected: Bool) {
        paymentMethodImageView.image = nil
        self.layer.cornerRadius = 5
        if selected {
            self.layer.borderColor = UIColor.black.cgColor
            self.layer.borderWidth = 2
        } else {
            self.layer.borderColor = UIColor.darkGray.cgColor
            self.layer.borderWidth = 0
        }
        if let imageURL = paymentMethod.imageUrl {
//            paymentMethodImageView.downloaded(from: imageURL)
            paymentMethodImageView.kf.setImage(with: URL(string: imageURL), placeholder: UIImage(named: "placeholder"))
            
        }
        paymentMethodNameLabel.text = paymentMethod.paymentMethodEn ?? ""
    }
}
