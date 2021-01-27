//
//  ListVideoOfChapterVC.swift
//  IFHAM
//
//  Created by AngelDev on 6/4/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import AIFlatSwitch

class ListVideoOfChapterVC: BaseVC {

    @IBOutlet weak var uiTableview: UITableView!
    @IBOutlet weak var viwPay: UIView!
    @IBOutlet weak var butPay: UIButton!
    
    var tblDataSource       = [VideoDataModel]()
    var curCellIndex        = -1
    var preCellIndex        = -1
    var selectedIndexFoPlay = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.endVideo(_:)), name: .endVideo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onCallPayMembershipApi), name: .paidVideosByPaymemt, object: nil)
    }
    
    //MARK:-- custom function
    func initView() {
        
        uiTableview.dataSource = self
        uiTableview.delegate = self
        loadData()
    }
    
    @objc func endVideo(_ notification : Notification) {
        
        let indesPath = [IndexPath(row: curCellIndex, section: 0)]
        curCellIndex = -1
        preCellIndex = -1
        selectedIndexFoPlay = -1
        uiTableview.reloadRows(at: indesPath, with: .none)
    }
    
    func loadData() {
        
        if let curChapter = currentVedeoChapter {
            let params = [
                "user_id"       : UserDefaults.standard.string(forKey: CONSTANT.KEY_USERID)!,
                "uni_id"        : curChapter.uni_id,
                "subject_id"    : curChapter.subject_id,
                "chapter_num"   : curChapter.chapter_num
            ] as [String : Any]
            
            showLoadingView(vc: self, label: CONSTANT.LOADING_TEXT_REQ)
            APIManager.shared.getVideofDetail(params) { (result_code, msg, data) in
                
                self.hideLoadingView()
                if result_code == CONSTANT.CODE_SUCCESS {
                    
                    self.tblDataSource = data as! [VideoDataModel]
                    self.uiTableview.reloadData()
                    var total_time = 0
                    var total_price: Float = 0
                    var fullPay = true
                    for one in self.tblDataSource {
                        total_time += one.video_time
                        total_price += one.video_price
                        if one.is_paid == 0 {
                            fullPay = false
                        }
                    }
                    if fullPay {
                        self.viwPay.isHidden = true
                    } else {
                        self.viwPay.isHidden = false
                    }
                    
                    //send new loadstate to onevideovc
                    let dataDict:[String: Any] = [
                        "video_count": self.tblDataSource.count,
                        "total_time": total_time,
                        "total_price": total_price
                    ]
                    
                    NotificationCenter.default.post(name: .loadVideos, object: nil, userInfo: dataDict)
                    
                } else {
                    self.showAlert(msg)
                }
            }
        } else {
            self.showAlert("Something's wrong")
        }
    }
    
    func didSelectVideoData(_ indexPath: IndexPath) {
        
        if selectedIndexFoPlay == indexPath.row {
            return
        }
        
        selectedIndexFoPlay = indexPath.row
        //send new url
        let dataDict:[String: String] = [
            "url": tblDataSource[indexPath.row].video_url,
            "instructor": tblDataSource[indexPath.row].instructor_name,
        ]
        NotificationCenter.default.post(name: .startVideo, object: nil, userInfo: dataDict)
        
        preCellIndex = curCellIndex
        curCellIndex = indexPath.row
        let indesPaths = (preCellIndex == -1 ? [indexPath] : [IndexPath(row: preCellIndex, section: 0), indexPath])
        uiTableview.reloadRows(at: indesPaths, with: .none)
    }
    
    func showAlertPromoCode(_ errStr: String = "") {
        /// promotion code alert
        let promoAlert = UIAlertController(title: "Enter Promotion code", message: errStr, preferredStyle: .alert)
        
        /// cancel
        let cancel1Action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        promoAlert.addAction(cancel1Action)
        
        /// purchase by code
        let purchaseAction = UIAlertAction(title: "Pay", style: .default) { [unowned promoAlert] _ in
            let promo_code = promoAlert.textFields![0].text!
            self.callPurchaseAPIByPromoCode(promo_code)
        }
        purchaseAction.isEnabled = false
        promoAlert.addAction(purchaseAction)
        
        promoAlert.addTextField {(textField) in
            textField.placeholder = "4 Charaters"
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { (notification) in
                purchaseAction.isEnabled = self.isValidCode(textField.text!) &&  !textField.text!.isEmpty
            }
        }
        
        self.present(promoAlert, animated: true)
    }
    
    func callPurchaseAPIByPromoCode(_ promo_code: String) {
        
        if promo_code != UserDefaults.standard.string(forKey: CONSTANT.KEY_PROMOCODE) {
            showAlertPromoCode("Incorrect promotion code!")
            return
        }
        
        let expireDate = UserDefaults.standard.string(forKey: CONSTANT.KEY_EXPIRE_DATE)
        
        if expireDate == "" {
            showError("Invalid promotion date!")
//            self.initPurchaseSelectedData()
            return
        } else {
            
            if getDateFormString(strDate: expireDate!, fromFormat: "yy-MM-dd") < Date() {
                showError("You can\'t use expired promotion code!")
//                self.initPurchaseSelectedData()
                return
            }
        }
        var param = getSelectedVideoIDsForPurchase()
        param["promo_code"] = promo_code
        
        APIManager.shared.payVideoByPromo(param) { (result_code, msg, data) in
            if result_code == CONSTANT.CODE_SUCCESS {
                self.showToast("Paying by promotion code was successful.")
                
                NotificationCenter.default.post(name: .paidVideosOnDetail, object: nil, userInfo: nil)
            } else {
                self.showAlert(msg)
            }
        }
    }
    
    func callPurchaseAPI(_ type: String) {
        let toVC = self.storyboard?.instantiateViewController( withIdentifier: "PayMFPaymentVC") as! PayMFPaymentVC
        toVC.modalPresentationStyle = .fullScreen
        toVC.amountPay = getPriceForPurchase()
        self.navigationController?.pushViewController(toVC, animated: true)
    }
    
    func getPriceForPurchase() -> Float {
        var totalPrice: Float = 0.0
        
        for index in 0 ..< tblDataSource.count {
            totalPrice += tblDataSource[index].video_price
        }
        
        return totalPrice
    }
    
    func getSelectedVideoIDsForPurchase() -> [String: Any] {
        var selectedVideos = [String]()
        for index in 0 ..< tblDataSource.count {
            selectedVideos.append("\(tblDataSource[index].row_id)")
        }
        
        let data = [
            "user_id"       : UserDefaults.standard.string(forKey: CONSTANT.KEY_USERID)!,
            "uni_id"        : tblDataSource[0].uni_id,
            "subject_id"    : tblDataSource[0].subject_id,
            "chapter"       : tblDataSource[0].chapter_num,
            "video_ids"     : selectedVideos.joined(separator: ","),
            "video_type"    : "university"
        ] as [String : Any]
        
        return data
    }
    
    @objc func onCallPayMembershipApi() {
        
        showLoadingView(vc: self, label: CONSTANT.LOADING_TEXT_REQ)
        
        var params = getSelectedVideoIDsForPurchase()
        params["pay_type"] = "myfatoorah"
        
        APIManager.shared.payVideoByPayment(params) { (result_code, msg, data) in
            
            self.hideLoadingView()
            if result_code == CONSTANT.CODE_SUCCESS {
                self.tblDataSource = data as! [VideoDataModel]
                self.uiTableview.reloadData()
            } else {
                self.showError(msg)
            }
        }
        
    }
    
    
    @IBAction func didChangeCheck(_ sender: AIFlatSwitch) {
        //
    }
    
    //MARK:- custom action
    @IBAction func didTapSubscribe(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: title, message: "Are you sure to pay the selected items?", preferredStyle: .actionSheet)
        
        /// by myFatoorah
        let myFatoorahAction = UIAlertAction(title: "By MyFatoorah", style: .default, handler: { (action: UIAlertAction) in
            self.callPurchaseAPI("myFatoorah")
        })
        alertController.addAction(myFatoorahAction)
        
        /// by promo code
        let promoAction = UIAlertAction(title: "By Promotion Code", style: .default, handler: { (action: UIAlertAction) in
            self.showAlertPromoCode()
        })
        alertController.addAction(promoAction)
        
        /// cancel
        let noAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
//            self.initPurchaseSelectedData()
        })
        alertController.addAction(noAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Table view data source
extension ListVideoOfChapterVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tblDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OneVideoOfUniCell") as! OneVideoCell
        cell.entity = tblDataSource[indexPath.row]
        
        cell.viwContainer.borderColor = CONSTANT.COLOR_LIGHT_PRIMARY
        cell.flatCheck.tag = indexPath.row
        cell.flatCheck.isHidden = true
        
        if curCellIndex == indexPath.row {
            cell.viwContainer.backgroundColor = CONSTANT.COLOR_BG
            cell.viwContainer.borderWidth = 2
        } else {
            cell.viwContainer.backgroundColor = .white
            cell.viwContainer.borderWidth = 0
        }
        return cell
    }
}

// MARK: - Table view data source
extension ListVideoOfChapterVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tblDataSource[indexPath.row].is_paid == 1 {
            didSelectVideoData(indexPath)
        }
        /*else if tblDataSource[indexPath.row].video_price == 0 {
            didSelectVideoData(indexPath)
        }
        */
        else {
            showError("You have to subscribe and pay to play this video.")
        }
    }
}
