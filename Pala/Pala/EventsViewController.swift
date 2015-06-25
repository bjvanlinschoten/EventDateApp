//
//  EventsViewController.swift
//  Pala
//
//  Created by Boris van Linschoten on 07-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//

import UIKit


class EventsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Properties
    var wallViewController: WallCollectionViewController?
    var wallUserArray: [Person]?
    var wall: Wall?
    
    var currentUser: User?
    var refreshControl: UIRefreshControl!
   
    @IBOutlet var eventsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.wall = Wall()
        
        // Pull to refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refreshEventsTable", forControlEvents: UIControlEvents.ValueChanged)
        self.eventsTable.addSubview(self.refreshControl)
        
        // Navigation bar appearance
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "FF7400")
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.title = "Menu"
        
        // Get data for table and reload
        self.currentUser?.getUserEvents() { () -> Void in
            self.eventsTable.reloadData()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Refresh events
    func refreshEventsTable() {
        self.currentUser?.getUserEvents() { () -> Void in
            self.eventsTable.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    // Gender selecton
    @IBAction func genderSelectChange(sender: UISegmentedControl) {
        if self.wall!.selectedEvent != nil {
            MBProgressHUD.showHUDAddedTo(self.wallViewController?.view, animated: true)
            self.wall!.selectedGender = sender.selectedSegmentIndex
            self.wallViewController?.wall = self.wall!
            self.wallViewController?.appearsFromEventSelect()
            self.closeLeft()
        }
    }

    
    // MARK: TableView Delegate methods
    
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
            
            // Make header cell
            let cell = tableView.dequeueReusableCellWithIdentifier("headerCell", forIndexPath: indexPath) as! HeaderCell
            
            let id = self.currentUser?.parseUser["facebookId"] as! NSString
            
            // Set profile picture
            let picURL: NSURL! = NSURL(string: "https://graph.facebook.com/\(id)/picture?width=600&height=600")
            cell.profilePicture.sd_setImageWithURL(picURL)
            cell.profilePicture.layer.masksToBounds = false
            cell.profilePicture.layer.shadowOpacity = 0.3
            cell.profilePicture.layer.shadowRadius = 1.0
            cell.profilePicture.layer.shadowOffset = CGSize(width: 2, height: 2)
            
            // Set label with name and age
            if let age = self.currentUser?.getUserAge() as NSInteger! {
                cell.nameLabel.text = "\(self.currentUser?.name) (\(age))"
            }
            
            // Get initial gender value
            self.wall!.selectedGender = cell.genderSelect.selectedSegmentIndex
            
            // Cell not selectable
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as! EventsTableViewCell
            
            // Event for this cell
            let event = self.currentUser!.events?[indexPath.row] as! NSDictionary
            let eventId = event["id"] as! String
            
            // Set event picutre
            let picURL: NSURL! = NSURL(string: "https://graph.facebook.com/\(eventId)/picture?width=600&height=600")
            cell.eventImageView.sd_setImageWithURL(picURL)
            cell.eventImageView.layer.masksToBounds = true
            cell.eventImageView.layer.cornerRadius = 4
            
            // Set appearance of cell
            cell.eventView.layer.masksToBounds = false
            cell.eventView.layer.shadowOpacity = 0.3
            cell.eventView.layer.shadowRadius = 1.0
            cell.eventView.layer.shadowOffset = CGSize(width: 2, height: 2)
            
            // Set label with event title
            cell.eventLabel.text = event["name"] as? String
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            
            // Loading
            MBProgressHUD.showHUDAddedTo(self.wallViewController?.view, animated: true)

            
            // Selected event
            let selectedEvent = self.currentUser?.events?[indexPath.row] as! NSDictionary
            
            // Pass information to wall and go there
            self.wall!.currentUser = self.currentUser
            self.wall!.selectedEvent = selectedEvent
            self.wallViewController!.wall = self.wall
            self.wallViewController!.appearsFromEventSelect()
            self.closeLeft()
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
            return 75
        }
    }
}
