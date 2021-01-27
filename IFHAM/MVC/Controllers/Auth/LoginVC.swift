//
//  LoginVC.swift
//  IFHAM
//
//  Created by AngelDev on 5/28/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import SKCountryPicker
import FirebaseAuth

class LoginVC: BaseVC {
    
    @IBOutlet weak var btnContrycode: UIButton!
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var txfPhoneNum: UITextField!
    
    var dialingCode = "+965"
    var countryCode = "KW"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    //MARK:- custom functions
    func setupView() {
        
        FirebaseAPI.isConnected { (isConnected) in }
        
        guard let country = CountryManager.shared.currentCountry else {
            self.btnContrycode.setTitle(countryCode, for: .normal)
            return
        }
        
        btnContrycode.setTitle(country.dialingCode, for: .normal)
        countryCode = country.countryCode
        dialingCode = country.dialingCode!
        imgFlag.image = country.flag
        btnContrycode.clipsToBounds = true
        txfPhoneNum.delegate = self
    }
    
    func sendOTPCode() {
                
        guard let phoneNum = txfPhoneNum.text, phoneNum != "" else {
            showAlert("Invalid number")
            return
        }
        
        if !Reachability.isConnected() {
            showError(R.string.U_CANNOT_CONNECT)
            return
        }
        
        self.showLoadingView(vc: self, label: CONSTANT.LOADING_TEXT_REQ)
        APIManager.shared.validLogin(countryCode, phoneNum) { (result_code, msg) in
            if result_code == CONSTANT.CODE_SUCCESS {
                
                let fullNumber = self.dialingCode + phoneNum
                Auth.auth().settings!.isAppVerificationDisabledForTesting = false
                PhoneAuthProvider.provider().verifyPhoneNumber(fullNumber, uiDelegate: nil) { (verificationID, error) in
                    self.hideLoadingView()
                    if let error = error {
                        let errStr = error.localizedDescription
                        let invalidPhoneTypes = ["TOO_LONG", "TOO_SHORT", "Invalid format"]
                        
                        if errStr == "MISSING_CLIENT_IDENTIFIER"  {
                            self.showError("You have tried too many times using this device! You cannot log in now. Please wait.")
                        } else if errStr == "We have blocked all requests from this device due to unusual activity. Try again later." {
                            self.showError("We have blocked all requests from this device due to unusual activity. Try again later.")
                        } else if invalidPhoneTypes.contains(errStr) {
                            self.showError("Invalid Phone number.")
                        } else {
                            self.showError("Somethings wrong!")
                        }
                        
                        return
                    }
                    
                    UserDefaults.standard.set(verificationID, forKey: CONSTANT.KEY_AUTHVERIFY_ID)
                    UserDefaults.standard.set(self.countryCode, forKey: CONSTANT.KEY_CCOUNTRY_CODE)
                    UserDefaults.standard.set(self.dialingCode, forKey: CONSTANT.KEY_DIALING_CODE)
                    UserDefaults.standard.set(phoneNum, forKey: CONSTANT.KEY_PHONE_NUM)
                    self.dismissKeyboard()
                    self.gotoNavVC("ConfirmOTPVC")
                }
            } else {
                self.hideLoadingView()
                self.showAlert(msg)
            }
        }
    }
    
    //MARK:- custom actions
    @IBAction func didTapkDialCode(_ sender: Any) {
        let countryController = CountryPickerWithSectionViewController.presentController(on: self) { [weak self] (country: Country) in

            guard let self = self else { return }

            self.dialingCode    = country.dialingCode! //digitCountrycode! //country.dialingCode!
            self.countryCode    = country.countryCode
            self.imgFlag.image = country.flag
            self.btnContrycode.setTitle(country.dialingCode, for: .normal)
            self.txfPhoneNum.text = ""

        }

        countryController.detailColor = UIColor.red
        CountryManager.shared.addFilter(.countryCode)
        CountryManager.shared.addFilter(.countryDialCode)
    }

    @IBAction func didTapSendCode(_ sender: Any) {
        
        
        FirebaseAPI.isConnected { (isConnected) in
            if isConnected {
                self.sendOTPCode()
            } else {
                self.showError(R.string.U_CANNOT_CONNECT)
            }
        }
    }
    
    @IBAction func didTapSignup(_ sender: Any) {
        gotoNavVC("SignupVC")
    }
    
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        sendOTPCode()
        if textField.text == "" {
            return false
        } else {
            return true
        }
    }
}
