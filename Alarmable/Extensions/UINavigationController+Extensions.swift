//
//  UINavigationController+Extensions.swift
//  Alarmable
//
//  Created by Haven Barnes on 6/5/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    func setSolidWhite() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor.white
    }
    
    func show() {
        setNavigationBarHidden(false, animated: true)
    }
    
    func hide() {
        setNavigationBarHidden(true, animated: true)
    }
}
