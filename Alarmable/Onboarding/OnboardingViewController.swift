//
//  OnboardingViewController.swift
//  Alarmable
//
//  Created by Haven Barnes on 7/11/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import UIKit
import UserNotifications

class OnboardingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var hiLabel: UILabel!
    @IBOutlet weak var whatsYourNameLabel: UILabel!
    
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var textfieldBorderView: UIView!
    
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
        hiLabel.alpha = 0
        whatsYourNameLabel.alpha = 0
        textfield.alpha = 0
        textfieldBorderView.alpha = 0
        
        textfield.delegate = self
    }
    
    func startPresentation() {
        hiLabel.fadeIn(completion: {
            self.whatsYourNameLabel.fadeIn(completion: {
                self.textfieldBorderView.fadeIn(completion: {
                    self.textfield.becomeFirstResponder()
                    self.textfield.fadeIn(delay: 0.1, completion: nil)
                })
            })
        })
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let name = textField.text?.replacingOccurrences(of: " ", with: "")
        App.shared.userName = name
        
        let vc = instantiate("sbPermissionsViewController")
        show(vc, sender: self)
        return false
    }
    
}
