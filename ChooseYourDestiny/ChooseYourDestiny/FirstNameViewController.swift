//
//  FirstNameViewController.swift
//  ChooseYourDestiny
//
//  Created by Jonathan Grubb on 12/13/16.
//  Copyright © 2016 Jonathan Grubb. All rights reserved.
//

import UIKit

class FirstNameViewController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstName: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func donePressed(_ sender: AnyObject) {
        _ = saveTheName()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return saveTheName()
    }
    
    func saveTheName() -> Bool {
        if let fname = firstName.text, fname != "" {
            UserDefaults.standard.setValue(fname, forKey: "firstName")
            UserDefaults.standard.synchronize()
            dismiss(animated: true, completion: nil)
            return true
        } else {
            ControllerCommon.displayErrorDialog(self, message: "Please? Some stories might mention you by name!")
            return false
        }
    }
    
}
