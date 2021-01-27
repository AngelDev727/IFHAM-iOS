//
//  OnePDFVC.swift
//  IFHAM
//
//  Created by AngelDev on 6/4/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import PDFKit
import WebKit

class OnePDFVC: BaseVC {

    @IBOutlet weak var uiWKWebview: WKWebView!
    
    var onePdfData: PDFdocModel? = nil
    var pdfURLString: String? = nil
    var activityIndicator: UIActivityIndicatorView!
//    var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "estimatedProgress" {
//            progressView.progress = Float(uiWKWebview.estimatedProgress)
//        }
//    }
    
    //MARK:-- custom function
    func initView() {
        
        if let pdfModel = onePdfData {
            let label = UILabel()
            label.backgroundColor = .clear
            label.numberOfLines = 0
            label.font = UIFont.boldSystemFont(ofSize: 16.0)
            label.textAlignment = .center
            label.textColor = .white
            label.text = pdfModel.subject_name + ", Chapter \(pdfModel.chapter_num)"
            self.navigationItem.titleView = label
            
            print("pdfModel.doc_url: ", pdfModel.doc_url)
            if pdfModel.doc_url != "" {
                uiWKWebview.load(URLRequest(url: URL(string: pdfModel.doc_url)!))
            } else {
                showToast("No PDF data.")
            }
            
            uiWKWebview.navigationDelegate = self
            uiWKWebview.uiDelegate = self
            
            // add activity
            activityIndicator = UIActivityIndicatorView()
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            if #available(iOS 13.0, *) {
                activityIndicator.style = .large
            } else {
                // Fallback on earlier versions
            }

            view.addSubview(activityIndicator)
                

        } else {
            doDismiss()
        }
    }

    func showActivityIndicator(show: Bool) {
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}

extension OnePDFVC: UIDocumentInteractionControllerDelegate{
    
}

extension OnePDFVC: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        showActivityIndicator(show: false)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showActivityIndicator(show: true)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showActivityIndicator(show: false)
    }
}
