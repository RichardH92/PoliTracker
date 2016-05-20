//
//  PoliticianTableViewController.swift
//  PoliTracker
//
//  Created by CS3714 on 12/7/15.
//  Copyright © 2015 Richard Hart. All rights reserved.
//

import UIKit

class PoliticianTableViewController: UITableViewController {

    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    @IBOutlet var poliTableView: UITableView!
    
    var results: Array<AnyObject> = []
    var currPoliData: Dictionary<String, AnyObject>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the Edit button on the left of the navigation bar to enable editing of the table view rows
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        // Set up the Add button on the right of the navigation bar to call the addButtonPressed method when tapped
        let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addButtonPressed:")
        self.navigationItem.rightBarButtonItem = addButton
        
        let tempDict = applicationDelegate.dict_Favorite_Politicians as! Dictionary<String, AnyObject>
        
        results = tempDict["results"] as! Array<AnyObject>
        
        self.title = "Your Politicians"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PoliticianCell", forIndexPath: indexPath)
        let rowNumber = indexPath.row
        
        let poliData = results[rowNumber] as! Dictionary<String, AnyObject>
        
        let title = poliData["title"] as! String
        cell.textLabel!.text = title + ". " + getName(poliData)
        
        let party = poliData["party"] as! String
        if party == "R" {
            cell.imageView!.image = UIImage(named: "RepublicanLogo.png")
            cell.textLabel!.textColor = UIColor.redColor()
        }
        else if party == "D" {
            cell.imageView!.image = UIImage(named: "DemocraticLogo.png")
            cell.textLabel!.textColor = UIColor.blueColor()
        }
        else {
            cell.imageView!.image = UIImage(named: "I.png")
        }
        cell.imageView!.contentMode = .ScaleToFill
        let frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        cell.imageView!.frame = frame
        
        var temp = party
        
        if title == "Rep" || title == "Sen" {
            let state = poliData["state"] as! String
            temp += ", " + state
        }
        
        if title == "Rep" {
            let district = poliData["district"] as! Int
            temp += ", District " + String(district)
        }
        
        cell.detailTextLabel!.text = temp

        return cell
    }
    
    func getName(poliData: Dictionary<String, AnyObject>) -> String {
        let keys = poliData.keys
        var nickname = ""
        
        if keys.contains("nickname") && poliData["nickname"] is String {
            nickname = poliData["nickname"] as! String
        }
        else {
            var temp = poliData["first_name"] as! String
            
            if (temp.characters.count == 2) {
                
                if keys.contains("middle_name") && poliData["middle_name"] is String {
                    temp = poliData["middle_name"] as! String
                }
            }
            
            nickname = temp
            
        }
        
        let lastname = poliData["last_name"] as! String
        
        return nickname + " " + lastname
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {   // Handle the Delete action
            
            let rowToDelete = indexPath.row
            results.removeAtIndex(rowToDelete)
            
            applicationDelegate.dict_Favorite_Politicians["results"] = results
            
            poliTableView.reloadData()
        }
    }

    
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let rowNumberFrom = fromIndexPath.row
        let rowNumberTo = toIndexPath.row
        
        let poliOne = results[rowNumberFrom]
        let poliTwo = results[rowNumberTo]
        
        results[rowNumberFrom] = poliTwo
        results[rowNumberTo] = poliOne
        
        applicationDelegate.dict_Favorite_Politicians.setValue(results, forKey: "results")
    }

    
    // MARK: - Navigation
    
    func addButtonPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("addPolitician", sender: self)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let rowNumber: Int = indexPath.row    // Identify the row number
        currPoliData = results[rowNumber] as! Dictionary<String, AnyObject>
        
        performSegueWithIdentifier("showPoliInfo", sender: self)
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let rowNumber: Int = indexPath.row    // Identify the row number
        currPoliData = results[rowNumber] as! Dictionary<String, AnyObject>
        
        performSegueWithIdentifier("politifactHist", sender: self)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //self.title = "Back"
        
        if segue.identifier == "politifactHist" {
            let tempName = getName(currPoliData!)
            let politifactViewController: PolitifactHistTableViewController = segue.destinationViewController as! PolitifactHistTableViewController
            politifactViewController.dispName = tempName
            politifactViewController.searchName = tempName.stringByReplacingOccurrencesOfString(" ", withString: "-").lowercaseString
        }
        else if segue.identifier == "showPoliInfo" {
            let tabViewController = segue.destinationViewController as! PoliticianTabBarController
            tabViewController.currPoliData = currPoliData
        }
    }
    
    @IBAction func unwindToPoliticianTableViewController (segue : UIStoryboardSegue) {
        
        if segue.identifier == "addPolitician-Save" {
            let controller: AddPoliticianViewController = segue.sourceViewController as! AddPoliticianViewController
            let newDict = controller.results[0] as! Dictionary<String, AnyObject>
            results.append(newDict)
            
            applicationDelegate.dict_Favorite_Politicians.setValue(results, forKey: "results")
            
            poliTableView.reloadData()
        }
    }


}
