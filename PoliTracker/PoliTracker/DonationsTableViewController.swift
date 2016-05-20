//
//  DonationsTableViewController.swift
//  PoliTracker
//
//  Created by CS3714 on 12/9/15.
//  Copyright © 2015 Richard Hart. All rights reserved.
//

import UIKit

class DonationsTableViewController: UITableViewController {

    var pcc: String?
    var fec_id = ""
    var donations: Array<AnyObject> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPcc()
        getDonations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return donations.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("donationCell", forIndexPath: indexPath)
        let rowNumber = indexPath.row
        let tempDict = donations[rowNumber] as! Dictionary<String, AnyObject>
        
        let amount = tempDict["total"] as! Double
        
        cell.textLabel!.text = "$" + String(format: "%.2f", amount)
        cell.detailTextLabel!.text = tempDict["contributor_name"] as? String

        return cell
    }

    
    // MARK: - API Calls
    
    func getPcc() {
        let reqOne = "http://realtime.influenceexplorer.com/api//candidates/?format=json&page=1&page_size=10&fec_id=" + fec_id + "&apikey=b763c625654c4c53ad7b43a230d6b83d"
        // Create an NSURL object from the API URL string
        let url = NSURL(string: reqOne)
        let jsonData: NSData?
        
        do {
            /*
            Try getting the JSON data from the URL and map it into virtual memory, if possible and safe.
            DataReadingMappedIfSafe indicates that the file should be mapped into virtual memory, if possible and safe.
            */
            jsonData = try NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            
        } catch let error as NSError {
            
            showErrorMessage("Error in retrieving JSON data: \(error.localizedDescription)")
            return
        }
        
        if let jsonDataFromApiUrl = jsonData {
            do {
                let jsonDataDictionary = try NSJSONSerialization.JSONObjectWithData(jsonDataFromApiUrl, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                let results = jsonDataDictionary!["results"] as! Array<AnyObject>
                
                if results.count > 0 {
                    let tempDict = results[0] as! Dictionary<String, AnyObject>
                    pcc = tempDict["pcc"] as? String
                }
            } catch let error as NSError {
                
                showErrorMessage("Error in JSON Data Serialization: \(error.localizedDescription)")
                return
            }
            
        } else {
            
            showErrorMessage("Error in retrieving JSON data!")
        }
        
    }
    
    func getDonations() {
        if (pcc != nil) {
        
        let apiReq = "https://api.open.fec.gov/v1/committee/" + pcc! + "/schedules/schedule_a/by_contributor/?per_page=100&sort_nulls_large=true&api_key=HJEazDWWVLwMk0VKeBNN1c2TKYj1pNQIw1MgI2Cz&page=1"
        let url = NSURL(string: apiReq)
        let jsonData: NSData?
        
        do {
            /*
            Try getting the JSON data from the URL and map it into virtual memory, if possible and safe.
            DataReadingMappedIfSafe indicates that the file should be mapped into virtual memory, if possible and safe.
            */
            jsonData = try NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            
        } catch let error as NSError {
            
            showErrorMessage("Error in retrieving JSON data: \(error.localizedDescription)")
            return
        }
        
        if let jsonDataFromApiUrl = jsonData {
            do {
                let jsonDataDictionary = try NSJSONSerialization.JSONObjectWithData(jsonDataFromApiUrl, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                donations = jsonDataDictionary!["results"] as! Array<AnyObject>
                
            } catch let error as NSError {
                
                showErrorMessage("Error in JSON Data Serialization: \(error.localizedDescription)")
                return
            }
            
        } else {
            
            showErrorMessage("Error in retrieving JSON data!")
        }
        }
        else {
            showErrorMessage("Campaign donations could not be retrieved!")
        }

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
    
    

}
