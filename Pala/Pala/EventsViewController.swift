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
    var refreshControl: UIRefreshControl!
    var selectedGender: Int?
   
    @IBOutlet var eventsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Pull to refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refreshEventsTable", forControlEvents: UIControlEvents.ValueChanged)
        self.eventsTable.addSubview(self.refreshControl)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "FF7400")
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.title = "Menu"
        
    }
        
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.wallViewController?.selectedGender = self.selectedGender!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if let user = self.currentUser {
                if let events = user.events {
                    return events.count
                }
            }
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("headerCell", forIndexPath: indexPath) as! HeaderCell
            
            if let id = self.currentUser?.parseUser.valueForKey("facebookId") as? NSString {
                let picURL: NSURL! = NSURL(string: "https://graph.facebook.com/\(id)/picture?width=600&height=600")
                cell.profilePicture.sd_setImageWithURL(picURL)
                cell.profilePicture.layer.masksToBounds = false
                cell.profilePicture.layer.shadowOpacity = 0.3
                cell.profilePicture.layer.shadowRadius = 1.0
                cell.profilePicture.layer.shadowOffset = CGSize(width: 2, height: 2)
    //            self.profilePicture.layer.cornerRadius = self.profilePicture.frame.width / 2
                if let age = self.currentUser?.getUserAge() as NSInteger! {
                    if let name = self.currentUser?.parseUser.valueForKey("name") as? String {
                            cell.nameLabel.text = "\(name) (\(age))"
                    }
                }
            }
            self.selectedGender = cell.genderSelect.selectedSegmentIndex
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as! EventsTableViewCell
            
            // Configure the cell
            let event = self.currentUser!.events?[indexPath.row] as! NSDictionary
            let eventId = event["id"] as! String
            let picURL: NSURL! = NSURL(string: "https://graph.facebook.com/\(eventId)/picture?width=600&height=600")
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
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
        
            self.wall = Wall()
            self.wall?.currentUser = self.currentUser
            let selectedEvent = self.currentUser?.events?[indexPath.row] as! NSDictionary
            let selectedEventId = selectedEvent["id"] as! String
            MBProgressHUD.showHUDAddedTo(self.wallViewController?.view, animated: true)
            
            self.closeLeft()
            self.currentUser?.parseUser.fetchInBackgroundWithBlock() { (object: PFObject?, error: NSError?) -> Void in
                self.wall?.getUsersToShow(selectedEventId, selectedGender: self.selectedGender!) { (userArray: [Person]) -> Void in
                    if userArray != [] {
                        self.wallUserArray = userArray as [Person]
                        self.wallViewController?.centerLabel.hidden = true
                        self.wallViewController?.wallUserArray = self.wallUserArray
                        self.wallViewController?.wallCollection.reloadData()
                    } else {
                        self.wallViewController?.centerLabel.text = "You've either (dis)liked everyone already or you're the only one going!"
                    }
                    self.wallViewController?.wallCollection.hidden = false
                    self.wallViewController?.selectedGender = self.selectedGender!
                    self.wallViewController?.selectedEvent = selectedEventId
                    self.wallViewController?.title = selectedEvent["name"] as? String
                    MBProgressHUD.hideHUDForView(self.wallViewController?.view, animated: true)
                    tableView.deselectRowAtIndexPath(indexPath, animated: true)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Menu"
        } else {
            return "Events"
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 280
        } else {
            return 100
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

    func refreshEventsTable() {
        self.currentUser?.getUserEvents() { () -> Void in
            self.eventsTable.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    @IBAction func genderSelectChange(sender: UISegmentedControl) {
        self.selectedGender = sender.selectedSegmentIndex
    }
    
}
