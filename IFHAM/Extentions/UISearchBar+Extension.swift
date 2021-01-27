//
//  Extention+UISearchBar.swift
//  IFHAM
//
//  Created by AngelDev on 6/3/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit

extension UISearchBar {
    func setPlaceholderTextColorTo(textColor: UIColor, placeholderColor: UIColor) {
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = textColor
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = placeholderColor
    }
    
    func getTextField() -> UITextField? { return value(forKey: "searchField") as? UITextField }
    func setTextFieldBGColor(bgcolor: UIColor, borderWidth: CGFloat, borderColor: UIColor) {
        guard let textField = getTextField() else { return }
        switch searchBarStyle {
            case .minimal:
                textField.layer.backgroundColor = bgcolor.cgColor
                textField.layer.cornerRadius = 10
                textField.borderWidth = borderWidth
                textField.borderColor = borderColor
            case .prominent, .default: textField.backgroundColor = bgcolor
            @unknown default: break
        }
    }

    func setMagnifyingGlassColorTo(color: UIColor, image: UIImage? = nil) {
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        
        if let img = image {
            glassIconView?.image = img.withRenderingMode(.alwaysTemplate)
        } else {
            glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        }
        glassIconView?.tintColor = color
    }
    
    func setClearButtonColorTo(color: UIColor, image: UIImage? = nil){
        // Clear Button
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        let crossIconView = textFieldInsideSearchBar?.value(forKey: "clearButton") as? UIButton
        crossIconView?.setImage(crossIconView?.currentImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        crossIconView?.setImage(crossIconView?.currentImage?.withRenderingMode(.alwaysTemplate), for: .highlighted)
        crossIconView?.setImage(crossIconView?.currentImage?.withRenderingMode(.alwaysTemplate), for: .selected)
        crossIconView?.setImage(crossIconView?.currentImage?.withRenderingMode(.alwaysTemplate), for: .focused)
        crossIconView?.setImage(crossIconView?.currentImage?.withRenderingMode(.alwaysTemplate), for: .application)
        
        if let img = image {
            crossIconView?.setImage(img.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            crossIconView?.setImage(crossIconView?.currentImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        
        crossIconView?.tintColor = color
    }
}

@IBDesignable
class CustomSearchBar: UISearchBar {
    @IBInspectable var searchImage: UIImage? {
        didSet {
            let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
            let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
            glassIconView?.image = searchImage
        }
    }
    @IBInspectable var searchImageColor: UIColor? {
        didSet {            
            let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
            let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
            glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
            glassIconView?.tintColor = searchImageColor
        }
    }
    
    @IBInspectable var placeholderColor: UIColor? {
        didSet {
            let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
            let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
            textFieldInsideSearchBarLabel?.textColor = placeholderColor
        }
    }

    @IBInspectable var textColor: UIColor? {
        didSet {
            let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
            textFieldInsideSearchBar?.textColor = textColor
        }
    }

    @IBInspectable var magnifyingGlassColor: UIColor? {

        didSet {
            if let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField,
                let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {

                //Magnifying glass
                glassIconView.image = glassIconView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                glassIconView.tintColor = magnifyingGlassColor
            }
        }
    }
}
