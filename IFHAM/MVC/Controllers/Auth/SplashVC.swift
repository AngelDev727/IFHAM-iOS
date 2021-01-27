//
//  SplashVC.swift
//
//  Created by AngelDev on 5/14/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit

class SplashVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        perform(#selector(gotoLogin), with: self, afterDelay: 1)
//        perform(#selector(gotoLogin))
    }

    @objc func gotoLogin() {
        
        let loginState = UserDefaults.standard.bool(forKey: CONSTANT.KEY_LOGIN_STATE)
        
        if loginState {
            
            let user_id = UserDefaults.standard.string(forKey: CONSTANT.KEY_USERID)!
            
            if !Reachability.isConnected() {
                showError(R.string.U_CANNOT_CONNECT)
                return
            }
            
            APIManager.shared.getUserData(user_id) { (result_code, msg) in
                if result_code == CONSTANT.CODE_SUCCESS {

                    if let token = currentUser?.device_token, token != "" {
                        APIManager.shared.updateToken(token) { (result_code, msg )  in }
                    }
                    
                    self.gotoVC("HomeNav")
                } else {
                    self.showAlert(msg)
                }
            }
            
        } else {
            self.gotoVC("LoginNav")
        }
    }
}
