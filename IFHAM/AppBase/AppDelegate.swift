//
//  AppDelegate.swift
//  IFHAM
//
//  Created by AngelDev on 5/14/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import MFSDK
import IQKeyboardManagerSwift
import SwiftMessages
import AudioToolbox


var deviceTokenString = ""

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 13.0, *) {
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.backgroundColor = .white
            window.makeKeyAndVisible()
            window.overrideUserInterfaceStyle = .light
            self.window = window
        }
        FirebaseApp.configure()
        
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert,UIUserNotificationType.badge, UIUserNotificationType.sound]
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        registerForPushNotifications()
        
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.layoutIfNeededOnUpdate = true
        
        /// My Fatoorah----------------------------------------
        
        //(Token) for testing
        let testDirectPaymentToken = "7Fs7eBv21F5xAocdPvvJ-sCqEyNHq4cygJrQUFvFiWEexBUPs4AkeLQxH4pzsUrY3Rays7GVA6SojFCz2DMLXSJVqk8NG-plK-cZJetwWjgwLPub_9tQQohWLgJ0q2invJ5C5Imt2ket_-JAlBYLLcnqp_WmOfZkBEWuURsBVirpNQecvpedgeCx4VaFae4qWDI_uKRV1829KCBEH84u6LYUxh8W_BYqkzXJYt99OlHTXHegd91PLT-tawBwuIly46nwbAs5Nt7HFOozxkyPp8BW9URlQW1fE4R_40BXzEuVkzK3WAOdpR92IkV94K_rDZCPltGSvWXtqJbnCpUB6iUIn1V-Ki15FAwh_nsfSmt_NQZ3rQuvyQ9B3yLCQ1ZO_MGSYDYVO26dyXbElspKxQwuNRot9hi3FIbXylV3iN40-nCPH4YQzKjo5p_fuaKhvRh7H8oFjRXtPtLQQUIDxk-jMbOp7gXIsdz02DrCfQIihT4evZuWA6YShl6g8fnAqCy8qRBf_eLDnA9w-nBh4Bq53b1kdhnExz0CMyUjQ43UO3uhMkBomJTXbmfAAHP8dZZao6W8a34OktNQmPTbOHXrtxf6DS-oKOu3l79uX_ihbL8ELT40VjIW3MJeZ_-auCPOjpE3Ax4dzUkSDLCljitmzMagH2X8jN8-AYLl46KcfkBV"
        
        let liveDirectPaymentToken = "g1ckGc9fDGyMajzbDVeSjvtSG0ZsU6sCn5dt6r4Sv4vuIVl1uabIf4h6LUwHe4MoRmOLknuONY75zDOg9oiCHOvD8OJwcVYxch-hq1luAUShn-NVi5-673Wp32WiPdpf2AT4ClfnWsvR6lJ6PWIDQ38sBE4Sf8xV8vLvVZvL8UTVIvvGXWyIqVq92Lh85S7p-khR32hMwPAWx2pjVfXxjQXfmZuPMLnEto90slS3sWqjlb9S51FRukMFVjRHV4E2N6-OJObAwlgPsEuRJ2tXkI-37pJ9WgEikzo76EBRQJOe2uOLWmayJBhDJ6h6AoPGgtO4ytTCy69wY8rcDloTiGsRQ9SVOGJXH801lEtNh5--r4AlxBDcrKCSKB3vVoaRLoyNGkglUri2l-z-bDVk1buAzO8nbVzfUYRBEtYZgY042qOfLxWxmQN3_giBwL3P62M0APq_4LVI69z2woEPMknIfGzyYfQtrs1EBA4l7ijT6jHxyWq6CWmGv5rFPFyjmNZkbqNpOlff_Y-II3HEYBGxDsZ3lY6KKp4ziOVnInhppeZIqpQL6L3quG2r1Fh0ZJV7kxDXr9LORozG9WMCq7J41J4XShjsh0d2wIJ5Gk6woTXcNUIxnk8_NiOC5k_FkEtZlIYA9xb1ni5ZiUzyyi5f7ngxNAOr6AhT1zDdS8P1YvGN"
        
        let baseURL = "https://api.myfatoorah.com" //"https://apitest.myfatoorah.com" for testing
        MFSettings.shared.configure(token: liveDirectPaymentToken, baseURL: baseURL)
        
        // you can change color and title of nvgigation bar
        let them = MFTheme(navigationTintColor: .white, navigationBarTintColor: CONSTANT.COLOR_PRIMARY!, navigationTitle: "Payment", cancelButtonTitle: "Cancel")
        MFSettings.shared.setTheme(theme: them)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let paymentId = url[MFConstants.paymentId] {
            NotificationCenter.default.post(name: .applePayCheck, object: paymentId)
        }
        return true
    }
    
    //MARK:-   set push notifations
    func registerForPushNotifications() {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .sound, .badge]//[.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {(granted, error) in
                if granted {
                    print("Permission granted: \(granted)")
                    DispatchQueue.main.async() {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            })
            
            Messaging.messaging().delegate = self
            Messaging.messaging().shouldEstablishDirectChannel = true
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }
    
    func getRegisteredPushNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
            switch settings.authorizationStatus {
                case .authorized, .provisional:
                    print("The user agrees to receive notifications.")
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                case .denied:
                    print("Permission denied.")
                    // The user has not given permission. Maybe you can display a message remembering why permission is required.
                case .notDetermined:
                    print("The permission has not been determined, you can ask the user.")
                    self.getRegisteredPushNotifications()
                default:
                    return
            }
        })
    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != [] {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
 
        print("Successfully registered for notifications!")
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""

        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        print(":::::::::didRegisterForRemoteNotificationsWithDeviceToken::::::::: tokenString: \(tokenString)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let firebaseAuth = Auth.auth()

        if (firebaseAuth.canHandleNotification(userInfo)){
            print(userInfo)
            return
        }
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        let aps             = userInfo["aps"] as? [AnyHashable : Any]
//        let badgeCount      = aps!["badge"] as? Int ?? 0
        let alertMessage    = aps!["alert"] as? [AnyHashable : Any]
        let bodyMessage     = alertMessage!["body"] as! String
        let titleMessage    = alertMessage!["title"] as! String
        
        
        let view: MessageView
        view = try! SwiftMessages.viewFromNib()
        view.configureContent(title: titleMessage, body: bodyMessage, iconImage: UIImage(named: "ifham"), iconText: nil, buttonImage: nil, buttonTitle: "OK", buttonTapHandler: { _ in
            SwiftMessages.hide()
        })
        
        /////////////////////    theme 1
//        view.configureTheme(.info, iconStyle: .light)
//        view.accessibilityPrefix = "info"
        /////////////////////    theme 2
        let icon = UIImage(named: "AppIcon")
        view.configureTheme(backgroundColor: CONSTANT.COLOR_PRIMARY!, foregroundColor: UIColor.white, iconImage: icon?.resize(to: CGSize(width: 35, height: 35)), iconText: nil)
//        view.button?.setImage(Icon.errorSubtle.image, for: .normal)
        view.button?.setTitle("OK", for: .normal)
        view.button?.backgroundColor = UIColor.white ///UIColor.clear
        view.button?.tintColor = CONSTANT.COLOR_PRIMARY!
        
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .top
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        config.duration = .forever //.seconds(seconds: 5)
        config.dimMode = .blur(style: .dark, alpha: 0.5, interactive: true)
        config.shouldAutorotate = true
        config.interactiveHide = true
        config.preferredStatusBarStyle = .lightContent
        
        
        SwiftMessages.show(config: config, view: view)
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        sleep(1)
        completionHandler([])
    }
}

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        Messaging.messaging().subscribe(toTopic: "/topics/all")
        deviceTokenString = fcmToken
        print("fcmToken: ", fcmToken)
    }
}
