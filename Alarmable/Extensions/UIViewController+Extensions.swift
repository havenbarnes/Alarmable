//
//  UIViewController+Extensions.swift
//  Alarmable
//
//  Created by Haven Barnes on 6/5/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import UIKit

extension UIViewController {
    func instantiate(_ identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
}

