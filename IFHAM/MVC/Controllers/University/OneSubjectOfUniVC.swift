//
//  OneSubjectOfUniVC.swift
//

import UIKit
import AIFlatSwitch

class OneSubjectOfUniVC: BaseVC {

    @IBOutlet weak var uiTableview: UITableView!
    @IBOutlet weak var imgSubjectLogo: UIImageView!
    @IBOutlet weak var lblSubjectName: UILabel!
    @IBOutlet weak var lblData: UILabel!
    @IBOutlet weak var lblTatalCount: UILabel!
    
    var totalDataSource     = [VideoChapterModel]()
    var tblDataSource       = [VideoChapterModel]()
    var isReadyPurchase     = false
    var selectedItemForPurchase = [Bool]()
    var selectedSubject: CategoryModel? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadData), name: .paidVideosOnDetail, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onCallPayMembershipApi), name: .paidVideosByPaymemt, object: nil)
    }
    
    // Swift
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            // The back button was pressed or interactive gesture used
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    //MARK:-- custom function
    func initView() {
        
        lblData.isHidden = true
        //navigation title multiline
        if let category = selectedItemOfCategory {
            let label = UILabel()
            label.backgroundColor = .clear
            label.numberOfLines = 0
            label.font = UIFont.boldSystemFont(ofSize: 16.0)
            label.textAlignment = .center
            label.textColor = .white
            label.text = category.title
            self.navigationItem.titleView = label
        } else {
            doDismiss()
        }
        
        initRightBarButtonItem()
        
        uiTableview.dataSource = self
        uiTableview.delegate = self
        uiTableview.tableFooterView = UIView()
        loadData()
        
    }

    @objc func loadData() {
        if let uniData = selectedItemOfCategory, let subjectData = selectedSubject {
            selectedItemOfCategory = subjectData
            APIManager.shared.getChapterOfVideo(uniData.row_id, subjectData.row_id) { (result_code, msg, data) in
                if result_code == CONSTANT.CODE_SUCCESS {
                    
                    self.tblDataSource = data as! [VideoChapterModel]
                    self.totalDataSource = self.tblDataSource
                    self.uiTableview.reloadData()
                    for _ in 0 ..< self.tblDataSource.count {
                        self.selectedItemForPurchase.append(false)
                    }
                    
                    self.lblTatalCount.text = "Total Chapter: \(self.totalDataSource.count)"
                    self.imgSubjectLogo.kf.setImage(with: URL(string: subjectData.imgName), placeholder: UIImage(named: "placeholder"))
                    self.lblSubjectName.text = subjectData.title
                } else {
                    self.showAlert("Something's wrong")
                }
            }
        } else {
            self.showAlert("Something's wrong")
        }
    }
    
    func initRightBarButtonItem () {
        let btn = UIButton(type: .custom)
        if isReadyPurchase {
            btn.setImage(UIImage(named: "ic_pay"), for: .normal)
        } else {
            btn.setImage(UIImage(named: "ic_select"), for: .normal)
        }
        
        btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn.tintColor = UIColor.white
        btn.addTarget(self, action: #selector(self.puchaseItem), for: .touchUpInside)
        let rightButton = UIBarButtonItem(customView: btn)
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc func puchaseItem() {
        if isReadyPurchase == true {
            isReadyPurchase = false
            checkInvalidPurchase()
        } else {
            tblDataSource = totalDataSource.filter{ ($0.is_paid == 0) }
            isReadyPurchase = true
        }
        
        initRightBarButtonItem()
        uiTableview.reloadData()
    }
    
    func gotoDetailPage(_ indexNum: Int) {
        currentVedeoChapter = tblDataSource[indexNum]
        gotoNavVC("OneVideoVC")
    }
    
    func checkInvalidPurchase() {
        var selectedState = false
        for one in selectedItemForPurchase {
            if one {
                selectedState = true
                break
            }
        }
        
        if selectedState == false {
            tblDataSource = totalDataSource
            return
        }

        
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
            self.initPurchaseSelectedData()
        })
        alertController.addAction(noAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func showAlertPromoCode(_ errStr: String = "") {
        /// promotion code alert
        let promoAlert = UIAlertController(title: "Enter Promotion code", message: errStr, preferredStyle: .alert)
        
        /// cancel
        let cancel1Action = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
            self.initPurchaseSelectedData()
        })
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
            self.initPurchaseSelectedData()
            return
        } else {
            
            if getDateFormString(strDate: expireDate!, fromFormat: "yy-MM-dd") < Date() {
                showError("You can\'t use expired promotion code!")
                self.initPurchaseSelectedData()
                return
            }
        }
        
        showLoadingView(vc: self, label: CONSTANT.LOADING_TEXT_REQ)
        var param = getSelectedChapterForPurchase()
        param["promo_code"] = promo_code
        
        APIManager.shared.payVideoByPromo(param) { (result_code, msg, data) in
            
            self.hideLoadingView()
            if result_code == CONSTANT.CODE_SUCCESS {
                self.showToast("Paying by promotion code was successful.")
                self.totalDataSource = data as! [VideoChapterModel]
                self.tblDataSource = self.totalDataSource
                self.uiTableview.reloadData()
                
            } else {
                self.showAlert(msg)
                
            }
            self.tblDataSource = self.totalDataSource
            self.initPurchaseSelectedData()
        }
        
    }
    
    func getSelectedChapterForPurchase() -> [String: Any] {
        var selectedChapters = [String]()
        for index in 0 ..< selectedItemForPurchase.count {
            if selectedItemForPurchase[index] {
                selectedChapters.append("\(tblDataSource[index].chapter_num)")
            }
        }
        
        let data = [
            "user_id"       : UserDefaults.standard.string(forKey: CONSTANT.KEY_USERID)!,
            "uni_id"        : tblDataSource[0].uni_id,
            "subject_id"    : tblDataSource[0].subject_id,
            "chapter"       : selectedChapters.joined(separator: ","),
            "video_ids"     : "0",
            "video_type"    : "university"
        ] as [String : Any]
        
        return data
    }
    
    func getPriceForPurchase() -> Float {
        var totalPrice: Float = 0.0
        for index in 0 ..< selectedItemForPurchase.count {
            if selectedItemForPurchase[index] {
                totalPrice += tblDataSource[index].video_price
            }
        }
        
        return totalPrice
    }
    
    func initPurchaseSelectedData() {
        for index in 0 ..< selectedItemForPurchase.count {
            selectedItemForPurchase[index] = false
        }
        tblDataSource = totalDataSource
        uiTableview.reloadData()
    }
    
    //MARK:-  payment gateway
    func callPurchaseAPI(_ type: String) {
        
        let toVC = self.storyboard?.instantiateViewController( withIdentifier: "PayMFPaymentVC") as! PayMFPaymentVC
        toVC.modalPresentationStyle = .fullScreen
        toVC.amountPay = getPriceForPurchase()
        self.navigationController?.pushViewController(toVC, animated: true)
    }
    
    @objc func onCallPayMembershipApi() {
        
        showLoadingView(vc: self, label: CONSTANT.LOADING_TEXT_REQ)
        
        var params = getSelectedChapterForPurchase()
        params["pay_type"] = "myfatoorah"
        
        APIManager.shared.payVideoByPayment(params) { (result_code, msg, data) in
            
            self.hideLoadingView()
            if result_code == CONSTANT.CODE_SUCCESS {
                self.totalDataSource = data as! [VideoChapterModel]
                self.tblDataSource = self.totalDataSource
                self.uiTableview.reloadData()
                self.selectedItemForPurchase.removeAll()
                self.isReadyPurchase = false
                
            } else {
                self.showError(msg)
            }
        }
        
    }
    
    //MARK:- custom action
    @IBAction func didChangeSelectedState(_ sender: AIFlatSwitch) {
        selectedItemForPurchase[sender.tag] = sender.isSelected//!selectedItemForPurchase[sender.tag]
        uiTableview.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
    }
}


// MARK: - Table view data source
extension OneSubjectOfUniVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tblDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OneUniversityCell") as! OneChapterCell
        cell.entity = tblDataSource[indexPath.row]
        cell.flatCheck.tag = indexPath.row
        
        if isReadyPurchase {
            if tblDataSource[indexPath.row].is_paid == 1 {
                cell.flatCheck.isHidden = true
            } else {
                cell.flatCheck.isHidden = false
            }
            if selectedItemForPurchase[indexPath.row] {
                cell.flatCheck.isSelected = true
            } else {
                cell.flatCheck.isSelected = false
            }
        } else {
            cell.flatCheck.isHidden = true
        }
        
        return cell
    }
}

// MARK: - Table view data source
extension OneSubjectOfUniVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if isReadyPurchase {
            if tblDataSource[indexPath.row].is_paid == 1 {
                return
            }
            
            selectedItemForPurchase[indexPath.row] = !selectedItemForPurchase[indexPath.row]
            uiTableview.reloadRows(at: [indexPath], with: .none)
        } else {
            self.gotoDetailPage(indexPath.row)
        }
    }
}



