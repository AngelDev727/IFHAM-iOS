//
//  ListBookSolutionVC.swift
//  IFHAM
//
//  Created by AngelDev on 6/2/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit

class ListBookSolutionVC: BaseAndMenuVC {

    @IBOutlet weak var colBookSolution: UICollectionView!
    var dataSource = [CategoryModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    
    func initView() {
        self.title = "List of Book Solution"
        
        if fromMenu {
            setNavigationBarColors()
        } else {
            removeNavigationBarColors()
        }
        
        colBookSolution.dataSource = self
        colBookSolution.delegate = self
        loadData()
    }
    
    func loadData() {
        showLoadingView(vc: self, label: CONSTANT.LOADING_TEXT_REQ)
        APIManager.shared.getBookSolutionData { (result_code, msg, data) in
            
            self.hideLoadingView()
            if result_code == CONSTANT.CODE_SUCCESS {
                
                self.dataSource = data as! [CategoryModel]
                self.colBookSolution.reloadData()
                
            } else {
                self.showAlert("Something's wrong")
            }
        }
    }
}



//MARK:--- UICollectionViewDelegate
extension ListBookSolutionVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedItemOfCategory = dataSource[indexPath.row]
        gotoCategoryItemPage(.booksolution)
    }
}


//MARK:--- UICollectionView DataSource
extension ListBookSolutionVC : UICollectionViewDataSource {
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
extension ListBookSolutionVC : UICollectionViewDelegateFlowLayout {
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
