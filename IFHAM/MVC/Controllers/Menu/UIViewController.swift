//
//  UIViewControllerExtension.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 1/19/15.
//  Copyright (c) 2015 Yuji Hato. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showMenuItem() {
        self.addLeftBarButtonWithImage(UIImage(named: "ic_menu")!)
        self.navigationController?.navigationBar.barTintColor = CONSTANT.COLOR_LIGHT_PRIMARY
    }
    
    func removeNavigationBarItem() {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
    }
    
    public func addLeftBarButtonWithImage(_ buttonImage: UIImage) {
        let leftButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.toggleLeft))
        
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.leftBarButtonItem!.tintColor = UIColor(named: "yellowBut")
    }
    
    public func addRightBarButtonWithImage(_ buttonImage: UIImage) {
        let rightButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.toggleRight))
        navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc public func toggleLeft() {
        let toVC = self.storyboard?.instantiateViewController( withIdentifier: "LeftMenuNav")
        toVC!.modalPresentationStyle = .overCurrentContext
        self.present(toVC!, animated: true, completion: nil)
    }
    

    @objc public func toggleRight() {
        let toVC = self.storyboard?.instantiateViewController( withIdentifier: "RightMenuNav")
        toVC!.modalPresentationStyle = .overCurrentContext
        self.present(toVC!, animated: true, completion: nil)
    }
    
}
