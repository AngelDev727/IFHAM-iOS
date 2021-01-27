//
//  UIView+Visibility.swift.swift
//  bumerang
//
//  Created by RMS on 2019/10/5.
//  Copyright © 2019 RMS. All rights reserved.
//
import UIKit

extension UILabel {
    @IBInspectable
    var rotation: Int {
        get {
            return 0
        } set {
            let radians = CGFloat(CGFloat(Double.pi) * CGFloat(newValue) / CGFloat(180.0))
            self.transform = CGAffineTransform(rotationAngle: radians)
        }
    }
}
