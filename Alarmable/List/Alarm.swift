//
//  Alarm.swift
//  Alarmable
//
//  Created by Haven Barnes on 6/3/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import Foundation
import RealmSwift
import UserNotifications
import Alamofire

class Alarm: Object {
    dynamic var id = UUID().uuidString
    dynamic var label: String? = nil
    dynamic var fireDate = NSDate()
    dynamic var isEnabled = false
    dynamic var repeats = false
    
    let friends = List<Friend>()
    
    func numbersList() -> [String] {
        var list = [String]()
        
        for friend in friends {
            list.append(friend.phoneNumber)
        }

        return list
    }
    
    func enable(test: Bool = false) {
        
        let realm = try! Realm()
        try! realm.write {
            // Randomizing ID on re-enable means no more
            // 3 texts at a time (SEE npm's node-schedule)
            self.id = UUID().uuidString
            self.isEnabled = true
            self.fireDate = self.fireDate.modernized() as NSDate
        }
        
        AlarmManager.shared.schedule(self, test: test)
        
        // If this alarm has no friends involved, the API 
        // doesn't need to know about it
        guard self.friends.count > 0 else { return }
        
        let alarm: Parameters = [
            "alarm": [
                "id": id,
                "name": App.shared.userName ?? "Your friend",
                "date": fireDate.string,
                "repeats": repeats,
                "friends_numbers": numbersList()
            ]
        ]
        
        print(alarm)
        
        let request = Request(endpoint: .alarm, method: .post, body: alarm)
        request.send(completion: {
            success, error in
            
            guard success else {
                try! realm.write {
                    self.isEnabled = false
                }
                return
            }
        })
    }
    
    func disable() {
        AlarmManager.shared.cancel(self)
        
        guard self.friends.count > 0 else { return }
        
        let request = Request(endpoint: .alarm, method: .delete, urlParameter: id)
        request.send(completion: {
            success, error in
            
            guard success else {
                let realm = try! Realm()
                try? realm.write {
                    self.isEnabled = true
                }
                return
            }
        })
    }
    
    static func get(id: String) -> Alarm? {
        let realm = try! Realm()
        return realm.objects(Alarm.self).filter("id == %@", String(describing: id)).first
    }
}
