//
//  APIManager.swift
//  IFHAM
//
//  Created by AngelDev on 6/22/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

let HOST = "http://admin.ifhams.com/"
let API = HOST + "api/"

class APIManager {
    
    let REQ_SIGNUP              = API + "signup"
    let REQ_ISVALID_LOGIN       = API + "validLogin"
    let REQ_LOGIN               = API + "login"
    let REQ_GET_USERDATA        = API + "getUserData"
    let REQ_UPDATE_TOKEN        = API + "updateToken"
    let REQ_UPDATE_PROFILE      = API + "updateProfile"
    let REQ_GET_ADSDATA         = API + "getAdsData"
    let REQ_GET_HOMEDATA        = API + "getHomeData"
    let REQ_GET_UNIDATA         = API + "getUniData"
    let REQ_GET_IGCSEDATA       = API + "getIGCSEData"
    let REQ_GET_BOOKDATA        = API + "getBookSolutionData"
    let REQ_GET_TESTDATA        = API + "getTestBankData"
    
    let REQ_GET_SUBJECTLISTOFUNI        = API + "getSubjectOfUniData"
    let REQ_GET_CHAPTERS_OF_VIDEO       = API + "getChapterOfVideo"
    let REQ_GET_VIDEOS_OF_DETAIL        = API + "getVideofDetail"
    let REQ_GET_FAQ_UNI_CHAPTER         = API + "getQuestionData"
    let REQ_SAVE_FAQ_UNI_CHAPTER        = API + "saveQuestionForVideo"
    let REQ_GET_CHAPTER_DOCUMENT        = API + "getChaptersOfDocument"
    
    
    
    let REQ_PAYVIDEO_BYPROMO   = API + "payVideoByPromo"
    let REQ_PAYVIDEO_BYPAYMENT = API + "payVideoByPayment"
    
    let REQ_SEND_CONTACTUS = API + "sendContactus"
    
    static let shared = APIManager()
    
    // MARK: - APIs
    //  MARK: - Private Helper for HTTP requst
    ///
    /// - parameter method:             HTTP Method(get, post, put, delete)
    /// - parameter url:                Call URL
    /// - parameter parameters:         Parameters
    /// - parameter completion:         Function to call when the response is obtained (Status: Bool, Message:  String?, Response: [String; Any]?
    fileprivate func request(_ method: HTTPMethod = .post, url: String, parameters: [String: Any]? = nil, completion: @escaping (Int, String?, Any?) -> Void) {
        AF.request(url, method: method, parameters: parameters)
        .validate()
        .responseJSON { response in
            guard response.error == nil else {
                completion(CONSTANT.CODE_FAIL, (response.error)?.localizedDescription, nil)
                return
            }

            // check response valud is valid
            guard let value = response.value as? [String: Any] else {
                completion(CONSTANT.CODE_FAIL, "Internal server error is occured.", nil)
               return
            }
           
            if  let result = value["result_code"] as? Int {
                let message = value["message"] as? String
                completion(result, message, value)
                
            } else {
                completion(CONSTANT.CODE_FAIL, "Internal server error is occured.", nil)
            }
        }
    }
    
