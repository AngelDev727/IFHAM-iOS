//
//  OtherDetailVC.swift
//

import UIKit

class OtherDetailVC: BaseVC {

    @IBOutlet weak var txvDetail: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }
    
    func setupView() {
        txvDetail.text = "No data yet."
    }

}
