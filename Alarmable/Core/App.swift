//
//  App.swift
//  Alarmable
//
//  Created by Haven Barnes on 6/20/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import Foundation
import UserNotifications

class App {
    
    static let shared = App()
        
    var userName: String? {
        get {
            return UserDefaults.standard.string(forKey: "name_preference")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "name_preference")
            UserDefaults.standard.synchronize()
        }
    }
    
    func notification(title: String,
                      message: String,
                      withSound sound: UNNotificationSound = UNNotificationSound.default(),
                      after timeInterval: TimeInterval = 3) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = sound
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval,
                                                        repeats: false)
        let identifier = "AlarmableLocalNotification"
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        })
    }
}
