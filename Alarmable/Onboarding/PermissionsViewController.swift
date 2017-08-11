//
//  PermissionsViewController.swift
//  Alarmable
//
//  Created by Haven Barnes on 7/13/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import UIKit
import UserNotifications

class PermissionsViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var allowLabel: UILabel!
    @IBOutlet weak var explanationLabel: UILabel!
    
    @IBOutlet weak var allowButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPresentation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: {
            timer in
            
            self.startPresentation()
        })
        
    }
    
    func setupPresentation() {
        
        if let name = App.shared.userName {
            nameLabel.text = "\(name),"
        }
        nameLabel.alpha = 0
        allowLabel.alpha = 0
        explanationLabel.alpha = 0
        allowButton.alpha = 0
    }
    
    func startPresentation() {
        nameLabel.fadeIn(completion: {
            self.allowLabel.fadeIn(completion: {
                self.explanationLabel.fadeIn(delay: 1.0, completion: {
                    self.allowButton.fadeIn(delay: 1.0, completion: nil)
                })
            })
        })
    }

    @IBAction func allowButtonPressed(_ sender: Any) {
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.alert, .sound]) { (granted, error) in
            
            guard granted else {
                self.showSettingsLink()
                return
            }
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func showSettingsLink() {
        let alert = UIAlertController(title: "Push Notifications", message: "Push Notifications are required for alarms to work. Please turn them on for the best experience with Alarmable", preferredStyle: .alert)
        
        let linkAction = UIAlertAction(title: "Go To Settings", style: .default, handler: {
            action in
            
            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        })
        
        alert.addAction(linkAction)
        
        present(alert, animated: true, completion: nil)
    }
}
