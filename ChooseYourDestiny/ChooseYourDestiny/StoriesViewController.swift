//
//  StoriesViewController.swift
//  ChooseYourDestiny
//
//  Created by Jonathan Grubb on 8/13/16.
//  Copyright © 2016 Jonathan Grubb. All rights reserved.
//

import UIKit

class StoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Downloaded"
        } else {
            return "Available (GitHub)"
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 3
        } else {
            return 2
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Create the cell
        let cell = tableView.dequeueReusableCellWithIdentifier("LibraryCell", forIndexPath: indexPath)
        
        // http://stackoverflow.com/a/1754259
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "High Seas"
            cell.detailTextLabel?.text = "Started (200 chapters)"
        case 1:
            cell.textLabel?.text = "Adventure!"
            cell.detailTextLabel?.text = "Not Started (231 chapters)"
        case 2:
            cell.textLabel?.text = "Meh - the Novel"
            cell.detailTextLabel?.text = "Started (109 chapters)"
        case 3:
            cell.textLabel?.text = "High Seas II"
            cell.detailTextLabel?.text = "Not On Device (109 chapters)"
        case 4:
            cell.textLabel?.text = "The Octopus"
            cell.detailTextLabel?.text = "Not On Device (351 chapters)"
        default:
            cell.textLabel?.text = "Undefined"
        }
        
        return cell;
    }
    
    //func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //    return 150.0
    //}
}
