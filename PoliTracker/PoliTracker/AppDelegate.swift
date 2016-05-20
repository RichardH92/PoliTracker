//
//  AppDelegate.swift
//  PoliTracker
//
//  Created by CS3714 on 11/10/15.
//  Copyright © 2015 Richard Hart. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var dict_Favorite_Politicians: NSMutableDictionary = NSMutableDictionary()
    var locationManager = CLLocationManager()
    var currentState = "VA"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        readFavoritePoliticiansFile()
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        writeFavoritePoliticiansFile()
    }
    
    func readFavoritePoliticiansFile() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectoryPath = paths[0] as String
        
        let plistFilePathInDocumentDirectory = documentDirectoryPath + "/MyFavoritePoliticians.plist"
        let dictionaryFromFile: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: plistFilePathInDocumentDirectory)
        
        
        // If the file exists locally
        if let dictionaryFromFileInDocumentDirectory = dictionaryFromFile {
            dict_Favorite_Politicians = NSKeyedUnarchiver.unarchiveObjectWithFile(plistFilePathInDocumentDirectory) as! NSMutableDictionary
        }
            
            // The file doesn't exist locally, load the data from the API
        else {
            getPoliticianInfoFromAPI()
        }
    }
    
    func writeFavoritePoliticiansFile() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectoryPath = paths[0] as String
        let plistFilePathInDocumentDirectory = documentDirectoryPath + "/MyFavoritePoliticians.plist"
        NSKeyedArchiver.archiveRootObject(dict_Favorite_Politicians, toFile: plistFilePathInDocumentDirectory)
    }
    
    func getCurrentState() {
        //TODO: implement this method
        currentState = "VA"
    }
    
    func getPoliticianInfoFromAPI() {
        getCurrentState()
        
        let apiReq = "http://congress.api.sunlightfoundation.com/legislators?state=" + currentState + "&apikey=b763c625654c4c53ad7b43a230d6b83d"
        
        // Create an NSURL object from the API URL string
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
            
            // The JSON data is successfully obtained from the API
            
            /*
            NSJSONSerialization class is used to convert JSON and Foundation objects (e.g., NSDictionary) into each other.
            NSJSONSerialization class's method JSONObjectWithData returns an NSDictionary object from the given JSON data.
            */
            
            do {
                let jsonDataDictionary = try NSJSONSerialization.JSONObjectWithData(jsonDataFromApiUrl, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary

                dict_Favorite_Politicians = jsonDataDictionary as! NSMutableDictionary
            
            } catch let error as NSError {
                
                showErrorMessage("Error in JSON Data Serialization: \(error.localizedDescription)")
                return
            }
            
        } else {
            
            showErrorMessage("Error in retrieving JSON data!")
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
        //presentViewController(alertController, animated: true, completion: nil)
        print("Unable to Obtain Data! " + errorMessage)
    }


}

