//
//  TabBarController.swift
//  ChooseYourDestiny
//
//  Created by Jonathan Grubb on 12/13/16.
//  Copyright © 2016 Jonathan Grubb. All rights reserved.
//

import UIKit

class TabBarController : UITabBarController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view, typically from a nib.
        
        // trying this first name thing here
        if UserDefaults.standard.string(forKey: "firstName") == nil {
            DispatchQueue.main.async {
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "FirstNameViewController")
                self.present(controller, animated: true, completion: nil)
            }
        }
    }

}
