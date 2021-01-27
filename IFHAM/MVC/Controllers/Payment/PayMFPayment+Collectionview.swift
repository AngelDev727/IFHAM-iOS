//
//  PayMFPayment+Collectionview.swift
//  IFHAM
//
//  Created by AngelDev on 7/2/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit

extension PayMFPaymentVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let paymentMethods = paymentMethods else {
            return 0
        }
        return paymentMethods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MFPaymentCell", for: indexPath) as! MFPaymentCell
        if let paymentMethods = paymentMethods, !paymentMethods.isEmpty {
            let selectedIndex = selectedPaymentMethodIndex ?? -1
            cell.configure(paymentMethod: paymentMethods[indexPath.row], selected: selectedIndex == indexPath.row)
        }
        return cell
    }
}

extension PayMFPaymentVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPaymentMethodIndex = indexPath.row
        butPay.isEnabled = true
        
        if let paymentMethods = paymentMethods {
            if paymentMethods[indexPath.row].isDirectPayment {
                hideCardInfoStacksView(isHidden: false)
            } else {
                hideCardInfoStacksView(isHidden: true)
            }
        }
        collectionView.reloadData()
    }
}
