//
//  AppConstant.swift
//  Parrot
//
//  Created by AngelDev on 4/28/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit

struct CONSTANT {
    //Basic
    static let APP_NAME             = "IFHAM"
    
    //Color
    static let COLOR_ORANGE         = UIColor(hex: "FDB913")
    static let COLOR_PRIMARY        = UIColor(named: "primary")
    static let COLOR_LIGHT_PRIMARY  = UIColor(named: "lightPrimary")
    static let COLOR_YELLOW         = UIColor(named: "yellowBut")
    static let COLOR_NAV_BAR        = UIColor(named: "navigation")
    static let COLOR_BG             = UIColor(named: "home_bgcolor")
    
    // userdefault Key
    static let KEY_AUTHVERIFY_ID    = "authVerificationID"
    static let KEY_TOKEN            = "kToken"
    static let KEY_USERID           = "k_id"
    static let KEY_NAME             = "kFullname"
    static let KEY_PHOTO            = "kPhotoUrl"
    static let KEY_CCOUNTRY_CODE    = "kCountryCode"
    static let KEY_DIALING_CODE     = "kDialingCode"
    static let KEY_PHONE_NUM        = "kPhoneNum"
    static let KEY_LOGIN_STATE      = "kLoginState"
    static let KEY_NOTI_STATE       = "kNotificationSetState"
    static let KEY_PROMOCODE_ID     = "kPromoCodeID"
    static let KEY_PROMOCODE        = "kPromoCode"
    static let KEY_EXPIRE_DATE      = "kExpireDate"
    
    // Result code
    static let RESULT_CODE          = "result_code"
    static let CODE_201             = 201
    static let CODE_SUCCESS         = 200
    static let CODE_202             = 202
    static let CODE_203             = 203
    static let CODE_FAIL            = 400
    
    //msg
    static let LOADING_TEXT_REQ     = "Requesting..."
    static let ERR_USERNAME         = "Invalid Full Name"
    static let ERR_EMAIL            = "Invalid Email"
    static let ERR_PHONE            = "Invalid Phone Number"
    static let ERR_AGREE            = "Please agree Our Privacy Policy"
    static let ERR_CONTENT          = "Please enter Contents"
}

// MARK: Notification.Name extension
extension Notification.Name {
    static let startVideo   = Notification.Name("Start_Video_Play")
    static let endVideo     = Notification.Name("End_Video_Play")
    static let getAdsData   = Notification.Name("Get_Ads_Data")
    static let getHomeData  = Notification.Name("Get_Home_Data")
    static let loadVideos   = Notification.Name("Load_Video_Data")
    
    static let paidVideosOnDetail       = Notification.Name("Paid_Video_On_Detail")
    static let paidVideosByPaymemt      = Notification.Name("Paid_Video_By_Paymemt")
    static let updatedProfile           = Notification.Name("Updated_Profile")
    
}

//MARK:- menu data
var menus = [
            "Home",
            "Universities",
            "IGCSE",
            "Book Solutions",
            "Test Bank",
//            "Course",
//            "Notification",
            "Privacy Policy",
            "Contact Us",
            "About IFHAM"
        ]

var icons = [
            "ic_home",
            "ic_universities",
            "ic_igcse",
            "ic_book_solution",
            "ic_test",
//            "ic_course",
//            "ic_notification",
            "ic_security_lock",
            "ic_contact",
            "ic_aboutus1"
        ]

var menusVCs = [
            "HomeVC",
            "ListUniversityVC",
            "ListIGCSEVC",
            "ListBookSolutionVC",
            "ListTestBankVC",
            "PrivacyVC",
            "ContactUsVC",
            "AboutUsVC",
        ]

//MARK:- main page names
let viewAllPageNames = [
            "ListUniversityVC",
            "ListIGCSEVC",
            "ListBookSolutionVC",
            "ListTestBankVC"
        ]

//MARK:- one of main page names
let viewOnePageNames = [
            "SubjectListVC",//"OneSubjectOfUniVC",
            "OneIGCSEVC",
            "OneBookSolutionVC",
            "OneBookSolutionVC"//"OneTestBankVC"
        ]

var selectedItemOfCategory : CategoryModel? = nil

enum CategeryType: Int {
    case university = 0
    case igcse
    case booksolution
    case testbank
    case course
}

enum DataType: Int {
    case video
    case pdf
}
