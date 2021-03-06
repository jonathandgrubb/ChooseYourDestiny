//
//  StoriesViewController.swift
//  ChooseYourDestiny
//
//  Created by Jonathan Grubb on 8/13/16.
//  Copyright © 2016 Jonathan Grubb. All rights reserved.
//

import UIKit
import CoreData

class StoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var allRemoteStories : [GitHubClient.StoryInfo] = []
    var displayedRemoteStories : [GitHubClient.StoryInfo]?
    var tapGesture : UITapGestureRecognizer?
    var activityIndicator : UIActivityIndicatorView?
    var barButton : UIBarButtonItem?
    var concurrentNetworkCalls = 0

    
    // MARK:  - Properties
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet{
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>) {
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
        
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Story")
        fr.sortDescriptors = []
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
                                                              managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        // see if we have any stories saved in CORE Data
        print("Number of fetchedObjects: \(fetchedResultsController!.fetchedObjects!.count)")
        
        // get a list of all stories that are available on GitHub
        getStoryInfoForAllStoriesAndAuthors()
        
        // http://stackoverflow.com/a/11937989/4611868
        // get rid of the empty rows at the bottom of the choices
        tableView?.tableFooterView = UIView()
        
        // http://stackoverflow.com/a/32281860/4611868
        // if the view is tapped we can dismiss the keyboard
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        
        // http://stackoverflow.com/questions/21839502/adding-an-activity-indicator-to-the-nav-bar
        // for displaying network activity
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        barButton = UIBarButtonItem(customView: activityIndicator!)
        navigationItem.rightBarButtonItem = nil
        navigationItem.rightBarButtonItem = barButton
        
        // track the number of network calls being executed concurrently
        concurrentNetworkCalls = 0
        networkCallDone()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Downloaded"
        } else {
            return "Available (GitHub)"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            // downloaded stories
            if let fc = fetchedResultsController, let fo = fc.fetchedObjects {
                print("downloaded stories count: \(fo.count)")
                return fo.count
            }
        } else {
            // undownloaded stories
            if let remoteStories = displayedRemoteStories {
                print("undownloaded stories count: \(remoteStories.count)")
                return remoteStories.count
            }
        }
        print("? stories count: 0 (section: \(section))")
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "LibraryCell", for: indexPath)
        
        // http://stackoverflow.com/a/1754259
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        if (indexPath.section == 0) {

            // Get the story
            let story = fetchedResultsController?.object(at: indexPath) as! Story
            
            // Sync Story -> cell
            cell.textLabel?.text = story.name
            cell.detailTextLabel?.text = "By \(story.author!) (\(story.chapter!.count) chapters) Rated: \(story.rating!)"
        
        } else {
 
            if let remoteStories = displayedRemoteStories {
                let story = remoteStories[indexPath.row]
                cell.textLabel?.text = story.title
                cell.detailTextLabel?.text = "By \(story.author) (\(story.numChapters) chapters) Rated: \(story.rating)"
            }
        }
        
        return cell;
    }
    
    // swipe left options (start)
    // http://stackoverflow.com/a/32586617
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let remove = UITableViewRowAction(style: .normal, title: "Remove") { action, index in
            print("remove button tapped")

            self.fetchedResultsController!.managedObjectContext.delete(self.fetchedResultsController!.object(at: indexPath) as! Story)
            //self.save()
            self.executeSearch()
            DispatchQueue.main.async {
                self.updateAvailableList()
            }
        }
        remove.backgroundColor = UIColor.red
        
        return [remove]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        // (allow editing of the rows representing books that have already been downloaded)
        if (indexPath.section == 0) {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
    }
    // swipe left options (end)
    
    // download or read
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            
            print("read a story")
            
            // create fetch request for the selected story
            if let story = fetchedResultsController!.object(at: indexPath) as? Story {

                let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Chapter")
                fr.sortDescriptors = []
                let pred = NSPredicate(format: "(is_first_chapter = %@) AND (story = %@)", "true", story)
                fr.predicate = pred
                
                // insert the fetch request into the reading tab's controller
                // Create FetchedResultsController
                let fc = NSFetchedResultsController(fetchRequest: fr,
                                                    managedObjectContext:fetchedResultsController!.managedObjectContext,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
                
                // Inject it into the reading VC
                if let navController = self.tabBarController?.childViewControllers[1] as? UINavigationController,
                   let readingVC = navController.viewControllers[0] as? ReadingViewController {
                    readingVC.fetchedResultsController = fc
                    GitHubClient.sharedInstance().startAtBeginning = true
                    self.tabBarController?.selectedIndex = 1
                } else {
                    print("could not find the story view controller")
                }
                
            } else {
                print("could not find the story")
            }
            
        } else {
            
            print("download a story")
            if let remoteStories = displayedRemoteStories {
                loadRemoteStory(remoteStories[indexPath.row])
            } else {
                ControllerCommon.displayErrorDialog(self, message: "Error downloading story")
            }
        }
        
    }
    
    func loadRemoteStory(_ info : GitHubClient.StoryInfo) {
        
        networkCallStart()
        GitHubClient.sharedInstance().getStoryContent(info.author, repo: info.repo) { (success, error, content) in
            
            DispatchQueue.main.async {
                self.networkCallDone()
            }
            
            if success == false {
                ControllerCommon.displayErrorDialog(self, message: "Error downloading story")
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
                
                // saving now in case the app is closed before the autosave
                self.executeSearch()
                
                // remove this downloaded story from the "available on GitHub" list
                self.removeStoryFromAvailableList(info.author, repo: info.repo)
                
                // reload the table
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                return
                
            } else {
                print("required Story content missing from story json : \(content)")
                ControllerCommon.displayErrorDialog(self, message: "Required Story content missing from story json")
                return
            }
        }
    }
    
    
    // get story info for all stories and authors
    func getStoryInfoForAllStoriesAndAuthors() {
        
        // ********** all authors ********** (failure covered)
        concurrentNetworkCallStart()
        GitHubClient.sharedInstance().listAllAuthors { (success, error, authors) in
            
            self.concurrentNetworkCallDone()
            if let error = error {
                print("error getting all authors: \(error)")
                if error == GitHubClient.Errors.networkError {
                    ControllerCommon.displayErrorDialog(self, message: "Network Error While Getting Author List")
                }
                return
            }
            
            if let authors = authors {
                
                for author in authors {
                    
                    // ********** all stories for the author **********
                    self.concurrentNetworkCallStart()
                    GitHubClient.sharedInstance().listStoriesForAuthor(author) { (success, error, storyNames) in
                        
                        self.concurrentNetworkCallDone()
                        if let error = error {
                            // just note the problem...
                            print("listStoriesForAuthor: \(error)")
                            
                            // seems like bad UX, but...
                            if error == GitHubClient.Errors.networkError {
                                ControllerCommon.displayErrorDialog(self, message: "Network Error")
                            }

                        } else if let storyNames = storyNames {
                            
                            for storyName in storyNames {
                            
                                // ********** get story info for each story **********
                                self.concurrentNetworkCallStart()
                                GitHubClient.sharedInstance().getStoryInfo(author, repo: storyName) { (success, error, info) in
                                    
                                    self.concurrentNetworkCallDone()
                                    if let error = error {
                                        // just note the problem...
                                        print("getStoryInfo: \(error) for author:\(author)/storyName:\(storyName)")
                                        
                                        // seems like bad UX, but...
                                        if error == GitHubClient.Errors.networkError {
                                            ControllerCommon.displayErrorDialog(self, message: "Network Error")
                                        }
                                        
                                    } else if let info = info {
                                        // add the new title to the list
                                        DispatchQueue.main.async {
                                            self.allRemoteStories.append(info)
                                            self.updateAvailableList()
                                        }
                                    } else {
                                        print("problem with getStoryInfo... returned no error but returned no info for author: \(author) storyName: \(storyName)")
                                    }
                                    
                                }
                            }
                            
                        } else {
                            // just note the problem...
                            print("problem with listStoriesForAuthor... returned no error but returned no stories for author: \(author)")
                        }
                    } // listStoriesforAuthor
                } // for authors
                
                
            } else {
                print("problem with listAllAuthors()... returned no error but returned no authors")
            }
        }
        
        
    }

    func updateAvailableList() {
        displayedRemoteStories = allRemoteStories
        
        // exclude from the "available" list what we've already downloaded
        if let fc = self.fetchedResultsController, let fo = fc.fetchedObjects as? [Story] {
            for story in fo {
                self.removeStoryFromAvailableList(story.author!, repo: story.repo!)
            }
        }
        
        // exclude from the "availble" list what's not matching the filter
        if let filter = searchBar.text?.lowercased(), self.displayedRemoteStories != nil && filter != "" {
            for remoteStory in self.displayedRemoteStories! {
                if remoteStory.author.lowercased().range(of: filter) == nil &&
                   remoteStory.title.lowercased().range(of: filter) == nil {
                    self.removeStoryFromAvailableList(remoteStory.author, repo: remoteStory.repo)
                }
            }
        }
        
        self.tableView.reloadData()
    }
    
    func removeStoryFromAvailableList(_ author: String, repo: String) {
        // http://stackoverflow.com/a/31883396/4611868
        if self.displayedRemoteStories != nil,
           let ind = self.displayedRemoteStories!.index(where: {$0.author == author && $0.repo == repo}) {
            self.displayedRemoteStories!.remove(at: ind)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // http://stackoverflow.com/a/32281860/4611868
        // if the view is tapped we can dismiss the keyboard
        if let tapGesture = tapGesture {
            view.addGestureRecognizer(tapGesture)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // remove the tap gesture when not editing so we can handle other events again
        if let tapGesture = tapGesture {
            view.removeGestureRecognizer(tapGesture)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("searchBar text changed: \(searchBar.text)")
        
        // filter the downloaded list
        if let filter = searchBar.text {
            let pred = NSPredicate(format: "(author LIKE[cd] %@) OR (name LIKE[cd] %@)", "*\(filter)*", "*\(filter)*")
            fetchedResultsController!.fetchRequest.predicate = pred
        } else {
            let pred = NSPredicate()
            fetchedResultsController!.fetchRequest.predicate = pred
        }
        executeSearch()
        
        // filter the available list
        self.updateAvailableList()
    }
    
    // when a user presses Search, the keyboard should be dismissed
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    // http://stackoverflow.com/a/32281860/4611868
    // if the view is tapped we can dismiss the keyboard
    func tap(_ gesture: UITapGestureRecognizer) {
        if self.searchBar.isFirstResponder {
            self.searchBar.resignFirstResponder()
        }
    }

    // started doing network stuff
    func networkCallStart() {
        if self.activityIndicator != nil {
            self.activityIndicator!.isHidden = false
            self.activityIndicator!.startAnimating()
        }
    }

    // stopped doing network stuff
    func networkCallDone() {
        if self.activityIndicator != nil {
            self.activityIndicator!.isHidden = true
            self.activityIndicator!.stopAnimating()
        }
    }
    
    // track a group of network calls - start
    func concurrentNetworkCallStart() {
        DispatchQueue.main.async {
            self.concurrentNetworkCalls += 1
            self.networkCallStart()
        }
    }

    // track a group of network calls - done
    func concurrentNetworkCallDone() {
        DispatchQueue.main.async {
            self.concurrentNetworkCalls -= 1
            if self.concurrentNetworkCalls < 1 {
                self.networkCallDone()
            }
        }
    }
}