    //  MARK: - Private Helper for multipartFormData upload
    ///
    /// - parameter to:                         URL to upload
    /// - parameter multipartFormData:          FormData to upload
    /// - parameter completion:                 Function to call when the response is obtained (Status: Bool, Message:  String?, Response: [String; Any]?
    fileprivate func multipartFormDataUpload(_ multipartFormData: @escaping (MultipartFormData) -> Void, url: String, completion: @escaping (Int, String?, Any?) -> Void) {
        AF.upload(multipartFormData: multipartFormData, to: url)
        .validate()
        .responseJSON { response in
            guard response.error == nil else {
               // got an error in response
                completion(CONSTANT.CODE_FAIL, (response.error)?.localizedDescription, nil)
                return
            }

            // check response valud is valid
            guard let value = response.value as? [String: Any] else {
                completion(CONSTANT.CODE_FAIL, "Internal server error is occured.", nil)
               return
            }
            
            // TODO:
            // Do common parse from response, extra will have main data from server
            // This represents common response format of app API server
            if  let result = value["result_code"] as? Int {
                let message = value["message"] as? String
                completion(result, message, value)
                
            } else {
                completion(CONSTANT.CODE_FAIL, "Internal server error is occured.", nil)
            }
        }
    }
    
//    func postImageUpload(_ url:URL, params:[String:Any], pictures : UIImage) -> Void {
    func postImageUpload(url: String, params: [String: Any], image: UIImage?, imageName: String?, completion: @escaping (Int, String?, Any?) -> Void) {

        let headers: HTTPHeaders
        headers = ["Content-type": "multipart/form-data",
                   "Content-Disposition" : "form-data"]
        AF.upload(multipartFormData: { (multipartFormData) in
            
            for (key, value) in params {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
            }
            if let img = image {
                
                let imageData = img.jpegData(compressionQuality: 0.5)!
                multipartFormData.append(imageData, withName: imageName!, fileName: "image.png", mimeType: "image/png")
            }
        }, to: url).response { response in
            print("response.data", response.data)
            print("response.url", url)
            print("response.result", response.result)
            print("response.request", response.request)
            
            guard response.error == nil else {
               // got an error in response
                completion(CONSTANT.CODE_FAIL, (response.error)?.localizedDescription, nil)
                return
            }

            // check response valud is valid
            guard let value = response.value as? [String: Any] else {
                completion(CONSTANT.CODE_FAIL, "Internal server error is occured.", nil)
               return
            }
            
            // TODO:
            // Do common parse from response, extra will have main data from server
            // This represents common response format of app API server
            if  let result = value["result_code"] as? Int {
                let message = value["message"] as? String
                completion(result, message, value)
                
            } else {
                completion(CONSTANT.CODE_FAIL, "Internal server error is occured.", nil)
            }
        }
    }
    
    func signup(_ user: UserModel, completion: @escaping (Int, String?, [Any]?) -> ()) {
        
        let params = ["full_name"   : user.full_name,
                      "email"       : user.email,
                      "country_code": user.country_code,
                      "dialing_code": user.dialing_code,
                      "phone_num"   : user.phone_num,
                      "photo_url"   : user.photo_url
            ] as [String : Any]
        
        
        request(.post, url: REQ_SIGNUP, parameters: params) { (result, message, value) in
           
            if result != CONSTANT.CODE_SUCCESS {
                completion(result, message, nil)
            } else if result == CONSTANT.CODE_SUCCESS, let value = value {
                
                let user = ParseHelper.parseUser(JSON(value)["user_data"])
                let adsTemp = JSON(value)["ads_data"].arrayValue
                var adsData = [String]()
                for one in adsTemp {
                    adsData.append(one.stringValue)
                }
                
                currentUser = user
                completion(result, message, adsData)
            }
        }
    }
    
    func validLogin(_ country_code: String, _ phone_num: String, completion: @escaping (Int, String) -> ()) {
        
        let params = ["country_code"   : country_code,
                      "phone_num"      : phone_num
            ] as [String : Any]
        
        
        request(.post, url: REQ_ISVALID_LOGIN, parameters: params) { (result, message, value) in
            completion(result, message!)
        }
    }
    
    func login(_ dialing_code: String, _ phone_num: String, _ device_token: String, completion: @escaping (Int, String?, [Any]?) -> ()) {
        
        let params = ["dialing_code" : dialing_code,
                      "phone_num"    : phone_num,
                      "device_token" : device_token
            ] as [String : Any]
        
        
        request(.post, url: REQ_LOGIN, parameters: params) { (result, message, value) in
            if result != CONSTANT.CODE_SUCCESS {
                completion(result, message, nil)
            } else if result == CONSTANT.CODE_SUCCESS, let value = value {
                
                let user = ParseHelper.parseUser(JSON(value)["user_data"])
                let adsTemp = JSON(value)["ads_data"].arrayValue
                var adsData = [String]()
                for one in adsTemp {
                    adsData.append(one.stringValue)
                }
                
                currentUser = user
                completion(result, message, adsData)
            }
        }
    }
    
    func updateToken (_ device_token : String, completion: @escaping (Int, String) -> ()) {
        
        let params = ["user_id" : UserDefaults.standard.string(forKey: CONSTANT.KEY_USERID)!,
                  "device_token" : device_token
        ] as [String : Any]
        
        request(.post, url: REQ_UPDATE_TOKEN, parameters: params) { (result, message, value) in
            completion(result, message!)
        }
    }
    
