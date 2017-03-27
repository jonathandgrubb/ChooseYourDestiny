//
//  ControllerCommon.swift
//  VirtualTourist
//
//  Created by Jonathan Grubb on 6/14/16.
//  Copyright © 2016 Jonathan Grubb. All rights reserved.
//

import UIKit

open class ControllerCommon {
    
    open static func displayErrorDialog(_ controller: UIViewController, message: String) {
        DispatchQueue.main.async {
            let emptyAlert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
            emptyAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            controller.present(emptyAlert, animated: true, completion: nil)
        }
    }
}
