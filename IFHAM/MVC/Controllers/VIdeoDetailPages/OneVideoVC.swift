//
//  OneVideoVC.swift
//  IFHAM
//
//  Created by AngelDev on 6/4/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import CarbonKit
import AVKit

var currentVedeoChapter: VideoChapterModel? = nil

class OneVideoVC: BaseVC {

    @IBOutlet weak var uiVideoView: UIView!
    @IBOutlet weak var lblInstructor: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblVideoInfo: UILabel!
    @IBOutlet weak var uiContainer: UIView!
    
    var tabSwipe: CarbonTabSwipeNavigation!
    var player: AVPlayer!
    var playerViewController: AVPlayerViewController!
    var observer: NSObjectProtocol?
    var isCaptured = false

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(selectedVideo(_:)), name: .startVideo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadedVideos(_:)), name: .loadVideos, object: nil)
        UIScreen.main.addObserver(self, forKeyPath: "captured", options: .new, context: nil)

        initView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        player.pause()
        player.seek(to: CMTime.zero)
        playerViewController.view.removeFromSuperview()

        NotificationCenter.default.removeObserver(self)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "captured") {
            isCaptured = UIScreen.main.isCaptured

            if isCaptured == true {
                checkVideoRecording()
            }
            
        } else if keyPath == "status" {
            if player.status == .readyToPlay {
//                player.play()
            }
            
        } else if keyPath == "timeControlStatus" {
            if #available(iOS 10.0, *) {
                if player.timeControlStatus == .playing {
                    print("player.timeControlStatus::::playing")
                    checkVideoRecording()
                } else {
                    print("player.timeControlStatus::::no-playing")
                }
            }
        } else if keyPath == "rate" {
            
            if player.rate > 0 {
                print("player.timeControlStatus::::playing")
                checkVideoRecording()
            } else {
                print("player.timeControlStatus::::no-playing")
            }
        }
    }
    
    //MARK:-- custom function
    func initView() {
        
        if let subject = selectedItemOfCategory, let chapter = currentVedeoChapter {
            let label = UILabel()
            label.backgroundColor = .clear
            label.numberOfLines = 0
            label.font = UIFont.boldSystemFont(ofSize: 16.0)
            label.textAlignment = .center
            label.textColor = .white
            label.text = subject.title + ", Chapter \(chapter.chapter_num)"
            self.navigationItem.titleView = label
            
            if !subject.preview_video.isEmpty {
                playVideo(subject.preview_video)
            } else {
                player = AVPlayer()
            }
            setPlayerInfo()
        } else {
            doDismiss()
        }
        
        setCarbonKitAndStyle()
        
    }
    
    func setCarbonKitAndStyle() {

        tabSwipe = CarbonTabSwipeNavigation(items: ["Lectures", "Questions", "Others"], delegate: self)
        
        // Custimize segmented control
        tabSwipe.carbonSegmentedControl?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        tabSwipe.carbonSegmentedControl?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: CONSTANT.COLOR_PRIMARY!], for: .selected)
        tabSwipe.insert(intoRootViewController: self, andTargetView: uiContainer)
        //For every tab extra with
//        tabSwipe.setTabExtraWidth(40)
        let widthOfTabIcons = self.view.frame.size.width / 3
        tabSwipe.carbonSegmentedControl?.setWidth(widthOfTabIcons, forSegmentAt: 0)
        tabSwipe.carbonSegmentedControl?.setWidth(widthOfTabIcons, forSegmentAt: 1)
        tabSwipe.carbonSegmentedControl?.setWidth(widthOfTabIcons, forSegmentAt: 2)
        tabSwipe.toolbarHeight.constant = 44
        tabSwipe.toolbar.isTranslucent = false
        tabSwipe.toolbar.barTintColor = CONSTANT.COLOR_LIGHT_PRIMARY
        tabSwipe.setIndicatorColor(CONSTANT.COLOR_PRIMARY)
        
    }
    
    // handle notification
    @objc func selectedVideo(_ notification: NSNotification) {
        print(notification.userInfo ?? "")
        if let dict = notification.userInfo as NSDictionary? {
            if let urlStr = dict["url"] as? String {
                playVideo(urlStr)
            }
            
            if let instructor = dict["instructor"] as? String {
                lblInstructor.text = instructor
            }
        }
    }
    
    @objc func handleCapturedDidChange(notification:Notification){
        isCaptured = UIScreen.main.isCaptured
        checkVideoRecording()
    }
    
    @objc func loadedVideos(_ notification: NSNotification) {
        
        if let dict = notification.userInfo as NSDictionary? {
            if let count = dict["video_count"] as? Int, let time = dict["total_time"] as? Int, let price = dict["total_price"] as? Float {
                 
                
                let sec = time % 60
                let min = (time - sec) / 60 % 60
                let hr = (time - min * 60 - sec) / 3600

                let timeStr = ((hr > 0) ? " \(hr) Hrs" : "")
                    + ((min > 0) ? " \(min) Mins" : "")
                    + ((sec > 0) ? " \(sec) Secs" : "")
                lblPrice.text = "\(price) KWD"
                lblVideoInfo.text = "\(count) Videos |" + timeStr
            }
        }
    }
    
    @objc func playerItemDidReachStart() {
        checkVideoRecording()
    }
    
    func checkVideoRecording() {
        
        if UIScreen.main.isCaptured {
            showError("You cannot play video because you are recording this screen.")
            player.pause()
            player.seek(to: CMTime.zero)
        }
    }
    
    func playVideo(_ url: String) {
        
        if url == "" {
            showToast("No Video data.")
            return
        }
        
        let videoURL = URL(string: url)!
        let asset = AVAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        setPlayerInfo()
        player.play()
        
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main, using: { (nc) in

            self.lblInstructor.text = "..."
            NotificationCenter.default.post(name: .endVideo, object: nil)
            if let observer = self.observer {
                NotificationCenter.default.removeObserver(observer)
            }
        })
        
        checkVideoRecording()
    }
    
    func setPlayerInfo() {

        player.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
        if #available(iOS 10.0, *) {
            player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        } else {
            player.addObserver(self, forKeyPath: "rate", options: [.old, .new], context: nil)
        }
        
        self.playerViewController = AVPlayerViewController()
        playerViewController.player = self.player
        playerViewController.view.frame = self.uiVideoView.frame
//        playerViewController.player?.pause()
        self.uiVideoView.addSubview((playerViewController.view)!)
    }
}

extension OneVideoVC: CarbonTabSwipeNavigationDelegate {
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        
        guard let storyboard = storyboard else { return UIViewController() }
        if index == 0 {
            return storyboard.instantiateViewController(withIdentifier: "ListVideoOfChapterVC")
        } else if index == 1 {
            return storyboard.instantiateViewController(withIdentifier: "QuestionsOfChapterVC")
        }
        return storyboard.instantiateViewController(withIdentifier: "OtherDetailVC")
    }
}

