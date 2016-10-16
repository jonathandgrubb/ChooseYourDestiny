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
        // TODO
        if let chapter = GitHubClient.sharedInstance().currentChapter {
            // text
            textView.text = chapter.text!
            
            // choices
            
            // picture
            //if let pic_data = chapter.picture {
            //    image.setValue(pic_data, forKey: "data")
            //} else if let pic_path = chapter.picture_path,
            //          let imageURL = NSURL(string: pic_path),
            //          let imageData = NSData(contentsOfURL: imageURL) {
            //    image.setValue(imageData, forKey: "data")
            //}
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Create the cell
        let cell = tableView.dequeueReusableCellWithIdentifier("ChoiceCell", forIndexPath: indexPath) as! ChoiceCell
        
        // http://stackoverflow.com/a/1754259
        cell.label?.numberOfLines = 0
        cell.label?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        switch indexPath.row {
        case 0:
            let message = "Grab one of the blahs!!! Grab one of the blahs!!! Grab one of the blahs!!! Grab one of the blahs!!! Grab one of the blahs!!! Grab one of the blahs!!! Grab one of the blahs!!! Grab one of the blahs!!! Grab one of the blahs!!! Grab one of the blahs!!! Grab one of the blahs!!! Grab one of the blahs!!!"
            //cell.textView.text = message
            cell.label?.text = message
        case 1:
            let message = "Get that other blah!!!"
            //cell.textView.text = message
            cell.label?.text = message
        case 2:
            let message = "Don't open that door!!!"
            //cell.textView.text = message
            cell.label?.text = message
        default:
            let message = "Run back out the door screaming!!!"
            //cell.textView.text = message
            cell.label?.text = message
        }
        
        return cell;
    }
    
    //func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //    let controller = ReadingViewController()
    //    presentViewController(controller, animated: true, completion: nil)
    //}
}
