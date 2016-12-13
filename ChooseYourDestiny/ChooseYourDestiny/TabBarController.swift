//
//  TabBarController.swift
//  ChooseYourDestiny
//
//  Created by Jonathan Grubb on 12/13/16.
//  Copyright © 2016 Jonathan Grubb. All rights reserved.
//

import UIKit

class TabBarController : UITabBarController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view, typically from a nib.
        
        // trying this first name thing here
        if NSUserDefaults.standardUserDefaults().stringForKey("firstName") == nil {
            dispatch_async(dispatch_get_main_queue()) {
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("FirstNameViewController")
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
    }

}