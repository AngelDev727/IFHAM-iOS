//
//  Extension+Date.swift
//  IFHAM
//
//  Created by AngelDev on 6/26/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import Foundation

//update by RMS,

func toMillis(_ dateVal: Date) -> Int64! {
    return Int64(dateVal.timeIntervalSince1970 * 1000)
}

func toSecond(_ dateVal: Date) -> Int64! {
    return Int64(dateVal.timeIntervalSince1970)
}

let CurrentTimestamp = toSecond(Date())

func getLocalTimeString(fromTime:String, formatStyle : String) -> String {
    
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd"
//    df.timeZone = TimeZone(abbreviation: "UTC")
    
    let fromDate = df.date(from: fromTime)
    
    df.timeZone = NSTimeZone.local
    df.dateFormat = formatStyle
    
    let localTime = df.string(from: fromDate!)
    
    return localTime;
}

func getStringFormDate (date: Date, toFormat: String = "yyyy/MM/dd") -> String {
    
    let df = DateFormatter()
    df.dateFormat = toFormat
    return df.string(from: date)
}

func getDateFormString (strDate: String, fromFormat: String = "yyyy/MM/dd") -> Date {
    
    let df = DateFormatter()
    df.dateFormat = fromFormat
    return df.date(from: strDate)!
}

func getDateStringFromTimeStamp (_ timesTamp : String, toFormat: String = "yyyy/MM/dd") -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timesTamp)!)
    
    let dateFormatter = DateFormatter()
    //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
    dateFormatter.locale = NSLocale.current
    dateFormatter.dateFormat = toFormat //Specify your format that you want MM-dd HH:mm format okay
    
    let strDate = dateFormatter.string(from: date)
    
    return strDate
}

func getTimeString(_ tstamp: String) -> String {
        
        let date = Date(timeIntervalSince1970: TimeInterval(tstamp)!)
        
        let dateFormatter = DateFormatter()
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm" //Specify your format that you want MM-dd HH:mm format okay
        
        let strDate = dateFormatter.string(from: date)
        
        return strDate
}

extension Date {
    
    func getNextMonth(_ numMonths: Int) -> Date? {
        return Calendar.current.date(byAdding: .month, value: numMonths, to: self)
    }
}
