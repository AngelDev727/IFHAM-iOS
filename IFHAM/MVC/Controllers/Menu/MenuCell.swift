//
//  MenuCell.swift
//  IFHAM
//
//  Created by AngelDev on 5/30/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

class MenuCell: UITableViewVibrantCell {
    
    @IBOutlet weak var imgMenuIcon: UIImageView!
    @IBOutlet weak var lblMenuName: UILabel!
    @IBOutlet weak var swiNotification: UISwitch!
    
    private var vibrancyView: UIVisualEffectView = UIVisualEffectView()
    private var vibrancySelectedBackgroundView: UIVisualEffectView = UIVisualEffectView()
    private var defaultSelectedBackgroundView: UIView?
    open override var blurEffectStyle: UIBlurEffect.Style? {
        didSet {
            updateBlur()
        }
    }
    
    // For registering with UITableView without subclassing otherwise dequeuing instance of the cell causes an exception
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        vibrancyView.frame = bounds
        vibrancyView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        for view in subviews {
            vibrancyView.contentView.addSubview(view)
        }
        addSubview(vibrancyView)
        
        let blurSelectionEffect = UIBlurEffect(style: .light)
        vibrancySelectedBackgroundView.effect = blurSelectionEffect
        defaultSelectedBackgroundView = selectedBackgroundView
        
        updateBlur()
    }
    
    internal func updateBlur() {
        // shouldn't be needed but backgroundColor is set to white on iPad:
        backgroundColor = UIColor.clear
        
        if let blurEffectStyle = blurEffectStyle, !UIAccessibility.isReduceTransparencyEnabled {
            let blurEffect = UIBlurEffect(style: blurEffectStyle)
            vibrancyView.effect = UIVibrancyEffect(blurEffect: blurEffect)
            
            if selectedBackgroundView != nil && selectedBackgroundView != vibrancySelectedBackgroundView {
                vibrancySelectedBackgroundView.contentView.addSubview(selectedBackgroundView!)
                selectedBackgroundView = vibrancySelectedBackgroundView
            }
        } else {
            vibrancyView.effect = nil
            selectedBackgroundView = defaultSelectedBackgroundView
        }
    }
    
}
