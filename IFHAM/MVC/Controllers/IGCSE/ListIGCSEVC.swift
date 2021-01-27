//
//  ListIGCSEVC.swift
//  IFHAM
//
//  Created by AngelDev on 6/2/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit

class ListIGCSEVC: BaseAndMenuVC {

    @IBOutlet weak var colIGCSE: UICollectionView!
    @IBOutlet weak var uiSearchBar: UISearchBar!
    
    
    var dataSource = [CategoryModel]()
    var allListOfIGCSE = [CategoryModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }
    
    override func viewDidLayoutSubviews() {
        setupSearchBar(searchBar: uiSearchBar)
    }
    
    func initView() {
        self.title = "List of IGCSE subject"
        
        if fromMenu {
            setNavigationBarColors()
        } else {
            removeNavigationBarColors()
        }
        
        colIGCSE.dataSource = self
        colIGCSE.delegate = self
        colIGCSE.reloadData()
        
        loadData()
    }
    
    func loadData() {
        showLoadingView(vc: self, label: CONSTANT.LOADING_TEXT_REQ)
        APIManager.shared.getIgcseData { (result_code, msg, data) in
            self.hideLoadingView()
            if result_code == CONSTANT.CODE_SUCCESS {
                
                self.allListOfIGCSE = data as! [CategoryModel]
                self.dataSource = self.allListOfIGCSE
                self.colIGCSE.reloadData()
            } else {
                self.showAlert("Something's wrong")
            }
        }
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
}


//MARK:--- UICollectionViewDelegate
extension ListIGCSEVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedItemOfCategory = dataSource[indexPath.row]
        gotoCategoryItemPage(.igcse)
    }
}


//MARK:--- UICollectionView DataSource
extension ListIGCSEVC : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListUniversityCell", for: indexPath) as! ListCatogeryCell
        cell.entity = dataSource[indexPath.row]
        return cell
    }
}

//MARK:--- UICollectionView DelegateFlowLayout
extension ListIGCSEVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let w : CGFloat = (collectionView.frame.size.width - 10) / 3
        let h : CGFloat = 160

        return CGSize(width: w, height: h)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
}

extension ListIGCSEVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.count > 0 {
            dataSource = allListOfIGCSE.filter{ ($0.title.lowercased().contains(searchBar.text!.lowercased())) }
            colIGCSE.reloadData()
        } else {
            dataSource = allListOfIGCSE
            colIGCSE.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        dataSource = allListOfIGCSE.filter{ ($0.title.lowercased().contains(searchBar.text!.lowercased())) }
        colIGCSE.reloadData()
    }
}
