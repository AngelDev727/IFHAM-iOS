//
//  SubjectListVC.swift
//  IFHAM
//
//  Created by AngelDev on 6/3/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit

class SubjectListVC: BaseVC {

    @IBOutlet weak var colSubject: UICollectionView!
    @IBOutlet weak var uiSearchBar: UISearchBar!
    
    var dataSource = [CategoryModel]()
    var allListOfIGCSE = [CategoryModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    func initView() {
        self.title = "List of Subject"
        
        colSubject.dataSource = self
        colSubject.delegate = self
        colSubject.reloadData()
        
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        setupSearchBar(searchBar: uiSearchBar)
    }

    func loadData() {
        
        if let curUni = selectedItemOfCategory {
            showLoadingView(vc: self, label: CONSTANT.LOADING_TEXT_REQ)
            APIManager.shared.getSubjectOfUniData(curUni.row_id) { (result_code, msg, data) in
                self.hideLoadingView()
                if result_code == CONSTANT.CODE_SUCCESS {
                    
                    self.allListOfIGCSE = data as! [CategoryModel]
                    
                    if self.allListOfIGCSE.count == 0 {
                        self.showToastCenter("No subject registerd.", duration: 2)
                    } else {
                        self.dataSource = self.allListOfIGCSE
                        self.colSubject.reloadData()
                    }
                    
                } else {
                    self.showAlert("Something's wrong.")
                }
            }
            
        } else {
            showAlert("Please select university.")
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
extension SubjectListVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let toVC = self.storyboard?.instantiateViewController( withIdentifier: "OneSubjectOfUniVC") as! OneSubjectOfUniVC
        toVC.modalPresentationStyle = .fullScreen
        toVC.selectedSubject = dataSource[indexPath.row]
        
        self.navigationController?.pushViewController(toVC, animated: true)
    }
}


//MARK:--- UICollectionView DataSource
extension SubjectListVC : UICollectionViewDataSource {
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
extension SubjectListVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let w : CGFloat = (collectionView.frame.size.width - 10) / 3
        let h : CGFloat = 170

        return CGSize(width: w, height: h)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
}

extension SubjectListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.count > 0 {
            dataSource = allListOfIGCSE.filter{ ($0.title.lowercased().contains(searchBar.text!.lowercased())) }
            colSubject.reloadData()
        } else {
            dataSource = allListOfIGCSE
            colSubject.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        dataSource = allListOfIGCSE.filter{ ($0.title.lowercased().contains(searchBar.text!.lowercased())) }
        colSubject.reloadData()
    }
}
