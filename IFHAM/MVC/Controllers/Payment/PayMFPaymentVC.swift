//
//  PayMFPaymentVC.swift
//  IFHAM
//
//  Created by AngelDev on 7/2/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import MFSDK

class PayMFPaymentVC: BaseVC {

    //MARK: Variables
    var amountPay: Float? = nil
    var paymentMethods: [MFPaymentMethod]?
    var selectedPaymentMethodIndex: Int?
    
    //at list one product Required
    let productList = NSMutableArray()
    
    @IBOutlet weak var lblPayAmount: UILabel!
    @IBOutlet weak var uiCollectionview: UICollectionView!
    @IBOutlet var cardInfoStackViews: [UIStackView]!
    @IBOutlet weak var butPay: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var monthTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var secureCodeTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        uiCollectionview.delegate = self
        uiCollectionview.dataSource = self
        butPay.isEnabled = false
        // Do any additional setup after loading the view.
        
        if amountPay != nil {
            lblPayAmount.text = "\(amountPay ?? 0) KWD"
        }
        
        self.title = "Info of Payment Gateway"
        setCardInfo()
        initiatePayment()
    }
    
    
    //MARK:- custom action
    @IBAction func didTapPay(_ sender: Any) {
        if let paymentMethods = paymentMethods, !paymentMethods.isEmpty {
            if let selectedIndex = selectedPaymentMethodIndex {
                
                if paymentMethods[selectedIndex].paymentMethodCode == MFPaymentMethodCode.applePay.rawValue {
                    executeApplePayPayment(paymentMethodId: paymentMethods[selectedIndex].paymentMethodId)
                } else if paymentMethods[selectedIndex].isDirectPayment {
                    executeDirectPayment(paymentMethodId: paymentMethods[selectedIndex].paymentMethodId)
                } else {
                    executePayment(paymentMethodId: paymentMethods[selectedIndex].paymentMethodId)
                }
            }
        } else {
            showError("Somthing's wrong.")
        }
    }
    
    @IBAction func sendPaymentDidTapped(_ sender: Any) {
        sendPayment()
    }
    
}


extension PayMFPaymentVC  {
    func startSendPaymentLoading() {
        /* errorCodeLabel.text = "Status:"
        resultTextView.text = "Result:"
        sendPaymentButton.setTitle("", for: .normal)
        sendPaymentActivityIndicator.startAnimating()*/
    }
    
    func stopSendPaymentLoading() {
        /* sendPaymentButton.setTitle("Send Payment", for: .normal)
        sendPaymentActivityIndicator.stopAnimating()*/
    }
    
    func startLoading() {
        butPay.setTitle("", for: .normal)
        activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        butPay.setTitle("Pay", for: .normal)
        activityIndicator.stopAnimating()
    }
    
    func showSuccess(_ message: String) {
        print("Pay result:", message)
        NotificationCenter.default.post(name: .paidVideosByPaymemt, object: nil, userInfo: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func showFailError(_ error: MFFailResponse) {
        print("responseCodePay result:", error.statusCode)
        print("Error:", error.errorDescription)
    }
}

extension PayMFPaymentVC {
    func hideCardInfoStacksView(isHidden: Bool) {
        for stackView in cardInfoStackViews {
            stackView.isHidden = isHidden
        }
    }
    private func setCardInfo() {
        cardNumberTextField.text = "5123450000000008"
        monthTextField.text = "05"
        yearTextField.text = "21"
        secureCodeTextField.text = "100"
    }
}
