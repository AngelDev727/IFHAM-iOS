//
//  ContactUsVC.swift
//  IFHAM
//
//  Created by AngelDev on 6/3/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import SideMenu

class ContactUsVC: BaseAndMenuVC {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txvContent: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }
    
    func initView() {
        self.title = "Contact Us"
        
//        showMenuItem()
        setNavigationBarColors()
    }

    @IBAction func didTapSend(_ sender: Any) {
        let username = txtUsername.text!
        let email = txtEmail.text!
        let content = txvContent.text!
        
        if username.isEmpty {
            
            self.showError(CONSTANT.ERR_USERNAME)
            return
        }

        if !isValidEmail(email) {
            self.showError(CONSTANT.ERR_EMAIL)
            return
        }

        if content.isEmpty {
            self.showAlert(CONSTANT.ERR_CONTENT)
            return
        }
        
        let data = [
            "user_id"       : UserDefaults.standard.string(forKey: CONSTANT.KEY_USERID)!,
            "user_name"     : username,
            "user_email"    : email,
            "content_text"  : content
        ] 
        
        self.showLoadingView(vc: self, label: CONSTANT.LOADING_TEXT_REQ)
        APIManager.shared.sendContactus(data) { (result_code, msg) in
            self.hideLoadingView()
            if result_code == CONSTANT.CODE_SUCCESS || result_code == CONSTANT.CODE_201 {
                self.showAlert(msg)
                
                self.txtUsername.text = ""
                self.txtEmail.text = ""
                self.txvContent.text = ""
                
            } else {
                self.showError("Sonthing's wrong.")
            }
        }
    }
    
    
}
