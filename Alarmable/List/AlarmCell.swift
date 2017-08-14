//
//  AlarmCell.swift
//  Alarmable
//
//  Created by Haven Barnes on 6/7/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import UIKit
import QuartzCore
import RealmSwift

class AlarmCell: UITableViewCell {
    
    var timeFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm"
        return dateFormatter
    }
    
    var amPmFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = " a"
        return dateFormatter
    }
    
    @IBOutlet weak var roundedBackgroundView: UIView!
    @IBOutlet weak var alarmLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amPmLabel: UILabel!
    @IBOutlet weak var enabledSwitch: UISwitch!
    @IBOutlet weak var repeatsImageView: UIImageView!
    @IBOutlet weak var sharedWith: UILabel!
    @IBOutlet weak var sharedWithLabel: UILabel!
    @IBOutlet weak var sharedWithLabelHeight: NSLayoutConstraint!
    
    var gradient: CAGradientLayer!
    
    var alarm: Alarm! {
        didSet {
            guard alarm != nil else { return }
            alarmLabel.text = alarm.label
            timeLabel.text = timeFormatter.string(from: alarm.fireDate as Date)
            amPmLabel.text = amPmFormatter.string(from: alarm.fireDate as Date)
            repeatsImageView.isHidden = !alarm.repeats || !alarm.isEnabled
            enabledSwitch.setOn(alarm.isEnabled, animated: false)
            roundedBackgroundView.layer.shadowOffset = CGSize.zero
            setupSharedWithLabel()
            setupGradient()
        }
    }
    
    /// Sets up the shared with label syntactically
    func setupSharedWithLabel() {
        switch alarm.friends.count {
        case 0:
            sharedWith.text = nil
            sharedWithLabel.text = nil
            sharedWithLabelHeight.constant = 0
            break
        case 1:
            sharedWith.text = "SHARED WITH"
            sharedWithLabel.text = alarm.friends.first!.name
            sharedWithLabelHeight.constant = 22
            break
        case 2:
            sharedWith.text = "SHARED WITH"
            sharedWithLabel.text = "\(alarm.friends[0].name) and \(alarm.friends[1].name)"
            sharedWithLabelHeight.constant = 22
            break
        case 3:
            sharedWith.text = "SHARED WITH"
            sharedWithLabel.text = "\(alarm.friends[0].name), \(alarm.friends[1].name), and \(alarm.friends[2].name)"
            sharedWithLabelHeight.constant = 22
            break
        case 4:
            sharedWith.text = "SHARED WITH"
            sharedWithLabel.text = "\(alarm.friends[0].name), \(alarm.friends[1].name), \(alarm.friends[2].name), and 1 other"
            sharedWithLabelHeight.constant = 22
            break
        default:
            sharedWith.text = "SHARED WITH"
            sharedWithLabel.text = "\(alarm.friends[0].name), \(alarm.friends[1].name), \(alarm.friends[2].name), and \(alarm.friends.count - 3) others"
            sharedWithLabelHeight.constant = 22
            break
        }
    }
    
    /// Applies background gradient specific to the time of alarm
    func setupGradient() {
        
        // Check to make sure we're not unnecessarily 
        // setting up gradient for deleted alarm
        // TODO: Find more elegant solution for this
        guard alarm != nil else { return }

        if gradient != nil {
            gradient.removeFromSuperlayer()
            gradient = nil
        }
        
        gradient = CAGradientLayer()
        gradient.frame = contentView.bounds
        roundedBackgroundView.layer.insertSublayer(gradient, at: 0)
        
        let hour = Calendar.current.component(.hour, from: alarm.fireDate as Date)
        let minute = Calendar.current.component(.minute, from: alarm.fireDate as Date)
        
        let totalMinutes = hour * 60 + minute
        
        let morning = UIColor("EC7051")
        let day = UIColor("14CCED")
        let night = UIColor("001655")
        
        let colorOne: UIColor!
        let colorTwo: UIColor!
        
        var percent: Double!
        if totalMinutes < 420 {
            percent = Double(totalMinutes) / 420 // sunrise
            colorOne = night
            colorTwo = morning
        } else {
            percent = Double(totalMinutes) / 1440 // day / night
            colorOne = day
            colorTwo = night
        }
        
        // Interpolate to create a gradient specific for this time of day
        let resultRed = colorOne.red + CGFloat(percent) * (colorTwo.red - colorOne.red);
        let resultGreen = colorOne.green + CGFloat(percent) * (colorTwo.green - colorOne.green);
        let resultBlue = colorOne.blue + CGFloat(percent) * (colorTwo.blue - colorOne.blue);
        
        let middleColor = UIColor(red: resultRed, green: resultGreen, blue: resultBlue, alpha: 1)
        
        gradient.colors = middleColor.gradientColors()
    }
    
    @IBAction func enabledSwitchChanged(_ sender: Any) {

        let realm = try! Realm()
        try! realm.write {
            alarm.isEnabled = enabledSwitch.isOn
        }
        
        if enabledSwitch.isOn {
            alarm.enable()
        } else {
            alarm.disable()
        }
    }
    
}
