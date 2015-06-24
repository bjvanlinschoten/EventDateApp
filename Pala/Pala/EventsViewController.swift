//
//  EventsViewController.swift
//  Pala
//
//  Created by Boris van Linschoten on 07-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//

import UIKit


class EventsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var wallUserArray: [Person]?
    var wall: Wall?
    var currentUser: User?
    var wallViewController: WallCollectionViewController?
    
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var genderSelect: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        if let id = self.currentUser?.parseUser.valueForKey("facebookId") as? NSString {
            let picURL: NSURL! = NSURL(string: "https://graph.facebook.com/\(id)/picture?width=600&height=600")
            self.profilePicture.sd_setImageWithURL(picURL)
            self.profilePicture.layer.masksToBounds = false
            self.profilePicture.layer.shadowOpacity = 0.3
            self.profilePicture.layer.shadowRadius = 1.0
            self.profilePicture.layer.shadowOffset = CGSize(width: 2, height: 2)
//            self.profilePicture.layer.cornerRadius = self.profilePicture.frame.width / 2
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
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
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as! EventsTableViewCell
        
        // Configure the cell
        let event = self.currentUser!.events?[indexPath.row] as! NSDictionary
        let eventId = event["id"] as! String
        let picURL: NSURL! = NSURL(string: "https://graph.facebook.com/\(eventId)/picture?width=600&height=600")
//        cell.imageView.frame = CGRectMake(10,10,150,230)
        cell.eventImageView.sd_setImageWithURL(picURL)
        cell.eventImageView.layer.masksToBounds = true
        cell.eventImageView.layer.cornerRadius = 4
        cell.eventView.layer.masksToBounds = false
        cell.eventView.layer.shadowOpacity = 0.3
        cell.eventView.layer.shadowRadius = 1.0
        cell.eventView.layer.shadowOffset = CGSize(width: 2, height: 2)
        cell.eventLabel.text = event["name"] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.wall = Wall()
        self.wall?.currentUser = self.currentUser
        let selectedEvent = self.currentUser?.events?[indexPath.row] as! NSDictionary
        let selectedEventId = selectedEvent["id"] as! String
        MBProgressHUD.showHUDAddedTo(self.wallViewController?.view, animated: true)
        self.closeLeft()
        self.currentUser?.parseUser.fetchInBackgroundWithBlock() { (object: PFObject?, error: NSError?) -> Void in
            self.wall?.getUsersToShow(selectedEventId, selectedGender: self.genderSelect.selectedSegmentIndex) { (userArray: [Person]) -> Void in
                if userArray != [] {
                    self.wallUserArray = userArray as [Person]
                    self.wallViewController?.wallCollection.hidden = false
                    self.wallViewController?.centerLabel.hidden = true
                    self.wallViewController?.wallUserArray = self.wallUserArray
                    self.wallViewController?.wallCollection.reloadData()
//                    self.slideMenuController()!.navigationController?.navigationItem.title = selectedEvent["name"] as? String
                } else {
                    self.wallViewController?.centerLabel.text = "You've either (dis)liked everyone already or you're the only one going!"
                }
                MBProgressHUD.hideHUDForView(self.wallViewController?.view, animated: true)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
