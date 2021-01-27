//
//  QuestionsForChapterVC.swift
//  IFHAM
//
//  Created by AngelDev on 6/4/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit

class QuestionsOfChapterVC: BaseVC {

    @IBOutlet weak var uiTableview: UITableView!
    var tblDataSource       = [QuestionModel]()
    
    let textView = UITextView(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadData()
    }
    
    //MARK:-- custom function
    func initView() {
        
        uiTableview.dataSource = self
        uiTableview.delegate = self
    }
    
    func loadData() {
        
        APIManager.shared.getQuestionData(getInitParams()) { (result_code, msg, data) in
            if result_code == CONSTANT.CODE_SUCCESS {
                self.tblDataSource = data as! [QuestionModel]
                self.uiTableview.reloadData()
                self.uiTableview.scroll(to: .bottom, animated: true)
            } else {
                self.showAlert(msg)
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "bounds"{
            if let rect = (change?[NSKeyValueChangeKey.newKey] as? NSValue)?.cgRectValue {
                let margin: CGFloat = 8
                let xPos = rect.origin.x + margin
                let yPos = rect.origin.y + 54
                let width = rect.width - 2 * margin
                let height: CGFloat = 90

                textView.frame = CGRect.init(x: xPos, y: yPos, width: width, height: height)
            }
        }
    }
    
    //MARK:- custom actions
    @IBAction func didTapMakeQuestion(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Your Question", message: "\n\n\n\n\n", preferredStyle: .alert)

        let cancelAction = UIAlertAction.init(title: "Cancel", style: .default) { (action) in
            alertController.view.removeObserver(self, forKeyPath: "bounds")
        }
        alertController.addAction(cancelAction)

        let saveAction = UIAlertAction(title: "Submit", style: .default) { (action) in
            alertController.view.removeObserver(self, forKeyPath: "bounds")
            self.sendMyQuestion(self.textView.text)
            self.textView.text = ""
        }
        saveAction.isEnabled = false
        alertController.addAction(saveAction)

        alertController.view.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions.new, context: nil)
        NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: textView, queue: OperationQueue.main) { (notification) in
            saveAction.isEnabled = self.textView.text != ""
        }
        textView.backgroundColor = UIColor.white
        textView.textContainerInset = UIEdgeInsets.init(top: 8, left: 5, bottom: 8, right: 5)
        textView.keyboardToolbar.isHidden = true
        alertController.view.addSubview(self.textView)

        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func sendMyQuestion(_ question: String) {
        
        if question == "" {
            return
        }
        
        var param = getInitParams()
        param["question"]   = question
        param["user_id"]    = UserDefaults.standard.string(forKey: CONSTANT.KEY_USERID)!
        
        APIManager.shared.saveQuestionForVideo(param) { (result_code, msg, data) in
            if result_code == CONSTANT.CODE_SUCCESS {
                
                self.tblDataSource.removeAll()
                self.tblDataSource = data as! [QuestionModel]
                self.uiTableview.reloadData()
                self.uiTableview.scrollToLastRow(true)
            } else {
                self.showAlert(msg)
            }
        }
    }
    
    func getInitParams() -> [String: Any] {
        
        var params = [String : Any]()
        
        if let curChapter = currentVedeoChapter {
            params = [
                "row_id"       : 0,
                "uni_id"       : curChapter.uni_id,
                "subject_id"   : curChapter.subject_id,
                "chapter_num"  : curChapter.chapter_num,
                "video_type"   : curChapter.kind
            ] as [String : Any]
        }
        
        return params
    }
}


// MARK: - Table view data source
extension QuestionsOfChapterVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tblDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OneQuestionCell") as! OneQuestionCell
        cell.entity = tblDataSource[indexPath.row]
        
        return cell
    }
}

// MARK: - Table view data source
extension QuestionsOfChapterVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    }
}

