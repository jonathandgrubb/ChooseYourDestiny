//
//  HomeViewController.swift
//  ChooseYourDestiny
//
//  Created by Jonathan Grubb on 8/13/16.
//  Copyright © 2016 Jonathan Grubb. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Create the cell
        let cell = tableView.dequeueReusableCellWithIdentifier("HomeCell", forIndexPath: indexPath)
        
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150.0
    }
}
