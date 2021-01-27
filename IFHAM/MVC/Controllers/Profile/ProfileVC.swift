//
//  ProfileVC.swift
//  IFHAM
//
//  Created by AngelDev on 6/3/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import SKCountryPicker

class ProfileVC: BaseAndMenuVC {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblPromo: UILabel!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhoneNum: UITextField!
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var butCountry: UIButton!
    @IBOutlet weak var butCopyPromo: UIButton!
    
    var selectedProfileImg : (Data, String)? = nil
    
    let contryPickerController = CountryPickerController()
    let picker: UIImagePickerController = UIImagePickerController()
    var countryCode = "KW"
    var dialingCode = "965"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }
    
    func initView() {
        self.title = "My Profile"
        setNavigationBarColors()
        
        if let user = currentUser {
            txtName.text = user.full_name
            imgProfile.kf.setImage(with: URL(string: user.photo_url), placeholder: UIImage(named: "profile"))
            txtEmail.text = user.email
            txtPhoneNum.text = user.phone_num
//            butCopyPromo.isHidden = user.promo_code == ""
            
            countryCode = user.country_code
            dialingCode = user.dialing_code
            butCountry.setTitle(user.dialing_code, for: .normal)
            butCountry.clipsToBounds = true
            
            let country = CountryManager.shared.country(withCode: user.country_code)
            imgFlag.image = country?.flag
            
            
            lblPromo.numberOfLines = 0
            if user.promo_code != "" {
                lblPromo.text = "Promo Code: " + user.promo_code + "\nExpire Date: " + getLocalTimeString(fromTime: user.expire_date, formatStyle: "MMM dd, yyyy")
            } else {
                lblPromo.text = ""
            }
            
        } else {
            butCountry.setTitle(countryCode, for: .normal)
            let country = CountryManager.shared.currentCountry
            butCountry.setTitle(country?.dialingCode, for: .normal)
            butCountry.clipsToBounds = true
            imgFlag.image = country?.flag
            countryCode = country?.countryCode as! String
            dialingCode = country?.dialingCode! as! String
        }
        
        
        
        self.picker.delegate = self
        picker.allowsEditing = true
        picker.modalPresentationStyle = .fullScreen
    }
    
    func isValid(_ fullname: String, _ email: String, _ phonenum: String) -> Bool {
        
        if fullname.isEmpty {
            self.showError(CONSTANT.ERR_USERNAME)
            return false
        }

        if !isValidEmail(email) {
            self.showError(CONSTANT.ERR_EMAIL)
            return false
        }

        if phonenum.isEmpty {
            self.showAlert(CONSTANT.ERR_PHONE)
            return false
        }
        
        return true
    }
    
    
    //MARK:- custom action
    @IBAction func didChangePhoto(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (action) -> Void in
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) -> Void in
            self.picker.sourceType = .camera
            self.present(self.picker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func didTapCopy(_ sender: Any) {
        
        if let user = currentUser {
            let curDate = getDateStringFromTimeStamp("\(CurrentTimestamp!)", toFormat: "yyyy-MM-dd")
            
            if user.expire_date > getLocalTimeString(fromTime: curDate, formatStyle: "yyyy-MM-dd") {
                UIPasteboard.general.string = user.promo_code
                showToast("Your promotion code was copied.")
            } else {
                showToast("Your promotion code was expired.")
            }
        }
    }
    
    @IBAction func didTapkDialCode(_ sender: Any) {
        let countryController = CountryPickerWithSectionViewController.presentController(on: self) { [weak self] (country: Country) in

            guard let self = self else { return }
            
            self.dialingCode    = country.digitCountrycode! //country.dialingCode!
            self.countryCode    = country.countryCode
            self.imgFlag.image  = country.flag
            self.butCountry.setTitle(country.dialingCode, for: .normal)
            
        }

        countryController.detailColor = UIColor.red
        CountryManager.shared.addFilter(.countryCode)
        CountryManager.shared.addFilter(.countryDialCode)
    }

    @IBAction func didTapUpdate(_ sender: Any) {
        
        let fullname = txtName.text!
        let email = txtEmail.text!
        let phonenum = txtPhoneNum.text!
        
        if isValid(fullname, email, phonenum) {
            showLoadingView(vc: self, label: CONSTANT.LOADING_TEXT_REQ)
            
            let user = UserModel()
            user.full_name = fullname
            user.email = email
            user.country_code = countryCode
            user.dialing_code = dialingCode
            user.phone_num = phonenum
            
            APIManager.shared.updateProfile(user, selectedProfileImg) { (result_code, msg, value)  in
                self.hideLoadingView()
                if result_code == CONSTANT.CODE_SUCCESS {
                    NotificationCenter.default.post(name: .updatedProfile, object: nil, userInfo: nil)
                } else {
                    self.showError(msg)
                }
            }
        }
    }
    
    
}

//MARK:-  ImagePickerDelegate
extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            self.imgProfile.image = image
            selectedProfileImg = (image.jpegData(compressionQuality: 0.75)!, "photo_url")
        }
        
        dismiss(animated: true, completion: nil)
    }
}
