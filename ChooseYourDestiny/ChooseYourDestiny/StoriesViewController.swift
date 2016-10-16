//
//  StoriesViewController.swift
//  ChooseYourDestiny
//
//  Created by Jonathan Grubb on 8/13/16.
//  Copyright © 2016 Jonathan Grubb. All rights reserved.
//

import UIKit
import CoreData

class StoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var remoteStories : [GitHubClient.StoryInfo]?
    
    // MARK:  - Properties
    var fetchedResultsController : NSFetchedResultsController? {
        didSet{
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    init(fetchedResultsController fc : NSFetchedResultsController) {
        fetchedResultsController = fc
        super.init(nibName: nil, bundle: nil)
    }
    
    // Do not worry about this initializer. I has to be implemented
    // because of the way Swift interfaces with an Objective C
    // protocol called NSArchiving. It's not relevant.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func executeSearch(){
        if let fc = fetchedResultsController{
            do{
                try fc.performFetch()
            }catch let e as NSError{
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
    
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
        
        // Get the stack
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        
        // Create a fetchrequest
        let fr = NSFetchRequest(entityName: "Story")
        fr.sortDescriptors = []
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
                                                              managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        // see if we have any pins saved in CORE Data and load them onto the map as annotations
        print("Number of fetchedObjects: \(fetchedResultsController!.fetchedObjects!.count)")
        
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
        if (indexPath.section == 0) {
            print("read a story")
        } else {
            print("download a story")
            if let remoteStories = remoteStories {
                loadRemoteStory(remoteStories[indexPath.row])
            } else {
                ControllerCommon.displayErrorDialog(self, message: "Error downloading story")
            }
        }
    }
    
    func loadRemoteStory(info : GitHubClient.StoryInfo) {
        GitHubClient.sharedInstance().getStoryContent(info.author, repo: info.title) { (success, error, content) in
            if success == false {
                dispatch_async(dispatch_get_main_queue()) {
                    ControllerCommon.displayErrorDialog(self, message: "Error downloading story")
                }
                return
            }
            
            // Story
            if let content = content,
               let story = content["story"] as? [String:AnyObject],
               let id = story["id"] as? String,
               let name = story["name"] as? String,
               let rating = story["rating"] as? String,
               let summary = story["summary"] as? String,
               let chapters = story["chapters"] as? [[String:AnyObject]] {
                
                let pic_path = story["pic_path"] as? String
                let vid_path = story["vid_path"] as? String
                
                let s = Story(author: info.author, repo: info.repo, id: id, name: name, rating: rating, summary: summary, pic_path: pic_path, vid_path: vid_path, context: self.fetchedResultsController!.managedObjectContext)
                
                // Chapters
                for chapter in chapters {
                    
                    if let id = chapter["id"] as? String,
                       let name = chapter["name"] as? String,
                       let text = chapter["text"] as? String {
                    
                        let firstCh = chapter["is_first_chapter"] as? Bool
                        let pic_path = chapter["pic_path"] as? String
                        let vid_path = chapter["vid_path"] as? String
                        
                        let chp = Chapter(id: id, name: name, text: text, isFirstChapter: firstCh, pic_path: pic_path, vid_path: vid_path, context: self.fetchedResultsController!.managedObjectContext)
                        chp.story = s
                        
                        // Choices
                        if let choices = chapter["choices"] as? [[String:AnyObject]] {
                            
                            for choice in choices {
                                
                                if let id = choice["chapter_id"] as? String,
                                   let text = choice["text"] as? String {
                                
                                    let ch = Choice(text: text, chapterId: id, context: self.fetchedResultsController!.managedObjectContext)
                                    ch.chapter = chp
                                
                                } else {
                                    print("required Choice content missing from story json : \(content)")
                                    ControllerCommon.displayErrorDialog(self, message: "Required Story content missing from story json")
                                    return
                                }
                            }
                        }
                    } else {
                        print("required Chapter content missing from story json : \(content)")
                        ControllerCommon.displayErrorDialog(self, message: "Required Chapter content missing from story json")
                        return
                    }
                }
                
                return
                
            } else {
                print("required Story content missing from story json : \(content)")
                ControllerCommon.displayErrorDialog(self, message: "Required Story content missing from story json")
                return
            }
        }
    }
    
}
