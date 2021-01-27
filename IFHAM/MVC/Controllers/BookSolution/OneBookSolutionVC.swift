//
//  OneBookSolutionVC.swift
//  IFHAM
//
//  Created by AngelDev on 6/2/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import Kingfisher

class OneBookSolutionVC: BaseVC {

    @IBOutlet weak var imgBookLogo: UIImageView!
    @IBOutlet weak var lblBookTitle: UILabel!
    @IBOutlet weak var lblBookIndex: UILabel!
    @IBOutlet weak var lblTotalCount: UILabel!
    @IBOutlet weak var uiSearchBar: UISearchBar!
    @IBOutlet weak var uiTableview: UITableView!
    
    var totalDataSource = [PDFdocModel]()
    var tblDataSource   = [PDFdocModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
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
        
        self.title = "List of Chapters"
        lblTotalCount.text = "Total Chapter: 0"
        if let category = selectedItemOfCategory {
            
            if category.imgName.starts(with: "http") {
                imgBookLogo.kf.setImage(with: URL(string: category.imgName), placeholder: UIImage(named: "placeholder"))
            } else {
                if let img = UIImage(named: category.imgName) {
                    imgBookLogo.image = img
                }
            }
            lblBookTitle.text = category.title
            lblBookTitle.numberOfLines = 0
            lblBookIndex.isHidden = true
        }
        
        uiTableview.dataSource = self
        uiTableview.delegate = self
        uiTableview.tableFooterView = UIView()
        loadData()
    }
    
    func loadData() {

        if let subject = selectedItemOfCategory {
            showLoadingView(vc: self, label: CONSTANT.LOADING_TEXT_REQ)
            APIManager.shared.getChaptersOfDocument(subject.row_id, subject.kind) { (result_code, msg, data) in
                
                self.hideLoadingView()
                if result_code == CONSTANT.CODE_SUCCESS {
                    self.totalDataSource = data as! [PDFdocModel]
                    self.tblDataSource = self.totalDataSource
                    self.uiTableview.reloadData()
                    self.lblTotalCount.text = "Total Chapter: \(self.tblDataSource.count)"
                } else {
                    self.showError(msg)
                }
            }
        }
    }
    
    func gotoDetailPage(_ indexNum: Int) {
        openPDFFromURL(tblDataSource[indexNum])
    }
}

extension OneBookSolutionVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.count > 0 {
                
            tblDataSource = totalDataSource.filter{ ($0.doc_title.lowercased().contains(searchBar.text!.lowercased()) || "\($0.chapter_num)"==searchBar.text!) }
            uiTableview.reloadData()
        } else {
            tblDataSource = totalDataSource
            uiTableview.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        tblDataSource = totalDataSource.filter{ ($0.doc_title.lowercased().contains(searchBar.text!.lowercased()) || "\($0.chapter_num)"==searchBar.text!) }
        uiTableview.reloadData()
    }
}


// MARK: - Table view data source
extension OneBookSolutionVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tblDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OneBookSolutionCell") as! OnePDFCell
        cell.entity = tblDataSource[indexPath.row]
        return cell
    }
}

// MARK: - Table view data source
extension OneBookSolutionVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.gotoDetailPage(indexPath.row)
    }
}
