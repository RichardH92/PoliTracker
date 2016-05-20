//
//  PoliticianInfoViewController.swift
//  PoliTracker
//
//  Created by CS3714 on 12/9/15.
//  Copyright © 2015 Richard Hart. All rights reserved.
//

import UIKit

class PoliticianInfoViewController: UIViewController {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var genderLabel: UILabel!
    @IBOutlet var stateLabel: UILabel!
    @IBOutlet var birthdayLabel: UILabel!
    @IBOutlet var termLabel: UILabel!
    @IBOutlet var partyLabel: UILabel!
    
    var url = ""
    var office = ""
    var twitter = ""
    var fb = ""
    var youtube = ""

    var poli_data: Dictionary<String, AnyObject>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let term_start = poli_data!["term_start"] as! String
        let birthday = poli_data!["birthday"] as! String
        let gender = poli_data!["gender"] as! String
        let state = poli_data!["state"] as! String
        let term_end = poli_data!["term_end"] as! String
        let first_name = poli_data!["first_name"] as! String
        let last_name = poli_data!["last_name"] as! String
        let title = poli_data!["title"] as! String
        let party = poli_data!["party"] as! String
        
        office = poli_data!["office"] as! String
        
        if poli_data!["twitter_id"] != nil {
            twitter = poli_data!["twitter_id"] as! String
        }
        
        if poli_data!["facebook_id"] != nil {
            fb = poli_data!["facebook_id"] as! String
        }
        
        if poli_data!["youtube_id"] != nil {
            youtube = poli_data!["youtube_id"] as! String
        }
        
        let name = title + ". " + first_name + " " + last_name
        nameLabel.text! = name
        
        birthdayLabel.text! += birthday
        genderLabel.text! += gender
        stateLabel.text! += state
        termLabel.text! += term_start + " to " + term_end
        partyLabel.text! += party
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func twitterPressed(sender: AnyObject) {
        if twitter == "" {
            showErrorMessage("The Twitter page could not be retrieved!")
        }
        else {
            url = "https://twitter.com/" + twitter + "?lang=en"
            performSegueWithIdentifier("showWeb", sender: self)
        }
    }
    
    @IBAction func facebookPressed(sender: UIButton) {
        if fb == "" {
            showErrorMessage("The Facebook page could not be retrieved!")
        }
        else {
            url = "https://www.facebook.com/" + fb + "/"
            performSegueWithIdentifier("showWeb", sender: self)
        }
    }

    @IBAction func youtubePressed(sender: UIButton) {
        if youtube == "" {
            showErrorMessage("The YouTube page could not be retrieved!")
        }
        else {
            url = "https://www.youtube.com/user/" + youtube
            performSegueWithIdentifier("showWeb", sender: self)
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showWeb" {
            let controller: MediaViewController = segue.destinationViewController as! MediaViewController
            controller.page_url = url
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
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
