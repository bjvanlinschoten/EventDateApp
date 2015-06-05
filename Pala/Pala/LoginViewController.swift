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
    let permissions = ["public_profile", "user_events"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if PFUser.currentUser() != nil {
            println("User Logged In")
        } else {
            println("User Not Logged In")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func fbLoginClick(sender: AnyObject) {
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user
            {
                if user.isNew
                {
                    println("User signed up and logged in through Facebook!")
                }
                else
                {
                    println("User logged in through Facebook!")
                }
                let user: User = User(parseUser: user)
                user.populateUserWithFBData()
                self.performSegueWithIdentifier("LoginToEventsSegue", sender: self)
            }
            else
            {
                println("Uh oh. The user cancelled the Facebook login.")
            }
        }
    }
    
    @IBAction func fbLogoutClick(sender: AnyObject) {
        PFUser.logOut()
        if PFUser.currentUser() != nil {
            println("User Logged In")
        } else {
            println("User Not Logged In")
        }
    }
}

