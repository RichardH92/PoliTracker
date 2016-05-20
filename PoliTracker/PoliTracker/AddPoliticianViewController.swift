//
//  AddPoliticianViewController.swift
//  PoliTracker
//
//  Created by CS3714 on 12/9/15.
//  Copyright © 2015 Richard Hart. All rights reserved.
//

import UIKit

class AddPoliticianViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var statusLabel: UILabel!
    
    var results: Array<AnyObject> = []
    
    var activeTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForKeyboardNotifications()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getNewPoliticianFromAPI() {
        var apiReq = "http://congress.api.sunlightfoundation.com/legislators?first_name="
        apiReq += firstNameTextField.text!
        apiReq += "&last_name=" + lastNameTextField.text!
        apiReq += "&apikey=b763c625654c4c53ad7b43a230d6b83d"
        
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
                let tempDict = jsonDataDictionary as! NSMutableDictionary
                results = tempDict["results"] as! Array<AnyObject>
                
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
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func searchButtonPressed(sender: UIButton) {
        results = Array<AnyObject>()
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        
        if firstName == String("") || lastName == String("") {
            showErrorMessage("Please enter a first and last name!")
        }
        else {
        
            getNewPoliticianFromAPI()
        
        
            if results.count == 0 {
                showErrorMessage("The requested member of Congress was not found. Please search again.")
            }
            else {
                performSegueWithIdentifier("addPolitician-Save", sender: self)
            }
        }
    }
    
    
    /*
    ---------------------------------------
    MARK: - Handling Keyboard Notifications
    ---------------------------------------
    */
    
    // This method is called in viewDidLoad() to register self for keyboard notifications
    func registerForKeyboardNotifications() {
        
        // "An NSNotificationCenter object (or simply, notification center) provides a
        // mechanism for broadcasting information within a program." [Apple]
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self,
            selector:   "keyboardWillShow:",    // <-- Call this method upon Keyboard Will SHOW Notification
            name:       UIKeyboardWillShowNotification,
            object:     nil)
        
        notificationCenter.addObserver(self,
            selector:   "keyboardWillHide:",    //  <-- Call this method upon Keyboard Will HIDE Notification
            name:       UIKeyboardWillHideNotification,
            object:     nil)
    }
    
    
    // This method is called upon Keyboard Will SHOW Notification
    func keyboardWillShow(sender: NSNotification) {
        
        // "userInfo, the user information dictionary stores any additional
        // objects that objects receiving the notification might use." [Apple]
        let info: NSDictionary = sender.userInfo!
        
        /*
        Key     = UIKeyboardFrameBeginUserInfoKey
        Value   = an NSValue object containing a CGRect that identifies the start frame of the keyboard in screen coordinates.
        */
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        
        // Obtain the size of the keyboard
        let keyboardSize: CGSize = value.CGRectValue().size
        
        // Create Edge Insets for the view.
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        
        // Set the distance that the content view is inset from the enclosing scroll view.
        scrollView.contentInset = contentInsets
        
        // Set the distance the scroll indicators are inset from the edge of the scroll view.
        scrollView.scrollIndicatorInsets = contentInsets
        
        //-----------------------------------------------------------------------------------
        // If active text field is hidden by keyboard, scroll the content up so it is visible
        //-----------------------------------------------------------------------------------
        
        // Obtain the frame size of the View
        var selfViewFrameSize: CGRect = self.view.frame
        
        // Subtract the keyboard height from the self's view height
        // and set it as the new height of the self's view
        selfViewFrameSize.size.height -= keyboardSize.height
        
        // Obtain the size of the active UITextField object
        let activeTextFieldRect: CGRect? = activeTextField!.frame
        
        // Obtain the active UITextField object's origin (x, y) coordinate
        let activeTextFieldOrigin: CGPoint? = activeTextFieldRect?.origin
        
        
        if (!CGRectContainsPoint(selfViewFrameSize, activeTextFieldOrigin!)) {
            
            // If active UITextField object's origin is not contained within self's View Frame,
            // then scroll the content up so that the active UITextField object is visible
            scrollView.scrollRectToVisible(activeTextFieldRect!, animated:true)
        }
    }
    
    // This method is called upon Keyboard Will HIDE Notification
    func keyboardWillHide(sender: NSNotification) {
        
        // Set contentInsets to top=0, left=0, bottom=0, and right=0
        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        
        // Set scrollView's contentInsets to top=0, left=0, bottom=0, and right=0
        scrollView.contentInset = contentInsets
        
        // Set scrollView's scrollIndicatorInsets to top=0, left=0, bottom=0, and right=0
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    /*
    ------------------------------------
    MARK: - UITextField Delegate Methods
    ------------------------------------
    */
    
    // Assign tag numbers to the text fields in the Storyboard.
    
    // This method is called when the user taps inside a text field
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
    }
    
    /*
    This method is called when the user:
    (1) selects another UI object after editing in a text field
    (2) taps Return on the keyboard
    */
    func textFieldDidEndEditing(textField: UITextField) {
        activeTextField = nil
        
    }
    
    // This method is called when the user taps Return on the keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // Deactivate the text field and remove the keyboard
        textField.resignFirstResponder()
        
        return true
    }
    
    /*
    ---------------------------------------------
    MARK: - Register and Unregister Notifications
    ---------------------------------------------
    */
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // This method is invoked when single tap gesture is applied
    func handleSingleTap(gestureRecognizer: UIGestureRecognizer) {
        activeTextField?.resignFirstResponder()
    }
    
    @IBAction func scrollViewTouched(sender: UITapGestureRecognizer) {
        activeTextField?.resignFirstResponder()
    }


}
