//
//  HomeVC.swift
//  IFHAM
//
//  Created by AngelDev on 5/29/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit
import ImageSlideshow
import SwiftyJSON

class HomeVC: BaseAndMenuVC {
    
    @IBOutlet weak var slideshow: ImageSlideshow!
    @IBOutlet weak var colUniversities: UICollectionView!
    @IBOutlet weak var colIGCSE: UICollectionView!
    @IBOutlet weak var colBooks: UICollectionView!
    @IBOutlet weak var colTestBank: UICollectionView!
    
    var adsData: [InputSource] = [ImageSource(image: UIImage(named: "hometemp1")!)]
    
    var inputData       = [InputSource]()
    var univesityData   = [CategoryModel]()
    var igcesData       = [CategoryModel]()
    var bookSloutionData = [CategoryModel]()
    var testBankData    = [CategoryModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    

    //MARK:- custom functions
    func initView() {
        
        setNavigationBarColors()
        setupMenu()
        self.title = CONSTANT.APP_NAME
        
        /// slideshow init
        slideshow.slideshowInterval = 2.5
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFit
        setIndicator(slideshow, "banner")
        if #available(iOS 13.0, *) {
            slideshow.activityIndicator = DefaultActivityIndicator(style: .medium, color: nil)
        } else {
            // Fallback on earlier versions
        }
        slideshow.delegate = self
        slideshow.setImageInputs(adsData)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        slideshow.addGestureRecognizer(recognizer)
        
        /// collectionveiw  data init
        colUniversities.dataSource = self
        colUniversities.delegate = self
        colUniversities.reloadData()
        
        colIGCSE.dataSource = self
        colIGCSE.delegate = self
        colIGCSE.reloadData()
        
        colBooks.dataSource = self
        colBooks.delegate = self
        colBooks.reloadData()
        
        colTestBank.dataSource = self
        colTestBank.delegate = self
        colTestBank.reloadData()
        
        loadHomeData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setHomeData(_:)), name: .getHomeData, object: nil)
        
    }
    
    func loadHomeData() {
        showLoadingView(vc: self, label: CONSTANT.LOADING_TEXT_REQ)
        APIManager.shared.getHomeData { (result_code, msg, data) in
            self.hideLoadingView()
            if result_code == CONSTANT.CODE_SUCCESS {
                
                let dataDict:[String: [String: Any]] = ["data": data!]
                NotificationCenter.default.post(name: .getHomeData, object: nil, userInfo: dataDict)
            }
        }
    }

    @objc func didTap() {
        let fullScreenController = slideshow.presentFullScreenController(from: self)
        setIndicator(fullScreenController.slideshow, "full")
//        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: UIActivityIndicatorView.Style.medium, color: nil)
        fullScreenController.slideshow.slideshowInterval = 5.0
        fullScreenController.slideshow.circular = true
    }
    
    @objc func setHomeData(_ notification: NSNotification) {
        
        if let dict = notification.userInfo as NSDictionary? {
            
            let data = dict["data"] as! NSDictionary
            /// set ads data and load ads sliderview
            adsData.removeAll()
            let adsTemp = JSON(data)["ads_data"].arrayValue
            for one in adsTemp {
                adsData.append(KingfisherSource(urlString: one.stringValue.replacingOccurrences(of: "http://localhost:1111/", with: HOST))!)
            }
            slideshow.setImageInputs(adsData)
            
            
            /// set univesity data and reload colUniversities
            univesityData.removeAll()
            let uniTemp = JSON(data)["uni_data"].arrayValue
            for one in uniTemp {
                univesityData.append(CategoryModel(dict: one, kind: "university"))
            }
            colUniversities.reloadData()
            
            
            /// set IGCSE data and reload colIGCSE
            igcesData.removeAll()
            let igcseTemp = JSON(data)["igcse_data"].arrayValue
            for one in igcseTemp {
                igcesData.append(CategoryModel(dict: one, kind: "igcse"))
            }
            colIGCSE.reloadData()
            
            
            // set BookSolution data and reload colBooks
            bookSloutionData.removeAll()
            let bookTemp = JSON(data)["book_data"].arrayValue
            for one in bookTemp {
                bookSloutionData.append(CategoryModel(dict: one, kind: "booksolution"))
            }
            colBooks.reloadData()
            
            // set TestBank data and reload colTestBank
            testBankData.removeAll()
            let testTemp = JSON(data)["test_data"].arrayValue
            for one in testTemp {
                testBankData.append(CategoryModel(dict: one, kind: "testbank"))
            }
            colTestBank.reloadData()
        }
    }
    
    func setIndicator (_ imgSlider: ImageSlideshow, _ type: String) {
        
        var limitCount = 10
        if type == "full" {
            limitCount = 20
        }
        
        if inputData.count > limitCount {
            let labelPageIndicator = LabelPageIndicator()
            labelPageIndicator.backgroundColor = .clear
            labelPageIndicator.textColor = .white
            imgSlider.pageIndicator = labelPageIndicator
            imgSlider.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .customBottom(padding: 10))
        }
        else {
            let pageControl = UIPageControl()
            pageControl.currentPageIndicatorTintColor = CONSTANT.COLOR_NAV_BAR
            pageControl.pageIndicatorTintColor = .lightGray
            imgSlider.pageIndicator = pageControl
            imgSlider.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .bottom)
        }
    }
    
    //MARK:---- custom action
    @IBAction func didTapViewAll(_ sender: UIButton) {
        gotoNavVC(viewAllPageNames[sender.tag])
    }
    
    
}

