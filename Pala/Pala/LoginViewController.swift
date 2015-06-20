//
//  ViewController.swift
//  EventDateApp
//
//  Created by Boris van Linschoten on 02-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//

import UIKit
import Parse

protocol LoginViewControllerDelegate {
    func prepareForLogout()
}

class LoginViewController: UIViewController  {
    var currentUser: User?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var loginButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBarHidden = true
        self.activityIndicator?.hidden = true
        
        if let user = PFUser.currentUser() {
            println("User Logged In")
            
            self.loginButton?.hidden = true
            self.activityIndicator?.hidden = false
            self.activityIndicator?.startAnimating()
            
            if !PFFacebookUtils.isLinkedWithUser(user) {
                PFFacebookUtils.linkUserInBackground(user, withReadPermissions: nil) { (succeeded: Bool, error: NSError?) -> Void in
                    if succeeded {
                        println("Woohoo, the user is linked with Facebook!")
                    }
                }
            }
            self.currentUser?.parseUser.fetchInBackground()
            
            self.currentUser = User(parseUser: user)
            self.currentUser?.getUserEvents() {(completion:Void) in
                self.nextView()
            }
            
            // Set-up and load chat
            self.setUpPNChannel(user.objectId!)
            self.setUpUserForPushMessages()
            self.loadUnseenMessages()

        } else {
            self.loginButton?.hidden = false
            println("User Not Logged In")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    @IBAction func fbLoginClick(sender: AnyObject) {
        self.loginButton?.hidden = true
        self.activityIndicator?.hidden = false
        self.activityIndicator?.startAnimating()
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "user_events", "user_birthday"]) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                self.currentUser = User(parseUser: user)
                
                // Set-up channel for chat
                self.setUpPNChannel(user.objectId!)
                self.setUpUserForPushMessages()
                self.loadUnseenMessages()
                
                if user.isNew {
                    println("User signed up and logged in through Facebook!")
                    self.setUpUserForPushMessages()
                    self.currentUser?.populateNewUserWithFBData() {(completion:Void) in
                        self.currentUser?.getUserEvents() {(completion:Void) in
                            self.nextView()
                        }
                    }
                } else {
                    println("User logged in through Facebook!")
                    self.currentUser?.parseUser.fetchInBackground()
                    self.currentUser!.personObject = Person(objectId: user.objectId!, facebookId: self.currentUser?.parseUser.valueForKey("facebookId") as! String, name: self.currentUser?.parseUser.valueForKey("name") as! String, birthday: self.currentUser?.parseUser.valueForKey("birthday") as! String)
                    self.currentUser?.getUserEvents() {(completion:Void) in
                        self.nextView()
                    }
                }
            }
            else {
                self.loginButton?.hidden = false
                self.activityIndicator?.stopAnimating()
                self.activityIndicator?.hidden = true
                println("Uh oh. The user cancelled the Facebook login.")
            }
        }
    }
    
    func setUpUserForPushMessages(){
        let installation: PFInstallation = PFInstallation.currentInstallation()
        installation["user"] = self.currentUser?.parseUser
        installation.saveEventually { (success: Bool, error: NSError?) -> Void in
            if success == true {
                
            } else {
                println(error)
            }
        }
    }
    
    func loadUnseenMessages() {
        let chat = Chat()
        chat.currentUser = self.currentUser
        chat.loadUnseenMessagesFromServer()
    }
    
    func setUpPNChannel(userId: String) {
        let userChannel: PNChannel = PNChannel.channelWithName(userId) as! PNChannel
        PubNub.connect()
        PubNub.subscribeOn([userChannel])
    }
    
    func nextView() {
        self.performSegueWithIdentifier("loginToEvents", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "loginToEvents" {
            let vc = segue.destinationViewController as! EventsViewController
            vc.currentUser = self.currentUser
        }
    }
    
    func prepareForLogout() {
        self.navigationController?.navigationBarHidden = true
        self.loginButton?.hidden = false
        self.activityIndicator?.hidden = true
        self.activityIndicator?.stopAnimating()
    }
}