    func updateProfile (_ user : UserModel, image: UIImage?, imageName: String?, completion: @escaping (Int, String) -> ()) {
        
        let params = [
            "user_id"   : UserDefaults.standard.string(forKey: CONSTANT.KEY_USERID)!,
            "full_name"   : user.full_name,
            "email"       : user.email,
            "country_code": user.country_code,
            "phone_num"   : user.phone_num,
        ] as [String : String]
        
        postImageUpload(url: REQ_UPDATE_PROFILE, params: params, image: image, imageName: imageName) { (result, message, value) in
            if result != CONSTANT.CODE_SUCCESS {
                completion(result, message!)
            } else if result == CONSTANT.CODE_SUCCESS, let value = value {
                
                let user = ParseHelper.parseUser(JSON(value)["user_data"])
                currentUser = user
                completion(result, message!)
            }
        }
    }
    
    func updateProfile(_ user : UserModel, _ attachment: (Data, String)?, completion: @escaping (Int, String?, Any?) -> ()) {
        
        let params = [
            "user_id"     : "\(UserDefaults.standard.integer(forKey: CONSTANT.KEY_USERID))",
            "full_name"   : user.full_name,
            "email"       : user.email,
            "country_code": user.country_code,
            "phone_num"   : user.phone_num,
        ] as [String : String]
        
        multipartFormDataUpload({ (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append(Data(value.utf8), withName: key)
            }
            if let img = attachment {
                multipartFormData.append(img.0, withName: img.1, fileName: "\(img.1).png", mimeType: "image/png")
            }
        }, url: REQ_UPDATE_PROFILE) { (result, message, value) in
            if result == CONSTANT.CODE_FAIL {
                completion(result, message, nil)
            } else if result == CONSTANT.CODE_SUCCESS {
                let json = JSON(value!)
                
                let user = ParseHelper.parseUser(json["user_data"])
                currentUser = user
                
                completion(result, message, nil)
            } else {
                completion(result, message, nil)
            }
        }
    }
    
    
    func getUserData(_ user_id: String, completion: @escaping (Int, String) -> ()) {
        let params = ["user_id" : user_id
        ] as [String : Any]
        
        request(.post, url: REQ_GET_USERDATA, parameters: params) { (result, message, value) in
            if result != CONSTANT.CODE_SUCCESS {
                completion(result, message!)
            } else if result == CONSTANT.CODE_SUCCESS, let value = value {
                
                let user = ParseHelper.parseUser(JSON(value)["user_data"])
                
                currentUser = user
                completion(result, message!)
            }
        }
    }
    
    func getADS(completion: @escaping (Int, String?, [Any]?) -> ()) {
        
        request(.get, url: REQ_GET_ADSDATA, parameters: nil) { (result, message, value) in
            if result != CONSTANT.CODE_SUCCESS {
                completion(result, message, nil)
            } else if result == CONSTANT.CODE_SUCCESS, let value = value {
                
                let adsTemp = JSON(value)["ads_data"].arrayValue
                var adsData = [String]()
                for one in adsTemp {
                    adsData.append(one.stringValue)
                }
                
                completion(result, message, adsData)
            }
        }
    }
    
    func getHomeData(completion: @escaping (Int, String?, [String: Any]?) -> ()) {
        
        request(.get, url: REQ_GET_HOMEDATA, parameters: nil) { (result, message, value) in
            if result != CONSTANT.CODE_SUCCESS {
                completion(result, message, nil)
            } else if result == CONSTANT.CODE_SUCCESS, let value = value {
                
                completion(result, message, (value as! [String: Any]))
            }
        }
    }
    
    func getUniData(completion: @escaping (Int, String?, Any?) -> ()) {
        
        request(.get, url: REQ_GET_UNIDATA, parameters: nil) { (result, message, value) in
            if result != CONSTANT.CODE_SUCCESS {
                completion(result, message, nil)
            } else if result == CONSTANT.CODE_SUCCESS, let value = value {
                
                let temp = JSON(value)["uni_data"].arrayValue
                var uniData = [CategoryModel]()
                for one in temp {
                    uniData.append(CategoryModel(dict: one, kind: "university"))
                }
                
                completion(result, message, uniData)
            }
        }
    }
    
