//
//  MenuVC.swift
//  IFHAM
//
//  Created by AngelDev on 5/29/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import SideMenu
import Kingfisher

class LeftMenuVC: BaseAndMenuVC {

    @IBOutlet weak var imgUserAvatar: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblPromoCode: UILabel!
    @IBOutlet weak var uiTableview: UITableView!
    @IBOutlet weak var butLogout: UIButton!
    @IBOutlet weak var imgPageBG: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        uiTableview.dataSource = self
        uiTableview.delegate = self
        uiTableview.reloadData()
        uiTableview.tableFooterView = UIView()
        
        guard let menu = navigationController as? SideMenuNavigationController, menu.blurEffectStyle == nil else {
            return
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(initProfile), name: .updatedProfile, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        fromMenu = false
        
        initProfile()
        
    }
    
    @objc func initProfile() {
        if let user = currentUser {
            lblUsername.text = user.full_name
            imgUserAvatar.kf.setImage(with: URL(string: user.photo_url), placeholder: UIImage(named: "profile"))
            lblPromoCode.numberOfLines = 0
            
            if user.promo_code != "" {
                lblPromoCode.text = "Promotion Code: " + user.promo_code + "\nExpire Date: " + getLocalTimeString(fromTime: user.expire_date, formatStyle: "MMM dd, yyyy")
            } else {
                lblPromoCode.text = ""
            }
        }
    }
    
    @IBAction func didTapProfile(_ sender: Any) {
        curretMenuIndex = -1
        gotoVCFromMenu("ProfileVC")
    }
    
    @IBAction func didTapLogout(_ sender: Any) {
        
        showAlert(title: R.string.CONFIRM_LOGOUT, message: "", okButtonTitle: R.string.OK, cancelButtonTitle: R.string.CANCEL, okClosure: {
            self.doLogout()
        }) {
            //did cancel
        }
        
    }
}


// MARK: - Table view data source
extension LeftMenuVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeftMenuCell") as! MenuCell
        
        cell.lblMenuName.text = menus[indexPath.row]
        cell.imgMenuIcon.image = UIImage(named: icons[indexPath.row])
        cell.swiNotification.isHidden = true
        
        if let menu = navigationController as? SideMenuNavigationController {
            cell.blurEffectStyle = menu.blurEffectStyle
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menus.count
    }
}

// MARK: - Table view data source
extension LeftMenuVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        fromMenu = true
        if indexPath.row > 0 && indexPath.row < 6 {
            fromMenu = true
        } else {
            fromMenu = false
        }
        
        if indexPath.row == 5 {
            if let url = URL(string: "https://nedress.com/privacy-policy") {
                UIApplication.shared.open(url)
            }
        } else {
            self.changeViewController(indexPath.row)
        }
        
    }    
}
