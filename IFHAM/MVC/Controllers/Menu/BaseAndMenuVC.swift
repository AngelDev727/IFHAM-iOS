//
//  BaseAndMenuVC.swift
//  IFHAM
//
//  Created by AngelDev on 5/31/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import SideMenu
import FirebaseAuth

var curretMenuIndex = 0
var newTitle    = ""
var isLoadMenu  = false
var fromMenu    = false

class BaseAndMenuVC: BaseVC {
    
    func setupMenu() {
        if isLoadMenu == false {
            setupSideMenu()
            updateMenus()
            isLoadMenu = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sideMenuNavigationController = segue.destination as? SideMenuNavigationController else { return }
        sideMenuNavigationController.settings = makeSettings()
    }
    
    func setNavigationBarColors() {
        self.navigationController?.navigationBar.barTintColor = CONSTANT.COLOR_PRIMARY
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style:.plain, target:nil, action:nil)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        
        // color for standard title label
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
    }
    
    func removeNavigationBarColors() {
        self.navigationItem.hidesBackButton = false
        self.navigationItem.leftBarButtonItem = nil
    }
    
    func gotoVCFromMenu(_ nameVC: String){
        let toVC = self.storyboard?.instantiateViewController( withIdentifier: nameVC)
        toVC!.modalPresentationStyle = .fullScreen
        self.navigationController?.dismiss(animated: false, completion: nil)
        self.navigationController?.pushViewController(toVC!, animated: true)
    }
    
    func setupSideMenu() {
        
        let lang = "en"
        if lang == "en" {
            SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNav") as? SideMenuNavigationController
            SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view, forMenu: .left)
        } else {
            SideMenuManager.default.rightMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "RightMenuNav") as? SideMenuNavigationController
            SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view, forMenu: .right)
        }

//        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view) // both of menu panel
    }
    
    func updateMenus() {
        let settings = makeSettings()
        SideMenuManager.default.leftMenuNavigationController?.settings = settings
        SideMenuManager.default.rightMenuNavigationController?.settings = settings
    }
    
    func makeSettings() -> SideMenuSettings {
        //.menuSlideIn, .viewSlideOut, .viewSlideOutMenuIn, .menuDissolveIn
        let presentationStyle = SideMenuPresentationStyle.menuSlideIn
        presentationStyle.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "menu_background"))
        presentationStyle.menuStartAlpha = 0.6
        presentationStyle.menuScaleFactor = 1
        presentationStyle.onTopShadowOpacity = 1
        presentationStyle.presentingEndAlpha = 0.3
        presentationStyle.presentingScaleFactor = 1
        
        var settings = SideMenuSettings()
        settings.presentationStyle = presentationStyle
        settings.menuWidth = min(view.frame.width, view.frame.height) * 0.7 //min(250, view.frame.height * 0.65)// //CGFloat(screenWidthSlider.value)
        settings.blurEffectStyle = nil//, nil, .dark, .light, .extraLight
        settings.statusBarEndAlpha = 0
        settings.dismissOnPush = true
//        settings.presentDuration = 1 // 0.5 second
        
        return settings
    }
    
    @objc func onSwitchNotification(_ sender: UISwitch) {
        
        if sender.isOn {
            print("notification is on")
            UserDefaults.standard.set(true, forKey: CONSTANT.KEY_NOTI_STATE)
        } else {
            print("notification is off")
            UserDefaults.standard.set(false, forKey: CONSTANT.KEY_NOTI_STATE)
            UIApplication.shared.unregisterForRemoteNotifications()
        }
    }
    
    // MARK: - left menu protocol
    func changeViewController(_ newMenuIndex: Int) {
        
        if curretMenuIndex == newMenuIndex {
            dismiss(animated: true, completion: nil)
            return
        } else {
            curretMenuIndex = newMenuIndex
        }
        
        newTitle = menus[newMenuIndex]
        gotoVCFromMenu(menusVCs[newMenuIndex])
    }
    
    func doLogout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            UserDefaults.standard.set(false, forKey: CONSTANT.KEY_LOGIN_STATE)
            gotoVC("LoginNav", false)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}

extension BaseAndMenuVC: SideMenuNavigationControllerDelegate {
    
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Appearing! (animated: \(animated))")
    }
    
    func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Appeared! (animated: \(animated))")
    }
    
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappearing! (animated: \(animated))")
    }
    
    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappeared! (animated: \(animated))")
    }
}
