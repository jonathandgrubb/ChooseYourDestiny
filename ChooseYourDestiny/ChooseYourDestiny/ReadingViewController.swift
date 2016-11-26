//
//  ReadingViewController.swift
//  ChooseYourDestiny
//
//  Created by Jonathan Grubb on 10/15/16.
//  Copyright © 2016 Jonathan Grubb. All rights reserved.
//

import UIKit
import CoreData

class ReadingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var currentChapter: Chapter?
    var currentChoices = [Choice]()
    
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
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 140
        
        // http://stackoverflow.com/a/11937989/4611868
        // get rid of the empty rows at the bottom of the choices
        tableView?.tableFooterView = UIView()
        
        // Create the FetchedResultsController (might need this to get the choices)
        //fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
        //                                                      managedObjectContext: stack.context, 
        //                                                      sectionNameKeyPath: nil, cacheName: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // if this was navigated to as a new story
        if let startOver = GitHubClient.sharedInstance().startAtBeginning where startOver == true {
            
            // pop the navigation stack
            self.navigationController?.popToRootViewControllerAnimated(true)
            
            // scroll to the top
            self.scrollView.setContentOffset(CGPoint(x: 0, y:0), animated: true)
            
            GitHubClient.sharedInstance().startAtBeginning = false
        }
        
        // load the data for the current chapter
        if let fc = fetchedResultsController,
           let chapters = fc.fetchedObjects as? [Chapter]
           where chapters.count > 0 {
            
            // set the current chapter
            currentChapter = chapters[0]
            
            // text
            textView.text = currentChapter!.text

            // picture
            //if let pic_data = chapter.picture {
            //    image.setValue(pic_data, forKey: "data")
            //} else if let pic_path = chapter.picture_path,
            //          let imageURL = NSURL(string: pic_path),
            //          let imageData = NSData(contentsOfURL: imageURL) {
            //    image.setValue(imageData, forKey: "data")
            //}

            // load the choices for this chapter
            let fr = NSFetchRequest(entityName: "Choice")
            fr.sortDescriptors = []
            let pred = NSPredicate(format: "(chapter = %@)", currentChapter!)
            fr.predicate = pred
            // Create FetchedResultsController (is this better than creating a new one?)
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
                                                managedObjectContext:fetchedResultsController!.managedObjectContext,
                                                sectionNameKeyPath: nil,
                                                cacheName: nil)
            executeSearch()
            
            if let choices = fetchedResultsController!.fetchedObjects as? [Choice] {
                for choice in choices {
                    currentChoices.append(choice)
                }
            }

        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let chapter = currentChapter, let choices = chapter.choice {
            return choices.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Create the cell
        let cell = tableView.dequeueReusableCellWithIdentifier("ChoiceCell", forIndexPath: indexPath) as! ChoiceCell
        
        // http://stackoverflow.com/a/1754259
        cell.label?.numberOfLines = 0
        cell.label?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        // get the text for the choice
        let choice = currentChoices[indexPath.row]
        if let text = choice.text {
            cell.label?.text = text
        }
        
        // http://stackoverflow.com/a/19570000/4611868
        // remove the extra height from the tableview
        tableView.sizeToFit()
        
        return cell;
    }
    
    //func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //    nextChapterId = currentChoices[indexPath.row].chapter_id
    //}
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let readingVC = segue.destinationViewController as? ReadingViewController,
           let chapter = currentChapter, let story = chapter.story,
           let selectedRowIndexPath = tableView.indexPathForSelectedRow,
           let nextChapterId = currentChoices[selectedRowIndexPath.row].chapter_id
           where segue.identifier! == "NextReadingPage"{
            
            // Create Fetch Reuqest for the next chapter
            let fr = NSFetchRequest(entityName: "Chapter")
            fr.sortDescriptors = []
            let pred = NSPredicate(format: "(id = %@) AND (story = %@)", nextChapterId, story)
            fr.predicate = pred
            
            // Create FetchedResultsController
            let fc = NSFetchedResultsController(fetchRequest: fr,
                                                managedObjectContext:fetchedResultsController!.managedObjectContext,
                                                sectionNameKeyPath: nil,
                                                cacheName: nil)
            
            // Inject it into the readingVC
            readingVC.fetchedResultsController = fc
        } else {
            print("Wasn't able to set the fetch request for the next page")
        }
    }

}
