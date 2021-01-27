//
//  BaseVC.swift
//  Parrot
//
//  Created by AngelDev on 4/28/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import Foundation
import UIKit
import SwiftyUserDefaults
import MBProgressHUD
import IQKeyboardManagerSwift
import PDFKit
import Toast_Swift

class BaseVC: UIViewController {
    
    var hud: MBProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        // to enable swiping left when back button in navigation bar customized
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style:.plain, target:nil, action:nil)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    //MARK:- alert function
    internal func showAlert(title: String?, message: String?, okButtonTitle: String, cancelButtonTitle: String?, okClosure: (() -> Void)?, cancelClosure: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: okButtonTitle, style: .destructive, handler: { (action: UIAlertAction) in
            if okClosure != nil {
                okClosure!()
            }
        })
        
        alertController.addAction(yesAction)
        if cancelButtonTitle != nil {
            let noAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: { (action: UIAlertAction) in
                cancelClosure!()
            })
            alertController.addAction(noAction)
        }

        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertDialog(title: String!, message: String!, positive: String?, negative: String?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if (positive != nil) {
            alert.addAction(UIAlertAction(title: positive, style: .default, handler: nil))
        }
        
        if (negative != nil) {
            alert.addAction(UIAlertAction(title: negative, style: .default, handler: nil))
        }
        
        DispatchQueue.main.async(execute:  {
            self.present(alert, animated: true, completion: nil)
        })
    }

    func showError(_ message: String!) {
        showAlertDialog(title: CONSTANT.APP_NAME, message: message, positive: nil, negative: "OK")
    }

    func showAlert(_ message: String!) {
        showAlertDialog(title: CONSTANT.APP_NAME, message: message, positive: "OK", negative: nil)
    }
    
    func showAlertOpenDeviceSettings(title: String!, message: String!) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // Button to Open Settings
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { action in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
   

    //MARK:- Toast function
    func showToast(_ message : String, duration: TimeInterval = ToastManager.shared.duration, position: ToastPosition = .bottom) {
        self.view.makeToast(message, duration: duration, position: position)
    }
    
    func showToastCenter(_ message : String, duration: TimeInterval = ToastManager.shared.duration) {
        showToast(message, duration: duration, position: .center)
    }
    
    //MARK:- check email
    func isValidEmail(_ testStr: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    //MARK:- goto navigation view controller function
    func gotoNavVC (_ nameVC: String) {
        
        let toVC = self.storyboard?.instantiateViewController( withIdentifier: nameVC)
        toVC!.modalPresentationStyle = .fullScreen
        
        self.navigationController?.pushViewController(toVC!, animated: true)
    }
    
    func doDismiss(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func doRootDismiss(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK:- goto view controller function
    func gotoVC(_ nameVC: String, _ animated: Bool = false){
        
        let toVC = self.storyboard?.instantiateViewController( withIdentifier: nameVC)
        toVC!.modalPresentationStyle = .fullScreen
        self.present(toVC!, animated: animated, completion: nil)
    }
    
    func openPDFFromURL(_ urlString : String) {
        let toVC = self.storyboard?.instantiateViewController( withIdentifier: "OnePDFVC") as! OnePDFVC
        toVC.modalPresentationStyle = .fullScreen
        toVC.pdfURLString = urlString
        self.navigationController?.pushViewController(toVC, animated: true)
    }
    
    func donwnloadandOpen(_ urlString : String) {
        let toVC = self.storyboard?.instantiateViewController( withIdentifier: "OnePDFVC") as! OnePDFVC
        toVC.modalPresentationStyle = .fullScreen
        toVC.pdfURLString = urlString
        self.navigationController?.pushViewController(toVC, animated: true)
    }
    
    func openPDFFromURL(_ obj : PDFdocModel) {
        let toVC = self.storyboard?.instantiateViewController( withIdentifier: "OnePDFVC") as! OnePDFVC
        toVC.modalPresentationStyle = .fullScreen
        toVC.onePdfData = obj
        self.navigationController?.pushViewController(toVC, animated: true)
    }
    
    //set dispaly effect
    func setTransitionType(_ direction : CATransitionSubtype) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = direction
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.linear)
        
        view.window!.layer.add(transition, forKey: kCATransition)
    }
    
    //MARK:- progressHUD function
    func showProgressHUD(view : UIView, mode: MBProgressHUDMode = .annularDeterminate) -> MBProgressHUD {
    
        let hud = MBProgressHUD .showAdded(to:view, animated: true)
        hud.mode = mode
        hud.label.text = "Loading";
        hud.animationType = .zoomIn
        hud.tintColor = UIColor.white
        hud.contentColor = CONSTANT.COLOR_ORANGE
        return hud
    }
    
    func showLoadingView(label: String = "") {

        let window = UIApplication.shared.key!.rootViewController

        if window != nil {
            hud = MBProgressHUD .showAdded(to: window!.view, animated: true)
        } else {
            hud = MBProgressHUD()
        }
        
        if label != "" {
            hud!.label.text = label;
        }
        
        hud!.mode = .indeterminate
        hud!.animationType = .zoomIn
        hud!.tintColor = UIColor.gray
        hud!.contentColor = CONSTANT.COLOR_ORANGE
    }
    
    func showLoadingView(vc: UIViewController, label: String = "") {
        
        hud = MBProgressHUD .showAdded(to: vc.view, animated: true)
        
        if label != "" {
            hud!.label.text = label;
        }
        hud!.mode = .indeterminate
        hud!.animationType = .zoomIn
        hud!.tintColor = UIColor.gray
        hud!.contentColor = CONSTANT.COLOR_ORANGE
    }
    
    func hideLoadingView() {
       if let hud = hud {
           hud.hide(animated: true)
       }
    }
    
    func gotoCategoryItemPage(_ categoryType: CategeryType ) {
        
        gotoNavVC(viewOnePageNames[categoryType.rawValue])
    }
    
    //Code validation method
    func isValidCode(_ testStr:String) -> Bool {
        if testStr.length >= 4 {
            return true
        }
        return false
    }
    
}


//MARK:- swiftyuserDefaultsKeys extention
extension DefaultsKeys {
    var enableNoti : DefaultsKey<Bool>{ return .init("enableNoti", defaultValue: false)}
}

//MARK:- UIViewController extention
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
