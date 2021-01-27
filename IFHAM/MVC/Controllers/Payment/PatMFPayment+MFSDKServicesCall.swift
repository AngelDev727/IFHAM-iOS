//
//  PatMFPayment+MFSDKServicesCall.swift
//  IFHAM
//
//  Created by AngelDev on 7/2/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import MFSDK

extension PayMFPaymentVC {
    func initiatePayment() {
        let request = generateInitiatePaymentModel()
        startLoading()
        MFPaymentRequest.shared.initiatePayment(request: request, apiLanguage: .english, completion: { [weak self] (result) in
            self?.stopLoading()
            switch result {
            case .success(let initiatePaymentResponse):
                self?.paymentMethods = initiatePaymentResponse.paymentMethods
                
                let ids = [3, 4, 11] //AMEX, Sadad, Apple Pay,
                
                if self?.paymentMethods != nil {
                    
                    for index in stride(from: self!.paymentMethods!.count, to: 0, by: -1) {
                        
                        let one = self!.paymentMethods![index - 1]
                        
                        /*print("image:\(one.imageUrl)")
                        print("paymentMethodId:\(one.paymentMethodId)")
                        print("paymentMethodCode:\(one.paymentMethodCode)")
                        print("currencyIso:\(one.currencyIso)")
                        print("paymentMethodAr:\(one.paymentMethodAr)")
                        print("paymentMethodEn:\(one.paymentMethodEn)")
                        print("isDirectPayment:\(one.isDirectPayment)")
                        print("serviceCharge:\(one.serviceCharge)")
                        print("totalAmount:\(one.totalAmount)")
                        print("=============================")*/
                        
                        if ids.contains(one.paymentMethodId) {
                            self?.paymentMethods?.remove(at: index - 1)
                        }
                    }
                }
                
                self?.uiCollectionview.reloadData()
            case .failure(let failError):
                self?.showFailError(failError)
            }
        })
    }
    
    func executeDirectPayment(paymentMethodId: Int) {
        let request = getExecutePaymentRequest(paymentMethodId: paymentMethodId)
        let card = getCardInfo()
        startLoading()
        MFPaymentRequest.shared.executeDirectPayment(request: request, cardInfo: card, apiLanguage: .english) { [weak self] (response, invoiceId) in
            self?.stopLoading()
            switch response {
            case .success(let directPaymentResponse):
                var cardNumber = ""
                if let cardInfoResponse = directPaymentResponse.cardInfoResponse, let card = cardInfoResponse.cardInfo {
//                    self?.resultTextView.text = "Status: with card number: \(card.number)"
                    
                    cardNumber = card.number
                }
                if let invoiceId = invoiceId {
//                    self?.errorCodeLabel.text = "Success with invoice id \(invoiceId)"
                    self?.showSuccess(cardNumber + "; " + invoiceId)
                } else {
//                    self?.errorCodeLabel.text = "Success"
                    self?.showSuccess(cardNumber + "; " + "Success")
                }
            case .failure(let failError):

                self?.showFailError(failError)
                /*self?.resultTextView.text = "Error: \(failError.errorDescription)"
                if let invoiceId = invoiceId {
                    self?.errorCodeLabel.text = "Fail: \(failError.statusCode) with invoice id \(invoiceId)"
                } else {
                    self?.errorCodeLabel.text = "Fail: \(failError.statusCode)"
                }*/
            }
        }
    }
    
    func executeApplePayPayment(paymentMethodId: Int) {
        let request = getExecutePaymentRequest(paymentMethodId: paymentMethodId)
        startLoading()
        if #available(iOS 13.0, *) {
            MFPaymentRequest.shared.executeApplePayPayment(request: request, apiLanguage: .arabic) { [weak self] (response, invoiceId) in
                self?.stopLoading()
                switch response {
                case .success(let executePaymentResponse):
                    if let invoiceStatus = executePaymentResponse.invoiceStatus {
                        self?.showSuccess(invoiceStatus)
                    }
                case .failure(let failError):
                    self?.showFailError(failError)
                }
            }
        } else {
            // Fallback on earlier versions
            let urlScheme = "ifham.angeldev.com"
            MFPaymentRequest.shared.executeApplePayPayment(request: request, urlScheme: urlScheme, apiLanguage: .arabic) { [weak self] response, invoiceId  in
                self?.stopLoading()
                switch response {
                case .success(let executePaymentResponse):
                    if let invoiceStatus = executePaymentResponse.invoiceStatus {
                        self?.showSuccess(invoiceStatus)
                    }
                case .failure(let failError):
                    self?.showFailError(failError)
                }
            }
        }
    }

    func executePayment(paymentMethodId: Int) {
        let request = getExecutePaymentRequest(paymentMethodId: paymentMethodId)
        startLoading()
        MFPaymentRequest.shared.executePayment(request: request, apiLanguage: .arabic) { [weak self] response, invoiceId  in
            self?.stopLoading()
            switch response {
            case .success(let executePaymentResponse):
                if let invoiceStatus = executePaymentResponse.invoiceStatus {
                    self?.showSuccess(invoiceStatus)
                }
            case .failure(let failError):
                self?.showFailError(failError)
            }
        }
    }
    
    
    func sendPayment() {
        let request = getSendPaymentRequest()
        startSendPaymentLoading()
        MFPaymentRequest.shared.sendPayment(request: request, apiLanguage: .arabic) { [weak self] (result) in
            self?.stopSendPaymentLoading()
            switch result {
            case .success(let sendPaymentResponse):
                if let invoiceURL = sendPaymentResponse.invoiceURL {
//                    self?.errorCodeLabel.text = "Success"
                    print("result: send this link to your customers \(invoiceURL)")
                }
            case .failure(let failError):
                self?.showFailError(failError)
            }
            
        }
    }
}

