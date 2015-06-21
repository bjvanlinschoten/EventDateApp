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
    var chatController: PrivateChatViewController!
    var matches: [Person]?
    var wallViewController: WallCollectionViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
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
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.slideMenuController()!.navigationController?.navigationBarHidden = true
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
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.chatController = PrivateChatViewController()
        self.chatController.otherUser = self.matches![indexPath.row] as Person
        self.chatController.currentUser = self.currentUser
        self.slideMenuController()?.navigationController?.pushViewController(self.chatController, animated: true)
    }
    
    
}