    func getIgcseData(completion: @escaping (Int, String?, Any?) -> ()) {
        
        request(.get, url: REQ_GET_IGCSEDATA, parameters: nil) { (result, message, value) in
            if result != CONSTANT.CODE_SUCCESS {
                completion(result, message, nil)
            } else if result == CONSTANT.CODE_SUCCESS, let value = value {
                
                let temp = JSON(value)["igcse_data"].arrayValue
                var uniData = [CategoryModel]()
                for one in temp {
                    uniData.append(CategoryModel(dict: one, kind: "igcse"))
                }
                
                completion(result, message, uniData)
            }
        }
    }
    
    func getBookSolutionData(completion: @escaping (Int, String?, Any?) -> ()) {
        
        request(.get, url: REQ_GET_BOOKDATA, parameters: nil) { (result, message, value) in
            if result != CONSTANT.CODE_SUCCESS {
                completion(result, message, nil)
            } else if result == CONSTANT.CODE_SUCCESS, let value = value {
                
                let temp = JSON(value)["book_data"].arrayValue
                var bookData = [CategoryModel]()
                for one in temp {
                    bookData.append(CategoryModel(dict: one, kind: "booksolution"))
                }
                
                completion(result, message, bookData)
            }
        }
    }
    
    func getTestBankData(completion: @escaping (Int, String?, Any?) -> ()) {
        
        request(.get, url: REQ_GET_TESTDATA, parameters: nil) { (result, message, value) in
            if result != CONSTANT.CODE_SUCCESS {
                completion(result, message, nil)
            } else if result == CONSTANT.CODE_SUCCESS, let value = value {
                
                let temp = JSON(value)["test_data"].arrayValue
                var testData = [CategoryModel]()
                for one in temp {
                    testData.append(CategoryModel(dict: one, kind: "testbank"))
                }
                
                completion(result, message, testData)
            }
        }
    }
    
    func getSubjectOfUniData(_ uni_id: Int, completion: @escaping (Int, String?, Any?) -> ()) {
        
        let params = [
            "uni_id"   : uni_id
        ] as [String : Any]
        
        request(.post, url: REQ_GET_SUBJECTLISTOFUNI, parameters: params) { (result, message, value) in
            if result != CONSTANT.CODE_SUCCESS {
                completion(result, message, nil)
            } else if result == CONSTANT.CODE_SUCCESS, let value = value {
                
                let temp = JSON(value)["subject_data"].arrayValue
                var testData = [CategoryModel]()
                for one in temp {
                    testData.append(CategoryModel(dict: one, kind: "igcse"))
                }
                
                completion(result, message, testData)
            }
        }
    }
    
    func getChapterOfVideo(_ uni_id: Int, _ subject_id: Int, completion: @escaping (Int, String?, Any?) -> ()) {
        
        let params = [
            "uni_id"     : uni_id,
            "subject_id" : subject_id,
            "user_id"    : UserDefaults.standard.string(forKey: CONSTANT.KEY_USERID)!,
        ] as [String : Any]
        
        request(.post, url: REQ_GET_CHAPTERS_OF_VIDEO, parameters: params) { (result, message, value) in
            if result != CONSTANT.CODE_SUCCESS {
                completion(result, message, nil)
            } else if result == CONSTANT.CODE_SUCCESS, let value = value {
                
                let temp = JSON(value)["chapter_data"].arrayValue
                var testData = [VideoChapterModel]()
                for one in temp {
                    testData.append(VideoChapterModel(dict: one, kind: "university"))
                }
                
                completion(result, message, testData)
            }
        }
    }
    
    func getVideofDetail(_ data: [String: Any], completion: @escaping (Int, String?, Any?) -> ()) {
        
        request(.post, url: REQ_GET_VIDEOS_OF_DETAIL, parameters: data) { (result, message, value) in
            if result != CONSTANT.CODE_SUCCESS {
                completion(result, message, nil)
            } else if result == CONSTANT.CODE_SUCCESS, let value = value {
                
                let temp = JSON(value)["video_data"].arrayValue
                var tempData = [VideoDataModel]()
                for one in temp {
                    tempData.append(VideoDataModel(dict: one, kind: "university"))
                }
                
                completion(result, message, tempData)
            }
        }
    }
    
    
    func payVideoByPromo(_ data: [String: Any], completion: @escaping (Int, String?, Any?) -> ()) {
        
        request(.post, url: REQ_PAYVIDEO_BYPROMO, parameters: data) { (result, message, value) in
            if result != CONSTANT.CODE_SUCCESS {
                completion(result, message, nil)
            } else if result == CONSTANT.CODE_SUCCESS, let value = value {
                
                if data["video_ids"] as! String == "0" {
                    let temp = JSON(value)["chapter_data"].arrayValue
                    var chapterData = [VideoChapterModel]()
                    for one in temp {
                        chapterData.append(VideoChapterModel(dict: one, kind: data["video_type"] as! String))
                    }
                    
                    completion(result, message, chapterData)
                    
                } else {
                    let temp = JSON(value)["video_data"].arrayValue
                    var videoData = [VideoDataModel]()
                    for one in temp {
                        videoData.append(VideoDataModel(dict: one, kind: data["video_type"] as! String))
                    }
                    
                    completion(result, message, videoData)
                }
            }
        }
    }
    
