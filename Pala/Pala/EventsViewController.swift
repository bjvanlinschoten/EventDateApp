//
//  EventsViewController.swift
//  Pala
//
//  Created by Boris van Linschoten on 07-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var wallUserArray: [Person]?
    var wall: Wall?
    var currentUser: User?
    var wallViewController: WallCollectionViewController?
    
    @IBOutlet var eventsTableView: UITableView!
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.eventsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        if let id = self.currentUser?.parseUser.valueForKey("facebookId") as? NSString {
            let picURL: NSURL! = NSURL(string: "https://graph.facebook.com/\(id)/picture?width=600&height=600")
            self.profilePicture.sd_setImageWithURL(picURL)
            self.profilePicture.layer.cornerRadius = self.profilePicture.frame.width / 2
            if let age = self.currentUser?.getUserAge() as NSInteger! {
                if let name = self.currentUser?.parseUser.valueForKey("name") as? String {
                        self.nameLabel.text = "\(name) (\(age))"
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.view.backgroundColor = UIColor.whiteColor()
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
        self.wall = Wall()
        self.wall?.currentUser = self.currentUser
        let selectedEvent = self.currentUser?.events?[indexPath.row] as! NSDictionary
        let selectedEventId = selectedEvent["id"] as! String
        self.currentUser?.parseUser.fetchInBackgroundWithBlock() { (object: PFObject?, error: NSError?) -> Void in
            self.wall?.getUsersToShow(selectedEventId) { (userArray: [Person]) -> Void in
                self.wallUserArray = userArray as [Person]
                self.wallViewController?.wallUserArray = self.wallUserArray
                self.wallViewController?.wallCollection.reloadData()
                self.wallViewController?.wallCollection.hidden = false
                self.wallViewController?.selectEventLabel.hidden = true
                self.closeLeft()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "eventsToWall" {
            let nvc = segue.destinationViewController as! UITabBarController
            let wvc = nvc.viewControllers?.first as! WallCollectionViewController
            let cvc = nvc.viewControllers?[1] as! ChatsTableViewController
            wvc.currentUser = self.currentUser
            cvc.currentUser = self.currentUser
            wvc.wallUserArray = self.wallUserArray
        }
    }

}
