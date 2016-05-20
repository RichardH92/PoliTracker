//
//  PoliticianTabBarController.swift
//  PoliTracker
//
//  Created by CS3714 on 12/9/15.
//  Copyright © 2015 Richard Hart. All rights reserved.
//

import UIKit

class PoliticianTabBarController: UITabBarController {

    var website_url = ""
    var currPoliData: Dictionary<String, AnyObject>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewControllers = self.viewControllers as! NSArray
        
        let webViewController = viewControllers[1] as! WebsiteViewController
        webViewController.page_url = currPoliData!["website"] as! String
        
        let twitter_id = currPoliData!["twitter_id"] as! String
        print(twitter_id)
        
        let infoViewController = viewControllers[0] as! PoliticianInfoViewController
        infoViewController.poli_data = currPoliData
        
        let fec_ids = currPoliData!["fec_ids"] as! [String]
        let donationsViewController = viewControllers[2] as! DonationsTableViewController
        donationsViewController.fec_id = fec_ids[0]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