extension PayMFPaymentVC {
    private func generateInitiatePaymentModel() -> MFInitiatePaymentRequest {
        // you can create initiate payment request with invoice value and currency
        // let invoiceValue = Double(amountTextField.text ?? "") ?? 0
        // let request = MFInitiatePaymentRequest(invoiceAmount: invoiceValue, currencyIso: .kuwait_KWD)
        // return request
        
        let request = MFInitiatePaymentRequest()
        return request
    }
    
    private func getCardInfo() -> MFCardInfo {
        let cardNumber = cardNumberTextField.text ?? ""
        let cardExpiryMonth = monthTextField.text ?? ""
        let cardExpiryYear = yearTextField.text ?? ""
        let cardSecureCode = secureCodeTextField.text ?? ""
        
        let card = MFCardInfo(cardNumber: cardNumber, cardExpiryMonth: cardExpiryMonth, cardExpiryYear: cardExpiryYear, cardSecurityCode: cardSecureCode, saveToken: false)
//        card.bypass = false
        return card
    }
    
    private func getExecutePaymentRequest(paymentMethodId: Int) -> MFExecutePaymentRequest {
        let invoiceValue = Decimal(Double(exactly: amountPay!) ?? 0)
        let request = MFExecutePaymentRequest(invoiceValue: invoiceValue , paymentMethod: paymentMethodId)
        //request.userDefinedField = ""
        request.customerEmail = "a@b.com"// must be email
        request.customerMobile = ""
        request.customerCivilId = ""
        let address = MFCustomerAddress(block: "ddd", street: "sss", houseBuildingNo: "sss", address: "sss", addressInstructions: "sss")
        request.customerAddress = address
        request.customerReference = ""
        request.language = .english
        request.mobileCountryCode = MFMobileCountryCodeISO.kuwait.rawValue
        request.displayCurrencyIso = .kuwait_KWD
        // Uncomment this to add products for your invoice
//         var productList = [MFProduct]()
//        let product = MFProduct(name: "ABC", unitPrice: 1.887, quantity: 1)
//         productList.append(product)
//         request.invoiceItems = productList
        return request
    }
    
    func getSendPaymentRequest() -> MFSendPaymentRequest {
        let invoiceValue = Decimal(Double(exactly: amountPay!) ?? 0)
        let request = MFSendPaymentRequest(invoiceValue: invoiceValue, notificationOption: .all, customerName: "Test")
        
        // send invoice link as sms to specified number
        // let request = MFSendPaymentRequest(invoiceValue: invoiceValue, notificationOption: .sms, customerName: "Test")
        // request.customerMobile  = "" // required here
        
        // get invoice link
        // let request = MFSendPaymentRequest(invoiceValue: invoiceValue, notificationOption: .link, customerName: "Test")
        
        //  send invoice link to email
        // let request = MFSendPaymentRequest(invoiceValue: invoiceValue, notificationOption: .email, customerName: "Test")
        // request.customerEmail = "" required here
        
        
        
        //request.userDefinedField = ""
        request.customerEmail = "a@b.com"// must be email
        request.customerMobile = "mobile no"//Required
        request.customerCivilId = ""
        request.mobileCountryIsoCode = MFMobileCountryCodeISO.kuwait.rawValue
        request.customerReference = ""
        request.language = .english
        let address = MFCustomerAddress(block: "ddd", street: "sss", houseBuildingNo: "sss", address: "sss", addressInstructions: "sss")
        request.customerAddress = address
        request.customerReference = ""
        request.language = .english
        request.displayCurrencyIso = .kuwait_KWD
        let date = Date().addingTimeInterval(1000)
        request.expiryDate = date
        return request
    }
}

 // MARK: - Recurring Payment
extension PayMFPaymentVC {

    func executeRecurringPayment(paymentMethodId: Int) {
        let request = MFExecutePaymentRequest(invoiceValue: 5.000 , paymentMethod: paymentMethodId)
        let card = MFCardInfo(cardNumber: "", cardExpiryMonth: "", cardExpiryYear: "", cardSecurityCode: "")
        MFPaymentRequest.shared.executeRecurringPayment(request: request, cardInfo: card, recurringIntervalDays: 10, apiLanguage: .english) { (response, invoiceId) in
            switch response {
            case .success(let directPaymentResponse):
                if let cardInfoResponse = directPaymentResponse.cardInfoResponse, let card = cardInfoResponse.cardInfo {
                    print("Status: with card number: \(card.number)")
                    print("Status: with recurring Id: \(cardInfoResponse.recurringId ?? "")")
                }
                if let invoiceId = invoiceId {
                    print("Success with invoice id \(invoiceId)")
                } else {
                    print("Success")
                }
            case .failure(let failError):
                print("Error: \(failError.errorDescription)")
                if let invoiceId = invoiceId {
                    print("Fail: \(failError.statusCode) with invoice id \(invoiceId)")
                } else {
                    print("Fail: \(failError.statusCode)")
                }
            }
        }
    }

    func executeRecurringPayment(recurringId: String) {
        MFPaymentRequest.shared.cancelRecurringPayment(recurringId: recurringId, apiLanguage: .english) { [weak self] (result) in
            switch result {
            case .success(let isCanceled):
                if isCanceled {
                    print("Success")
                }

            case .failure(let failError):
                self?.showFailError(failError)
            }
        }
    }

}

