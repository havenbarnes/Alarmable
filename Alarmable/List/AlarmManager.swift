//
//  AlarmModel.swift
//  Alarmable
//
//  Created by Haven Barnes on 7/11/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import Foundation
import UserNotifications

class AlarmManager {
    
    static let shared = AlarmManager()
    
    var category: UNNotificationCategory {
        let deleteAction = UNNotificationAction(identifier: "AlarmOff",
                                                title: "Stop", options: [.destructive])
        
        return UNNotificationCategory(identifier: "AlarmCategory",
                                              actions: [deleteAction],
                                              intentIdentifiers: [], options: [])
    }
    
    
    /// Schedules a Local Notification for Alarm
    func schedule(_ alarm: Alarm) {
        
        // After some time, if alarm not deactivated, send SMS
        var components: Set<Calendar.Component> = [.hour, .minute]
        
        if !alarm.repeats {
            components = components.union([.year, .month, .day])
        }
       
        // Schedule alarm for tomorrow if time has already passed
        var fireDate = alarm.fireDate as Date
        if fireDate < Date() {
            fireDate = fireDate.addingTimeInterval(TimeInterval.day)
        }
        
        let fireDateComponents = Calendar.current.dateComponents(components, from: fireDate as Date)
                
        let trigger = UNCalendarNotificationTrigger(dateMatching: fireDateComponents, repeats: alarm.repeats)

        let identifier = alarm.id
        
        let content = UNMutableNotificationContent()
        content.title = alarm.label ?? "Alarm"
        content.sound = UNNotificationSound(named: "Alarm.mp3")
        content.categoryIdentifier = "AlarmCategory"
        content.userInfo["id"] = alarm.id
        
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
        })
    }
    
    func cancel(_ alarm: Alarm) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarm.id])
    }
}
