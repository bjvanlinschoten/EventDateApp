//
//  ChatsTableViewController.swift
//  Pala
//
//  Created by Boris van Linschoten on 15-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//

import UIKit

class ChatsTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {

    var currentUser: User?
    var otherUserChannel: PNChannel!
    var chatController: PrivateChatViewController!
    var matches: [Person]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        var pnConfiguration: PNConfiguration!
        pnConfiguration = PNConfiguration(publishKey: "pub-c-17afe8c1-9836-4e02-8ca8-629ae092c506", subscribeKey: "sub-c-54a03d8c-12a7-11e5-825b-02ee2ddab7fe", secretKey: "sec-c-YTk5ZmJlNGUtMWIyZi00NmU5LWEwOWYtMTc1MGE2ODA4MTNj")
        
        PubNub.setConfiguration(pnConfiguration)
        PNLogger.loggerEnabled(false)
        let userChannel: PNChannel = PNChannel.channelWithName(self.currentUser?.parseUser.objectId) as! PNChannel
        PubNub.connect()
        PubNub.subscribeOn([userChannel])
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.matches = []
        if let matches = self.currentUser!.parseUser.valueForKey("matches") as? NSArray {
            var query = PFUser.query()
            query?.whereKey("objectId", containedIn: matches as [AnyObject])
            query?.findObjectsInBackgroundWithBlock{(objects: [AnyObject]?, error: NSError?) -> Void in
            
                if let array = objects as? [PFUser] {
                    for item in array {
                        let person = Person(objectId: item.objectId!, facebookId: item.valueForKey("facebookId") as! String, name: item.valueForKey("name") as! String, birthday: item.valueForKey("birthday") as! String)
                        self.matches?.append(person)
                    }
                }
                
                self.tableView.reloadData()
                
            }
            
//            for person in matches {
//                var query = PFUser.query()
//                query?.getObjectInBackgroundWithId(otherUserObjectId, block: {(user: PFObject?, error: NSError?) -> Void in
//                    if let user = user as? PFUser {
//                        let cellText = user.valueForKey("name") as! NSString
//                        cell.textLabel?.text = cellText as String
//                    }
//                })
//            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if self.matches != nil {
            return self.matches!.count
        } else {
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatCell", forIndexPath: indexPath) as! UITableViewCell

        let person = matches![indexPath.row] as Person
        let cellText = person.name as String
        cell.textLabel?.text = cellText
        
//        if let matches = self.currentUser!.parseUser.valueForKey("matches") as? NSArray {
//            let otherUserObjectId = matches.objectAtIndex(indexPath.row) as! String
//            
//            var query = PFUser.query()
//            query?.getObjectInBackgroundWithId(otherUserObjectId, block: {(user: PFObject?, error: NSError?) -> Void in
//                if let user = user as? PFUser {
//                    let cellText = user.valueForKey("name") as! NSString
//                    cell.textLabel?.text = cellText as String
//                }
//            })
//        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.chatController = PrivateChatViewController()
        self.chatController.otherUser = self.matches![indexPath.row] as Person
        self.chatController.currentUser = self.currentUser
        
        self.navigationController?.pushViewController(self.chatController, animated: true)
    }
    
    
}
