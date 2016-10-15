//
//  ReadingViewController.swift
//  ChooseYourDestiny
//
//  Created by Jonathan Grubb on 10/15/16.
//  Copyright © 2016 Jonathan Grubb. All rights reserved.
//

import UIKit

class ReadingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Create the cell
        let cell = tableView.dequeueReusableCellWithIdentifier("ChoiceCell", forIndexPath: indexPath)
        
        // http://stackoverflow.com/a/1754259
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Welcome"
            cell.detailTextLabel?.text = "Welcome back to the Choose Your Destiny app, an open source project fueled by stories that can be experienced and changed by you! See http://www.blahblah.com for details"
        case 1:
            cell.textLabel?.text = "Continue Reading..."
            cell.detailTextLabel?.text = "High Seas"
        case 2:
            cell.textLabel?.text = "Find a new story"
        default:
            cell.textLabel?.text = "Find a new story"
        }
        
        return cell;
    }
}
