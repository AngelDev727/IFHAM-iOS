//
//  ListTestBankVC.swift
//  IFHAM
//
//  Created by AngelDev on 6/2/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit

class ListTestBankVC: BaseAndMenuVC {

    @IBOutlet weak var colTestBankVC: UICollectionView!
    var dataSource = [CategoryModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    
    func initView() {
        self.title = "List of Test Bank"
        
        if fromMenu {
            setNavigationBarColors()
        } else {
            removeNavigationBarColors()
        }
        colTestBankVC.dataSource = self
        colTestBankVC.delegate = self
        loadData()
    }
    
    func loadData() {
        showLoadingView(vc: self, label: CONSTANT.LOADING_TEXT_REQ)
        APIManager.shared.getTestBankData { (result_code, msg, data) in
            self.hideLoadingView()
            if result_code == CONSTANT.CODE_SUCCESS {
                
                self.dataSource = data as! [CategoryModel]
                self.colTestBankVC.reloadData()
                
            } else {
                self.showAlert("Something's wrong")
            }
        }
    }
}

//MARK:--- UICollectionViewDelegate
extension ListTestBankVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedItemOfCategory = dataSource[indexPath.row]
        gotoCategoryItemPage(.testbank)
    }
}


//MARK:--- UICollectionView DataSource
extension ListTestBankVC : UICollectionViewDataSource {
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
extension ListTestBankVC : UICollectionViewDelegateFlowLayout {
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
