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
    @IBOutlet weak var loginButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBarHidden = true
        self.view.backgroundColor = UIColor(hexString: "FF7400")
        
        if let user = PFUser.currentUser() {
            println("User Logged In")
            
            self.loginButton?.hidden = true
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            
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
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
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
                MBProgressHUD.hideHUDForView(self.view, animated: true)
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
        MBProgressHUD.hideHUDForView(self.view, animated: true)

        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        let wvc = storyboard.instantiateViewControllerWithIdentifier("WallViewController") as! WallCollectionViewController
        let evc = storyboard.instantiateViewControllerWithIdentifier("EventsViewController") as! EventsViewController
        let cvc = storyboard.instantiateViewControllerWithIdentifier("ChatsViewController") as! ChatsTableViewController
        wvc.currentUser = self.currentUser
        evc.currentUser = self.currentUser
        cvc.currentUser = self.currentUser
        
        let wnvc: UINavigationController = UINavigationController(rootViewController: wvc)
        let cnvc: UINavigationController = UINavigationController(rootViewController: cvc)
        evc.wallViewController = wvc
        cvc.wallViewController = wvc
        
        let slideMenuController = SlideMenuController(mainViewController: wnvc, leftMenuViewController: evc, rightMenuViewController: cnvc)
        let slideNvc: UINavigationController = UINavigationController(rootViewController: slideMenuController)
        
        slideNvc.navigationBarHidden = true
        slideNvc.automaticallyAdjustsScrollViewInsets = false
        wnvc.automaticallyAdjustsScrollViewInsets = false
        
        self.presentViewController(slideNvc, animated: false) { () -> Void in
            println("success")
        }
        
//        self.performSegueWithIdentifier("loginToEvents", sender: self)
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "loginToEvents" {
//            let vc = segue.destinationViewController as! EventsViewController
//            vc.currentUser = self.currentUser
//        }
//    }
    
    @IBAction func logOut(segue:UIStoryboardSegue) {
        self.currentUser?.logout()
        prepareForLogout()
    }
    
    func prepareForLogout() {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        self.navigationController?.navigationBarHidden = true
        self.loginButton?.hidden = false
    }
}

