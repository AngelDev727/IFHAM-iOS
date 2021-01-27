//
//  OneIGCSEVC.swift
//  IFHAM
//
//  Created by AngelDev on 6/2/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import AIFlatSwitch

class OneIGCSEVC: BaseVC {

    @IBOutlet weak var uiTableview: UITableView!
    @IBOutlet weak var imgSubjectLogo: UIImageView!
    @IBOutlet weak var lblSubjectName: UILabel!
    @IBOutlet weak var lblData: UILabel!
    @IBOutlet weak var lblTatalCount: UILabel!
    @IBOutlet weak var uiSearchBar: UISearchBar!
    
    var tblDataSource = [VideoChapterModel]()
    var totalDataSource = [VideoChapterModel]()
    var isReadyPurchase = false
    var selectedItemForPurchase = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadData), name: .paidVideosOnDetail, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onCallPayMembershipApi), name: .paidVideosByPaymemt, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        setupSearchBar(searchBar: uiSearchBar)
    }

    func setupSearchBar(searchBar : UISearchBar) {
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = CONSTANT.COLOR_PRIMARY
        searchBar.barTintColor = CONSTANT.COLOR_PRIMARY
        if #available(iOS 13.0, *) {
            uiSearchBar.searchTextField.enablesReturnKeyAutomatically = true
        } else {
            // Fallback on earlier versions
        }
        uiSearchBar.setMagnifyingGlassColorTo(color: CONSTANT.COLOR_PRIMARY!)
        uiSearchBar.setPlaceholderTextColorTo(textColor: CONSTANT.COLOR_PRIMARY!, placeholderColor: CONSTANT.COLOR_LIGHT_PRIMARY!)
        uiSearchBar.setTextFieldBGColor(bgcolor: .white, borderWidth: 1.0, borderColor: .lightGray)
        uiSearchBar.setClearButtonColorTo(color: CONSTANT.COLOR_PRIMARY!)
        uiSearchBar.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    //MARK:-- custom function
    func initView() {
        
        lblData.isHidden = true
        initRightBarButtonItem()
        
        if let category = selectedItemOfCategory {
            
            let label = UILabel()
            label.backgroundColor = .clear
            label.numberOfLines = 0
            label.font = UIFont.boldSystemFont(ofSize: 16.0)
            label.textAlignment = .center
            label.textColor = .white
            label.text = category.title
            self.navigationItem.titleView = label
        }
        
        uiTableview.dataSource = self
        uiTableview.delegate = self
        uiTableview.tableFooterView = UIView()
        loadData()
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
    
    @objc func loadData() {
        
        if let subject =  selectedItemOfCategory {
            showLoadingView(vc: self, label: CONSTANT.LOADING_TEXT_REQ)
            APIManager.shared.getChapterOfVideo(0, subject.row_id) { (result_code, msg, data) in
                self.hideLoadingView()
                if result_code == CONSTANT.CODE_SUCCESS {
                    self.totalDataSource = data as! [VideoChapterModel]
                    self.tblDataSource = self.totalDataSource
                    self.uiTableview.reloadData()
                    
                    self.lblTatalCount.text = "Total Chapter: \(self.totalDataSource.count)"
                    self.imgSubjectLogo.kf.setImage(with: URL(string: subject.imgName), placeholder: UIImage(named: "placeholder"))
                    self.lblSubjectName.text = subject.title
//                    self.lblData.text   = subject
                } else {
                    self.showError(msg)
                }
            }
        }
    }
    
    @objc func puchaseItem() {
        if isReadyPurchase == true {
            isReadyPurchase = false
            checkInvalidPurchase()
        } else {
            tblDataSource = totalDataSource.filter{ ($0.is_paid == 0) }
            isReadyPurchase = true
            selectedItemForPurchase.removeAll()
            for _ in tblDataSource {
                selectedItemForPurchase.append(false)
            }
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
    
    func callPurchaseAPI(_ type: String) {

        let toVC = self.storyboard?.instantiateViewController( withIdentifier: "PayMFPaymentVC") as! PayMFPaymentVC
        toVC.modalPresentationStyle = .fullScreen
        toVC.amountPay = getPriceForPurchase()
        self.navigationController?.pushViewController(toVC, animated: true)
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
        var params = getSelectedChapterForPurchase()
        params["promo_code"] = promo_code
        
        showLoadingView(vc: self, label: CONSTANT.LOADING_TEXT_REQ)
        APIManager.shared.payVideoByPromo(params) { (result_code, msg, data) in
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
            "video_type"    : "igcse"
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
        selectedItemForPurchase[sender.tag] = sender.isSelected //!selectedItemForPurchase[sender.tag]
        uiTableview.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
    }

}

extension OneIGCSEVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.count > 0 {
            tblDataSource = totalDataSource.filter{ ($0.video_name.lowercased().contains(searchBar.text!.lowercased()) || "\($0.chapter_num)"==searchBar.text!) }
            uiTableview.reloadData()
        } else {
            tblDataSource = totalDataSource
            uiTableview.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        tblDataSource = totalDataSource.filter{ ($0.video_name.lowercased().contains(searchBar.text!.lowercased()) || "\($0.chapter_num)"==searchBar.text!) }
        uiTableview.reloadData()
    }
}


// MARK: - Table view data source
extension OneIGCSEVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tblDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OneIGCSECell") as! OneChapterCell
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
    
    @IBAction func didChangedSelectState(_ sender: UIButton) {
        selectedItemForPurchase[sender.tag] = !selectedItemForPurchase[sender.tag]
        uiTableview.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
    }
}

// MARK: - Table view data source
extension OneIGCSEVC: UITableViewDelegate {
    
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
