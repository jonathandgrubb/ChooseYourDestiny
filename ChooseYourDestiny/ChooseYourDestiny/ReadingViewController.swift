//
//  ReadingViewController.swift
//  ChooseYourDestiny
//
//  Created by Jonathan Grubb on 10/15/16.
//  Copyright © 2016 Jonathan Grubb. All rights reserved.
//

import UIKit

class ReadingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 140
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // pop the navigation stack if this was navigated to as a new story (and scroll to the top)
        if let startOver = GitHubClient.sharedInstance().startAtBeginning where startOver == true {
            self.navigationController?.popToRootViewControllerAnimated(true)
            self.scrollView.setContentOffset(CGPoint(x: 0, y:0), animated: true)
            GitHubClient.sharedInstance().startAtBeginning = false
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
