//
//  UITableView+Extension.swift
//  IFHAM
//
//  Created by AngelDev on 6/28/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import UIKit

extension UITableView {

    
    func scroll(to: Position, animated: Bool) {
        let sections = numberOfSections
        let rows = numberOfRows(inSection: numberOfSections - 1)
        switch to {
            case .top:
                if rows > 0 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.scrollToRow(at: indexPath, at: .top, animated: animated)
                }
                break
            
            case .bottom:
                if rows > 0 {
                    let indexPath = IndexPath(row: rows - 1, section: sections - 1)
                    self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
                break
        }
    }
    
    enum Position {
        case top
        case bottom
    }

    func scrollToLastRow(_ animated: Bool) {
        if self.numberOfRows(inSection: 0) > 0 {
            self.scrollToRow(at: IndexPath(row: self.numberOfRows(inSection: 0) - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1, section: self.numberOfSections - 1)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func scrollToTop() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
}
