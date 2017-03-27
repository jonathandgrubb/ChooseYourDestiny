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
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var currentChapter: Chapter?
    var currentChoices = [Choice]()
    
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
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 140
        
        // http://stackoverflow.com/a/11937989/4611868
        // get rid of the empty rows at the bottom of the choices
        tableView?.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // take out background colors
        let bgColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        scrollView.backgroundColor = bgColor
        stackView.backgroundColor = bgColor
        view.backgroundColor = bgColor
        
        // if this was navigated to as a new story
        if let startOver = GitHubClient.sharedInstance().startAtBeginning, startOver == true {
            
            // pop the navigation stack
            _ = self.navigationController?.popToRootViewController(animated: true)
            
            // scroll to the top
            self.scrollView.setContentOffset(CGPoint(x: 0, y:0), animated: true)
            
            GitHubClient.sharedInstance().startAtBeginning = false

            // don't hide the image by default
            image.isHidden = false
        }
        
        // load the data for the current chapter
        if let fc = fetchedResultsController,
           let chapters = fc.fetchedObjects as? [Chapter], chapters.count > 0 {
            
            // set the current chapter
            currentChapter = chapters[0]
            
            // text
            textView.text = addPersonalization(currentChapter!.text)

            // picture
            if (chapterImageLoad() == false) {
                image.isHidden = true
            }

            // load the choices for this chapter
            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Choice")
            fr.sortDescriptors = []
            let pred = NSPredicate(format: "(chapter = %@)", currentChapter!)
            fr.predicate = pred
            // Create FetchedResultsController (is this better than creating a new one?)
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
                                                managedObjectContext:fetchedResultsController!.managedObjectContext,
                                                sectionNameKeyPath: nil,
                                                cacheName: nil)
            executeSearch()
            
            currentChoices.removeAll()
            if let choices = fetchedResultsController!.fetchedObjects as? [Choice] {
                for choice in choices {
                    currentChoices.append(choice)
                }
            }
        }
        
        // Load the name of the chapter
        if let chapter = currentChapter {
            navigationItem.title = chapter.name
        }
        
        // if the reading tab was clicked w/o any story ever being loaded, don't show anything
        if currentChapter == nil {
            scrollView.isHidden = true
        } else {
            scrollView.isHidden = false
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let chapter = currentChapter, let choices = chapter.choice {
            return choices.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChoiceCell", for: indexPath) as! ChoiceCell
        
        // http://stackoverflow.com/a/1754259
        cell.label?.numberOfLines = 0
        cell.label?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let readingVC = segue.destination as? ReadingViewController,
           let chapter = currentChapter, let story = chapter.story,
           let selectedRowIndexPath = tableView.indexPathForSelectedRow,
           let nextChapterId = currentChoices[selectedRowIndexPath.row].chapter_id, segue.identifier! == "NextReadingPage"{
            
            // Create Fetch Reuqest for the next chapter
            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Chapter")
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

    func chapterImageLoad() -> Bool {
   
        var loadSuccess = true
        
        if let pic_data = currentChapter!.picture {
            
            print("retrieving image data from CORE Data")
            // set the image for the chapter
            image.image = UIImage(data: pic_data as Data)
            
        } else if let pic_path = currentChapter!.picture_path {
            
            // reaching out over the network for the image

            if let imageURL = URL(string: pic_path), pic_path.hasPrefix("https") {
            
                print("retrieving image data from web (outside of GitHub)")
                
                if let imageData = try? Data(contentsOf: imageURL) {
                    // set the image for the chapter
                    image.image = UIImage(data: imageData)
                    // save image data to the model
                    currentChapter!.setValue(imageData, forKey: "picture")
                } else {
                    print("problem getting \(imageURL)")
                    ControllerCommon.displayErrorDialog(self, message: "Problem Loading Image")
                    loadSuccess = false
                }
                
            } else {
            
                if let author = currentChapter!.story!.author,
                   let repo = currentChapter!.story!.repo {
                
                    print("retrieving image data from GitHub repo")
                    
                    GitHubClient.sharedInstance().getStoryResource(pic_path, author: author, repo: repo) { (success, error, data) in
                        if success == false {
                            print("problem getting \(pic_path) from \(author)'s \(repo) repo")
                            ControllerCommon.displayErrorDialog(self, message: "Problem Loading Image")
                            loadSuccess = false
                        } else {
                            DispatchQueue.main.async {
                                // set the image for the chapter
                                self.image.image = UIImage(data: data!)
                                
                                // save image data to the model
                                self.currentChapter!.setValue(data!, forKey: "picture")
                            }
                        }
                    }
                } else {
                    print("author or repo missing from the story model. shouldn't get here")
                    ControllerCommon.displayErrorDialog(self, message: "Problem With Story File")
                    loadSuccess = false
                }
                
            }
            
        } else {
            print("image data not specified")
            loadSuccess = false
        }
        
        return loadSuccess
    }
    
    func addPersonalization(_ text: String?) -> String? {
        if let text = text {
            if let fname = UserDefaults.standard.string(forKey: "firstName") {
                return text.replacingOccurrences(of: "[[name]]", with: fname)
            } else {
                return text
            }
        } else {
            return nil
        }
    }
}