    func payVideoByPayment(_ data: [String: Any], completion: @escaping (Int, String?, Any?) -> ()) {
        
        request(.post, url: REQ_PAYVIDEO_BYPAYMENT, parameters: data) { (result, message, value) in
            if result != CONSTANT.CODE_SUCCESS {
                completion(result, message, nil)
            } else if result == CONSTANT.CODE_SUCCESS, let value = value {
                
                if data["video_ids"] as! String == "0" {
                    let temp = JSON(value)["chapter_data"].arrayValue
                    var chapterData = [VideoChapterModel]()
                    for one in temp {
                        chapterData.append(VideoChapterModel(dict: one, kind: data["video_type"] as! String))
                    }
                    
                    completion(result, message, chapterData)
                    
                } else {
                    let temp = JSON(value)["video_data"].arrayValue
                    var videoData = [VideoDataModel]()
                    for one in temp {
                        videoData.append(VideoDataModel(dict: one, kind: data["video_type"] as! String))
                    }
                    
                    completion(result, message, videoData)
                }
            }
        }
    }
    
    
    func getQuestionData(_ data: [String: Any], completion: @escaping (Int, String?, Any?) -> ()) {
        
        request(.post, url: REQ_GET_FAQ_UNI_CHAPTER, parameters: data) { (result, message, value) in
            if result != CONSTANT.CODE_SUCCESS {
                completion(result, message, nil)
            } else if result == CONSTANT.CODE_SUCCESS, let value = value {
                
                let temp = JSON(value)["question_data"].arrayValue
                var tempData = [QuestionModel]()
                for one in temp {
                    tempData.append(QuestionModel(dict: one, kind: data["video_type"] as! String))
                }
                
                completion(result, message, tempData)
            }
        }
    }
    
    func saveQuestionForVideo(_ data: [String: Any], completion: @escaping (Int, String?, Any?) -> ()) {
        
        request(.post, url: REQ_SAVE_FAQ_UNI_CHAPTER, parameters: data) { (result, message, value) in
            if result != CONSTANT.CODE_SUCCESS {
                completion(result, message, nil)
            } else if result == CONSTANT.CODE_SUCCESS, let value = value {
                
                let temp = JSON(value)["question_data"].arrayValue
                var tempData = [QuestionModel]()
                for one in temp {
                    tempData.append(QuestionModel(dict: one, kind: data["video_type"] as! String))
                }
                
                completion(result, message, tempData)
            }
        }
    }
    
    func getChaptersOfDocument(_ subject_id: Int, _ doc_type: String, completion: @escaping (Int, String?, Any?) -> ()) {
        
        let data = [
            "subject_id"  : subject_id,
            "doc_type"    : doc_type
        ] as [String : Any]
        
        request(.post, url: REQ_GET_CHAPTER_DOCUMENT, parameters: data) { (result, message, value) in
            if result != CONSTANT.CODE_SUCCESS {
                completion(result, message, nil)
            } else if result == CONSTANT.CODE_SUCCESS, let value = value {
                
                let temp = JSON(value)["pdf_data"].arrayValue
                var tempData = [PDFdocModel]()
                for one in temp {
                    tempData.append(PDFdocModel(dict: one, kind: doc_type))
                }
                
                completion(result, message, tempData)
            }
        }
    }
    
    func sendContactus(_ data: [String: Any], completion: @escaping (Int, String) -> ()) {
        
        request(.post, url: REQ_SEND_CONTACTUS, parameters: data) { (result, message, value) in
            completion(result, message!)
        }
    }
    
}
