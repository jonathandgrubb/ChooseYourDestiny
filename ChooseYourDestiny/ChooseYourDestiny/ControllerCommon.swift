//
//  ControllerCommon.swift
//  VirtualTourist
//
//  Created by Jonathan Grubb on 6/14/16.
//  Copyright © 2016 Jonathan Grubb. All rights reserved.
//

import UIKit

public class ControllerCommon {
    
    public static func displayErrorDialog(controller: UIViewController, message: String) {
        dispatch_async(dispatch_get_main_queue()) {
            let emptyAlert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            emptyAlert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
            controller.presentViewController(emptyAlert, animated: true, completion: nil)
        }
    }
}
