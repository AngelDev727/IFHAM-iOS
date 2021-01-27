//
//  PrivacyVC.swift
//  IFHAM
//
//  Created by AngelDev on 6/3/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import WebKit

class PrivacyVC: BaseAndMenuVC {
    
    @IBOutlet weak var txvPrivacy: UITextView!
    
    private lazy var url = URL(string:"http://fromheadtotoebeauty.com/privacy")!
    private weak var webView: WKWebView!

    init (url: URL, configuration: WKWebViewConfiguration) {
        super.init(nibName: nil, bundle: nil)
        self.url = url
        navigationItem.title = ""
    }

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        
    }
    
    func initView() {
        self.title = "Privacy Policy"
        if fromMenu {
            setNavigationBarColors()
        } else {
            removeNavigationBarColors()
        }
        
        txvPrivacy.text = load(file: "terms")
        txvPrivacy.setPaddingSpace(top: 20, left: 16, bottom: 16, right: 16)
        txvPrivacy.setSamePaddingSpace(val: 16)

    }
    
    func load(file name:String) -> String {
        
        if let path = Bundle.main.path(forResource: name, ofType: "txt") {
            
            if let contents = try? String(contentsOfFile: path) {
                return contents
            } else {
                print("Error! - This file doesn't contain any text.")
            }
            
        } else {
            print("Error! - This file doesn't exist.")
        }
        
        return ""
    }
    
    private func initWebView() {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        view.addSubview(webView)
        showLoadingView()
        self.webView = webView
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
    }
}

extension PrivacyVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideLoadingView()
        guard let host = webView.url?.host else { return }
        print("loaded host name: ", host)
//        navigationItem.title = host
    }
}

extension PrivacyVC: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard navigationAction.targetFrame == nil, let url =  navigationAction.request.url else { return nil }
        let vc = PrivacyVC(url: url, configuration: configuration)
        if let navigationController = navigationController {
            navigationController.pushViewController(vc, animated: false)
            return vc.webView
        }
        present(vc, animated: true, completion: nil)
        return nil
    }
}

extension WKWebView {
    func loadPage(address url: URL) { load(URLRequest(url: url)) }
    func loadPage(address urlString: String) {
        guard let url = URL(string: urlString) else { return }
        loadPage(address: url)
    }
}
