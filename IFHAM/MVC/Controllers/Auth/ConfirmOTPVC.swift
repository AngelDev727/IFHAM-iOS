//
//  ConfirmOTPVC.swift
//  IFHAM
//
//  Created by AngelDev on 5/29/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import KAPinField
import FirebaseAuth

class ConfirmOTPVC: BaseVC {
    
    @IBOutlet weak var otpCodeView: KAPinField!
    @IBOutlet weak var butResendCode: UIButton!
    
    @IBOutlet weak var lblYourOTP: UILabel!
    @IBOutlet weak var lblPhoneNum: UILabel!
    @IBOutlet weak var lblIhave: UILabel!
    
    private var dialingCode = ""
    private var phoneNum = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        
        self.navigationController?.isNavigationBarHidden = true
        
        dialingCode = UserDefaults.standard.string(forKey: CONSTANT.KEY_DIALING_CODE)!
        phoneNum = UserDefaults.standard.string(forKey: CONSTANT.KEY_PHONE_NUM)!
        lblYourOTP.text = "Enter your OTP"
        lblPhoneNum.text = "Enter the OTP sent to " + dialingCode + phoneNum
        lblIhave.text = "Didn't receice OTP? "
        butResendCode.setTitle("Resent Code", for: .normal)
        setStyle()
    }
   
    func setStyle() {
        
        otpCodeView.properties.delegate = self
//        otpCodeView.properties.token = "-"
        otpCodeView.properties.animateFocus = true
        otpCodeView.text = ""
        otpCodeView.keyboardType = .numberPad
        otpCodeView.properties.numberOfCharacters = 6
        otpCodeView.appearance.tokenColor = UIColor.black.withAlphaComponent(0.2)
        otpCodeView.appearance.tokenFocusColor = UIColor.black.withAlphaComponent(0.2)
        otpCodeView.appearance.textColor = UIColor.black
        otpCodeView.appearance.font = .menlo(30)
        otpCodeView.appearance.kerning = 24
        otpCodeView.appearance.backOffset = 5
        otpCodeView.appearance.backColor = UIColor.clear
        otpCodeView.appearance.backBorderWidth = 1
        otpCodeView.appearance.backBorderColor = UIColor.black.withAlphaComponent(0.2)
        otpCodeView.appearance.backCornerRadius = 4
        otpCodeView.appearance.backFocusColor = UIColor.clear
        otpCodeView.appearance.backBorderFocusColor = UIColor.black.withAlphaComponent(0.8)
        otpCodeView.appearance.backActiveColor = UIColor.clear
        otpCodeView.appearance.backBorderActiveColor = UIColor.black
        otpCodeView.appearance.backRounded = false
        otpCodeView.becomeFirstResponder()
    }
   
    func refreshPinField() {

        otpCodeView.text = ""
//        UIPasteboard.general.string = targetCode
        setStyle()
    }
    
    
    @IBAction func didTapResendCode(_ sender: Any) {
        self.dismissKeyboard()
        self.showLoadingView(vc: self, label: CONSTANT.LOADING_TEXT_REQ)
        Auth.auth().settings!.isAppVerificationDisabledForTesting = true
        Auth.auth().languageCode = "en";
        PhoneAuthProvider.provider().verifyPhoneNumber(dialingCode + phoneNum, uiDelegate: nil) { (verificationID, error) in
            
            self.hideLoadingView()
            
            if let error = error {
                let errStr = error.localizedDescription
                let invalidPhoneTypes = ["TOO_LONG", "TOO_SHORT", "Invalid format"]
                
                if errStr == "MISSING_CLIENT_IDENTIFIER" {
                    self.showError("You have tried too many times using this device! You cannot log in now. Please wait.")
                } else if invalidPhoneTypes.contains(errStr) {
                    self.showError("Invalid Phone number.")
                } else {
                    self.showError("Somethings wrong!")
                }
                
                return
            }
            
            UserDefaults.standard.set(verificationID, forKey: CONSTANT.KEY_AUTHVERIFY_ID)
            self.refreshPinField()
        }
    }
    
}


// Mark: - KAPinFieldDelegate
extension ConfirmOTPVC : KAPinFieldDelegate {
    
    func pinField(_ field: KAPinField, didChangeTo string: String, isValid: Bool) {
        if isValid {
            print("Valid input: \(string) ")
        } else {
            print("Invalid input: \(string) ")
            self.otpCodeView.animateFailure()
        }
    }
    
    func pinField(_ field: KAPinField, didFinishWith code: String) {
        
        print("didFinishWith : \(code)")
        let verificationID = UserDefaults.standard.string(forKey: CONSTANT.KEY_AUTHVERIFY_ID)
        self.showLoadingView(vc: self, label: CONSTANT.LOADING_TEXT_REQ)
        self.dismissKeyboard()
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID ?? "", verificationCode: code)
        Auth.auth().signIn(with: credential) { authData, error in
        
            if let error = error {
                self.hideLoadingView()
                self.showError(error.localizedDescription)
                field.animateFailure()
                self.otpCodeView.becomeFirstResponder()
                return
            }
            
            field.animateSuccess(with: "👍") {
                
                APIManager.shared.login(self.dialingCode, self.phoneNum, deviceTokenString) { (result_code, msg, data) in
                    self.hideLoadingView()
                    if result_code == CONSTANT.CODE_SUCCESS {
                        if let token = currentUser?.device_token, token != "" {
                            APIManager.shared.updateToken(token) { (result_code, msg )  in
                            }
                        }
                        UserDefaults.standard.set(true, forKey: CONSTANT.KEY_LOGIN_STATE)
                        self.gotoVC("HomeNav")
                    } else {
                        self.showAlert(msg)
                    }
                }
            }
        }
    }
    
}
