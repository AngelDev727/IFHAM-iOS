//
//  UIText+Extension.swift
//  bumerang
//
//  Created by RMS on 2019/9/15.
//  Copyright © 2019 RMS. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
    func setPaddingSpace(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        self.textContainerInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
    func setSamePaddingSpace(val: CGFloat) {
        self.textContainerInset = UIEdgeInsets(top: val, left: val, bottom: val, right: val)
    }
}