//MARK:--- ImageSlideshow Delegate
extension HomeVC: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
//        print("current page:", page)
    }
}


//MARK:--- ImageSlideshow fullscreen landscape setting
extension FullScreenSlideshowViewController {
    func currentOrientation() -> UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }
    
    override public var shouldAutorotate: Bool {
//        return true
        
        let or = UIDevice.current.orientation
        if or == UIDeviceOrientation.landscapeLeft || or == UIDeviceOrientation.landscapeRight || or == UIDeviceOrientation.unknown {
            return false
        }
        else {
            return true
        }
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    override public var interfaceOrientation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
}


//MARK:--- UICollectionViewDelegate
extension HomeVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.colUniversities {
            selectedItemOfCategory = univesityData[indexPath.row]
            gotoCategoryItemPage(.university)
        }
        else if collectionView == self.colIGCSE {
            selectedItemOfCategory = igcesData[indexPath.row]
            gotoCategoryItemPage(.igcse)
        }
        else if collectionView == self.colBooks {
            selectedItemOfCategory = bookSloutionData[indexPath.row]
            gotoCategoryItemPage(.booksolution)
        }
        else {
            selectedItemOfCategory = testBankData[indexPath.row]
            gotoCategoryItemPage(.testbank)
        }
    }
}


//MARK:--- UICollectionView DataSource
extension HomeVC : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.colUniversities {return univesityData.count}
        else if collectionView == self.colIGCSE {return igcesData.count}
        else if collectionView == self.colBooks {return bookSloutionData.count}
        
        return testBankData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.colUniversities {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeUniversityCell", for: indexPath) as! ListCatogeryCell
            cell.entity = univesityData[indexPath.row]
            return cell
        }
        else if collectionView == self.colIGCSE {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeIgcseCell", for: indexPath) as! ListCatogeryCell
            cell.entity = igcesData[indexPath.row]
            return cell
        }
        else if collectionView == self.colBooks {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeBookSolutionCell", for: indexPath) as! ListCatogeryCell
            cell.entity = bookSloutionData[indexPath.row]
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeTestBankCell", for: indexPath) as! ListCatogeryCell
        cell.entity = testBankData[indexPath.row]
        return cell
    }
}

//MARK:--- UICollectionView DelegateFlowLayout
extension HomeVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let w : CGFloat = (collectionView.frame.size.width - 10) / 3
        let h : CGFloat = collectionView.height

        return CGSize(width: w, height: h)
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
}
