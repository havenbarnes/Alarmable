//
//  UIView+Extensions.swift
//  Alarmable
//
//  Created by Haven Barnes on 7/13/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import UIKit

extension UIView {
    func fadeIn(delay: Double = 0.5, completion: (() -> ())?) {
        self.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: delay, options: .curveEaseInOut, animations: {
            self.alpha = 1
        }, completion: {
            complete in
            
            if complete {
                completion?()
            }
        })
    }
}
