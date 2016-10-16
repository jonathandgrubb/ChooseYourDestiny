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
    var remoteStories : [GitHubClient.StoryInfo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get a list of all stories that are available on GitHub
        GitHubClient.sharedInstance().getStoryInfoForAllStoriesAndAuthors { (success, error, info) in
            if success, let info = info {
                self.remoteStories = info
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
        }
        
        // exclude the list of what we've already downloaded
        // TODO
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
            // downloaded stories
            return 3
        } else {
            // undownloaded stories
            if let remoteStories = remoteStories {
                return remoteStories.count
            } else {
                return 0
            }
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Create the cell
        let cell = tableView.dequeueReusableCellWithIdentifier("LibraryCell", forIndexPath: indexPath)
        
        // http://stackoverflow.com/a/1754259
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        if (indexPath.section == 0) {
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
            default:
                cell.textLabel?.text = "Undefined"
            }
        } else {
            /*
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "High Seas II"
                cell.detailTextLabel?.text = "Not On Device (109 chapters)"
            case 1:
                cell.textLabel?.text = "The Octopus"
                cell.detailTextLabel?.text = "Not On Device (351 chapters)"
            default:
                cell.textLabel?.text = "Undefined"
            }
            */
            if let remoteStories = remoteStories { //where remoteStories[indexPath.row] != nil {
                let story = remoteStories[indexPath.row]
                cell.textLabel?.text = story.title
                cell.detailTextLabel?.text = "Not On Device (\(story.numChapters) chapters) Rated: \(story.rating)"
            }
        }
        
        return cell;
    }
    
    //func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //    return 150.0
    //}
    
    // swipe left options (start)
    // http://stackoverflow.com/a/32586617
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let manage = UITableViewRowAction(style: .Normal, title: "Manage") { action, index in
            print("manage button tapped")
        }
        manage.backgroundColor = UIColor.lightGrayColor()
        
        let remove = UITableViewRowAction(style: .Normal, title: "Remove") { action, index in
            print("remove button tapped")
        }
        remove.backgroundColor = UIColor.redColor()
        
        return [remove, manage]
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        // (allow editing of the rows representing books that have already been downloaded)
        if (indexPath.section == 0) {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
    }
    // swipe left options (end)
    
    // download or read
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("either download a story or read a story")
    }
}
