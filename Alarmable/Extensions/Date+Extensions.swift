//
//  Date+Extensions.swift
//  Alarmable
//
//  Created by Haven Barnes on 8/4/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import Foundation

extension NSDate {
    public var hour: Int {
        let date = self as Date
        var calendar = NSCalendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        let fireDateComponents = calendar.dateComponents([.hour], from: date)
        return fireDateComponents.hour!
    }
    
    public var string: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZ"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        return dateFormatter.string(from: self as Date)
    }
    
    /// Keeps the date's time, just changes it to the next
    /// occurrence of that time
    func modernized() -> Date {
        let date = self as Date
        let currentDate = Date()
        let calendar = Calendar.current
        var fireDateComponents = calendar.dateComponents([.day, .hour, .minute, .second], from: date)
        let currentDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: currentDate)

        fireDateComponents.setValue(currentDateComponents.year, for: .year)
        fireDateComponents.setValue(currentDateComponents.month, for: .month)
        fireDateComponents.setValue(currentDateComponents.day, for: .day)
        fireDateComponents.setValue(fireDateComponents.hour, for: .hour)
        fireDateComponents.setValue(fireDateComponents.minute, for: .minute)
        
        // If this time already past, set it for tomorrow
        if fireDateComponents.hour! <= currentDateComponents.hour!
            && fireDateComponents.minute! <= currentDateComponents.minute!
            && fireDateComponents.second! < currentDateComponents.second! {
            fireDateComponents.setValue(currentDateComponents.day! + 1, for: .day)
        }

        return calendar.date(from: fireDateComponents)!
    }

}

