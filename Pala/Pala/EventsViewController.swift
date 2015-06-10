//
//  EventsViewController.swift
//  Pala
//
//  Created by Boris van Linschoten on 07-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var currentUser: User?
    @IBOutlet var eventsTableView: UITableView!
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.eventsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        if let id = self.currentUser?.parseUser.valueForKey("facebookId") as? NSString {
            let picURL: NSURL! = NSURL(string: "https://graph.facebook.com/\(id)/picture?type=large")
            self.profilePicture.sd_setImageWithURL(picURL)
            self.profilePicture.layer.cornerRadius = self.profilePicture.frame.width / 2
            if let age = self.currentUser?.getUserAge() as NSInteger! {
                if let name = self.currentUser?.parseUser.valueForKey("name") as? String {
                        self.nameLabel.text = "\(name) (\(age))"
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        self.navigationItem.hidesBackButton = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let user = self.currentUser {
            if let events = user.events {
                return events.count
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = self.eventsTableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        
        let event = self.currentUser!.events?[indexPath.row] as! NSDictionary
        let cellText = event.valueForKey("name") as! NSString
        cell.textLabel?.text = cellText as String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentEvent = self.currentUser?.events?[indexPath.row] as! NSDictionary
        self.currentUser?.parseUser.setValue(currentEvent.valueForKey("id"), forKey: "currentEvent")
        self.currentUser?.saveUserToParse()
        self.performSegueWithIdentifier("eventsToWall", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "eventsToWall" {
            let nvc = segue.destinationViewController as! UITabBarController
            let vc = nvc.viewControllers?.first as! WallCollectionViewController
            vc.currentUser = self.currentUser
        }
    }
    
    @IBAction func logout() {
        if let loginView = navigationController?.viewControllers[0] as? LoginViewController {
            self.currentUser?.logout()
            loginView.prepareForLogout()
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

}
