//
//  PolitifactHistTableViewController.swift
//  PoliTracker
//
//  Created by CS3714 on 12/8/15.
//  Copyright © 2015 Richard Hart. All rights reserved.
//

import UIKit

class PolitifactHistTableViewController: UITableViewController, NSXMLParserDelegate {
    
    var parser = NSXMLParser()
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var statement = NSMutableString()
    var ruling = NSMutableString()
    var statement_url = NSMutableString()
    var graphic_url = NSMutableString()
    
    var dispName = ""
    var searchName = ""
    var page_url = ""
    
    let tableViewRowHeight = CGFloat(90.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPolitifactInfoFromAPI()
        
        self.title = dispName + "'s Politifact History"
        
        if posts.count == 0 {
            showErrorMessage(dispName + " doesn't have a Politifact history.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StatementCell", forIndexPath: indexPath)
        let rowNumber = indexPath.row
        let data = posts[rowNumber] as! NSMutableDictionary
        
        let statement = data["statement"] as! String
        let ruling = data["ruling"] as! String
        let graphic_url = data["graphic_url"] as! String
        
        cell.textLabel!.text = formatString(statement)
        cell.detailTextLabel!.text = ruling
        cell.imageView!.contentMode = .ScaleAspectFit
        
        let url = NSURL(string: graphic_url)
        
        var imageData: NSData?
        
        do {
            imageData = try NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            cell.imageView!.image = UIImage(data: imageData!)
            
        } catch let error as NSError {
            showErrorMessage("Error in retrieving thumbnail image data: \(error.localizedDescription)")
        }

        return cell
    }
    
    func formatString(statement: String) -> String {
        var tempStatement = statement.stringByReplacingOccurrencesOfString("<p>", withString: "")
        tempStatement = tempStatement.stringByReplacingOccurrencesOfString("<\\p>", withString: "")
        tempStatement = tempStatement.stringByReplacingOccurrencesOfString("&quot;", withString: "\"")
        tempStatement = tempStatement.stringByReplacingOccurrencesOfString("\n", withString: "")
        tempStatement = tempStatement.stringByReplacingOccurrencesOfString("\t", withString: "")
        tempStatement = tempStatement.stringByReplacingOccurrencesOfString("&#39;", withString: "'")
        
        return tempStatement
    }
    
    
    // Asks the table view delegate to return the height of a given row.
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableViewRowHeight
    }
    
    
    
    // MARK: - Navigation
    
    // Informs the table view delegate that the specified row is selected.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let rowNumber: Int = indexPath.row
        let data = posts[rowNumber] as! NSMutableDictionary
        page_url = data["statement_url"] as! String
        //self.title = "Back"
        
        performSegueWithIdentifier("showPolitifactPage", sender: self)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPolitifactPage" {
            let politifactViewController: PolitifactWebViewController = segue.destinationViewController as! PolitifactWebViewController
            politifactViewController.page_url = page_url
        }
        
    }

    
    
    // MARK: - XML Parsing
    
    func getPolitifactInfoFromAPI() {
        let apiReq = "http://www.politifact.com/api/statements/truth-o-meter/people/" + searchName + "/xml/?n=10"
        let url = NSURL(string: apiReq)
        
        posts = []
        parser = NSXMLParser(contentsOfURL: url!)!
        parser.delegate = self
        parser.parse()
    }
    
    func showErrorMessage(errorMessage: String) {
        
        /*
        Create a UIAlertController object; dress it up with title, message, and preferred style;
        and store its object reference into local constant alertController
        */
        let alertController = UIAlertController(title: "Unable to Obtain Data!", message: errorMessage,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        // Create a UIAlertAction object and add it to the alert controller
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        // Present the alert controller by calling the presentViewController method
        presentViewController(alertController, animated: true, completion: nil)
    }

    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        element = elementName
        
        if (elementName as NSString).isEqualToString("statement_url") {
            elements = NSMutableDictionary()
            elements = [:]
            statement = NSMutableString()
            ruling = NSMutableString()
            statement_url = NSMutableString()
            graphic_url = NSMutableString()
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String)
    {
        if element.isEqualToString("statement") {
            statement.appendString(string)
        }
        else if element.isEqualToString("statement_url") {
            statement_url.appendString(string)
        }
        else if element.isEqualToString("ruling") {
            ruling.appendString(string)
        }
        else if element.isEqualToString("canonical_ruling_graphic") {
            graphic_url.appendString(string)
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if (elementName as NSString).isEqualToString("statement") {
            if !statement.isEqual(nil) {
                elements.setObject(statement, forKey: "statement")
            }
            
            posts.addObject(elements)
        }
        else if (elementName as NSString).isEqualToString("statement_url") {
            if !statement_url.isEqual(nil) {
                elements.setObject(statement_url, forKey: "statement_url")
            }
        }
        else if (elementName as NSString).isEqualToString("ruling") {
            if !ruling.isEqual(nil) {
                elements.setObject(ruling, forKey: "ruling")
            }
        }
        else if (elementName as NSString).isEqualToString("canonical_ruling_graphic") {
            if !graphic_url.isEqual(nil) {
                elements.setObject(graphic_url, forKey: "graphic_url")
            }
        }
    }
    
    
}
