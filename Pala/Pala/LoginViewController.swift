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
    
    // Properties
    var currentUser: User?
    @IBOutlet weak var loginButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set appearance
        self.navigationController?.navigationBarHidden = true
        self.view.backgroundColor = UIColor(hexString: "FF7400")
        
        // If user is already logged in
        if let user = PFUser.currentUser() {
            
            self.loginButton?.hidden = true
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            
            // Set currentUser
            self.currentUser = User(parseUser: user)
            
            // Set-up and load chat
            self.setUpPNChannel(user.objectId!)
            self.setUpUserForPushMessages()
            self.loadUnseenMessages()
            
            self.currentUser?.getUserEvents() { () -> Void in
                self.nextView()
            }

        } else {
            self.loginButton?.hidden = false
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    @IBAction func fbLoginClick(sender: AnyObject) {
        
        // Start login
        self.loginButton?.hidden = true
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        // Login with FB
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "user_events", "user_birthday"]) {
            (user: PFUser?, error: NSError?) -> Void in
            
            // If successful
            if let user = user {
                
                self.currentUser = User(parseUser: user)
                
                // Set-up channel for chat
                self.setUpPNChannel(user.objectId!)
                self.setUpUserForPushMessages()
                self.loadUnseenMessages()
                
                if user.isNew {
                    self.setUpUserForPushMessages()
                    self.currentUser?.populateNewUserWithFBData() {(completion:Void) in
                        self.nextView()
                    }
                } else {
                    self.currentUser?.parseUser.fetchInBackground()
                    self.nextView()
                }
            }
            else {
                // User cancelled login
                self.loginButton?.hidden = false
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            }
        }
    }
    
    func setUpUserForPushMessages(){
        
        // Set up installation with pointer to User, to send push to user
        let installation: PFInstallation = PFInstallation.currentInstallation()
        installation["user"] = self.currentUser?.parseUser
        installation.saveEventually { (success: Bool, error: NSError?) -> Void in
            if success == true {
                
            } else {
                println(error)
            }
        }
    }
    
    // Load messages that were received while app was inactive
    func loadUnseenMessages() {
        let chat = Chat()
        chat.currentUser = self.currentUser
        chat.loadUnseenMessagesFromServer()
    }
    
    // Connect to PubNub and subscribe to own channel
    func setUpPNChannel(userId: String) {
        let userChannel: PNChannel = PNChannel.channelWithName(userId) as! PNChannel
        PubNub.connect()
        PubNub.subscribeOn([userChannel])
    }
    
    
    func nextView() {
        MBProgressHUD.hideHUDForView(self.view, animated: true)

        // Instantiate all views that are in the slide menu
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        let wvc = storyboard.instantiateViewControllerWithIdentifier("WallViewController") as! WallCollectionViewController
        wvc.currentUser = self.currentUser
        let wnvc: UINavigationController = UINavigationController(rootViewController: wvc)

        let evc = storyboard.instantiateViewControllerWithIdentifier("EventsViewController") as! EventsViewController
        let envc: UINavigationController = UINavigationController(rootViewController: evc)
        evc.currentUser = self.currentUser
        evc.wallViewController = wvc

        let cvc = storyboard.instantiateViewControllerWithIdentifier("ChatsViewController") as! ChatsTableViewController
        let cnvc: UINavigationController = UINavigationController(rootViewController: cvc)
        cvc.currentUser = self.currentUser
        cvc.wallViewController = wvc

        // instantiate slide menu
        let slideMenuController = SlideMenuController(mainViewController: wnvc, leftMenuViewController: envc, rightMenuViewController: cnvc)
        let slideNvc: UINavigationController = UINavigationController(rootViewController: slideMenuController)
        slideNvc.navigationBarHidden = true
        slideNvc.automaticallyAdjustsScrollViewInsets = false
        
        // Present the slide menu
        self.presentViewController(slideNvc, animated: false, completion: nil)
    }
    
    
    // Log out user
    @IBAction func logOut(segue:UIStoryboardSegue) {
        prepareForLogout()
        self.currentUser?.logout()
    }
    
    // Prepare view for logout
    func prepareForLogout() {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        self.navigationController?.navigationBarHidden = true
        self.loginButton?.hidden = false
    }
}

