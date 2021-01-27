//
//  SignupVC.swift
//  IFHAM
//
//  Created by AngelDev on 5/29/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import SKCountryPicker
import FirebaseAuth
import AIFlatSwitch

class SignupVC: BaseVC {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var btnContrycode: UIButton!
    @IBOutlet weak var txtPhoneNum: UITextField!
    @IBOutlet weak var chkAgree: AIFlatSwitch!
    
    var dialingCode = "965"
    var countryCode = "KW"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK:- custom functions
    func setupView() {
        
        self.navigationController?.isNavigationBarHidden = true
        txtUsername.delegate = self
        txtEmail.delegate = self
        
        self.navigationController?.isNavigationBarHidden = false
        guard let country = CountryManager.shared.currentCountry else {
            self.btnContrycode.setTitle(countryCode, for: .normal)
            return
        }
        
        btnContrycode.setTitle(country.dialingCode, for: .normal)
        countryCode = country.countryCode
        dialingCode = country.dialingCode!
        imgFlag.image = country.flag
        btnContrycode.clipsToBounds = true
        txtPhoneNum.delegate = self
        
    }
    
    func callSignupAPI() {
        let fullname = txtUsername.text
        let email = txtEmail.text
        let phonenum = txtPhoneNum.text
        
        if fullname == "" {
            showError(CONSTANT.ERR_USERNAME)
            return
        }
        
        if !isValidEmail(email!) {
            showError(CONSTANT.ERR_EMAIL)
            return
        }
        
        if phonenum == "" {
            showError(CONSTANT.ERR_PHONE)
            return
        }
        
        if !chkAgree.isSelected {
            showError(CONSTANT.ERR_AGREE)
            return
        }
        
        let user = UserModel()
        
        user.full_name      = fullname!
        user.email          = email!
        user.country_code   = countryCode
        user.phone_num      = phonenum!
        user.dialing_code   = dialingCode
        
        if !Reachability.isConnected() {
            showError(R.string.U_CANNOT_CONNECT)
            return
        }
        
//        self.showLoadingView(vc: self, label: CONSTANT.LOADING_TEXT_REQ)
//        
//        let phoneNumber = countryCode + phoneNum
//        Auth.auth().settings!.isAppVerificationDisabledForTesting = false
//        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
//            self.hideLoadingView()
//            if let error = error {
//                let errStr = error.localizedDescription
//                let invalidPhoneTypes = ["TOO_LONG", "TOO_SHORT", "Invalid format"]
//                
//                if errStr == "MISSING_CLIENT_IDENTIFIER" {
//                    self.showError("You have tried too many times using this device! You cannot log in now. Please wait.")
//                } else if invalidPhoneTypes.contains(errStr) {
//                    self.showError("Invalid Phone number.")
//                } else {
//                    self.showError("Somethings wrong!")
//                }
//                
//                return
//            }
//            
//            UserDefaults.standard.set(verificationID, forKey: CONSTANT.KEY_AUTHVERIFY_ID)
//            UserDefaults.standard.set(self.countryCode, forKey: CONSTANT.KEY_CCOUNTRY_CODE)
//            UserDefaults.standard.set(phoneNum, forKey: CONSTANT.KEY_PHONE_NUM)
//            self.dismissKeyboard()
//            self.gotoNavVC("ConfirmOTPVC")
//        }
        
        
        
        self.showLoadingView(vc: self, label: CONSTANT.LOADING_TEXT_REQ)
        APIManager.shared.signup(user) { (result, message, data) in
            self.hideLoadingView()
            if result == CONSTANT.CODE_SUCCESS {
                if let token = currentUser?.device_token, token != "" {
                    APIManager.shared.updateToken(token) { (result_code, msg )  in
                    }
                }
                
                UserDefaults.standard.set(true, forKey: CONSTANT.KEY_LOGIN_STATE)
                self.gotoVC("HomeNav")
            } else {
                self.showAlert(message!)
            }
        }
        
    }
    
    //MARK:- custom actions
    
    @IBAction func didTapSignup(_ sender: Any) {
        callSignupAPI()
    }
    
    @IBAction func didTapkDialCode(_ sender: Any) {
        let countryController = CountryPickerWithSectionViewController.presentController(on: self) { [weak self] (country: Country) in

            guard let self = self else { return }

            self.dialingCode    = country.digitCountrycode! //country.dialingCode!
            self.countryCode    = country.countryCode
            self.imgFlag.image  = country.flag
            self.btnContrycode.setTitle(country.dialingCode, for: .normal)

        }

        countryController.detailColor = UIColor.red
        CountryManager.shared.addFilter(.countryCode)
        CountryManager.shared.addFilter(.countryDialCode)
    }
    
    @IBAction func didTapPrivacyPolicy(_ sender: Any) {
        
        if let url = URL(string: "https://nedress.com/privacy-policy") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func didTapSignin(_ sender: Any) {
        doRootDismiss()
    }
    
    
}

extension SignupVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == "" {
            return false
        } else {
            if textField == self.txtUsername {
                self.txtEmail.becomeFirstResponder()
            } else if textField == self.txtEmail {
                self.txtPhoneNum.becomeFirstResponder()
            } else {
                callSignupAPI()
            }
        }
        
        return true
    }
    
}
