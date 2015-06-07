//
//  ViewController.swift
//  EventDateApp
//
//  Created by Boris van Linschoten on 02-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController  {
    let permissions = ["public_profile", "user_events", "user_birthday"]
    var currentUser: User?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var loginButton: UIButton?
    @IBOutlet weak var logoutButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.activityIndicator?.hidden = true
        
        if let user = PFUser.currentUser() {
            self.loginButton?.hidden = true
            self.currentUser = User(parseUser: user)
        } else {
            println("User Not Logged In")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func fbLoginClick(sender: AnyObject) {
        self.loginButton?.hidden = true
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    println("User signed up and logged in through Facebook!")
                } else {
                    println("User logged in through Facebook!")
                }
                self.populateUserWithFBData(user)
            }
            else {
                println("Uh oh. The user cancelled the Facebook login.")
            }
        }
    }
    
    @IBAction func fbLogoutClick(sender: AnyObject) {
        PFUser.logOut()
        self.loginButton?.hidden = false
        self.logoutButton?.hidden = true
    }
    
    func populateUserWithFBData(user: PFUser) {
        
        self.activityIndicator?.hidden = false
        self.activityIndicator?.startAnimating()
        self.logoutButton?.hidden = true
        self.currentUser = User(parseUser: user)
        
        let profileRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        profileRequest.startWithCompletionHandler{(connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            if let resultDict = result as? NSDictionary {
                self.currentUser!.facebookId = resultDict.valueForKey("id") as! NSString
                self.currentUser!.parseUser.setValue(self.currentUser!.facebookId, forKey: "facebookId")
                self.currentUser!.parseUser.setValue(resultDict.valueForKey("first_name"), forKey: "name")
                self.currentUser!.parseUser.setValue(resultDict.valueForKey("gender"), forKey:"gender")
                self.currentUser!.parseUser.setValue(resultDict.valueForKey("birthday"), forKey: "birthday")
                self.currentUser!.saveUserToParse()
            }
        }
        
        let eventsRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath:"/me/events" , parameters: nil, HTTPMethod: "GET")
        eventsRequest.startWithCompletionHandler{(connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            if let result = result as? NSDictionary {
                if let events = result.valueForKey("data") as? NSMutableArray {
                    self.currentUser!.events = events as NSMutableArray
                }
            }
            self.activityIndicator?.stopAnimating()
            self.activityIndicator?.hidden = true
            self.logoutButton?.hidden = false
            self.nextView()
        }
    }

    func nextView() {
        self.performSegueWithIdentifier("loginToEvents", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "loginToEvents" {
            let nvc = segue.destinationViewController as! UINavigationController
            let vc = nvc.topViewController as! EventsViewController
            vc.currentUser = self.currentUser
        }
    }
}

