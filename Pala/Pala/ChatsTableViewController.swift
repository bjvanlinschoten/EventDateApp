//
//  ChatsTableViewController.swift
//  Pala
//
//  Created by Boris van Linschoten on 15-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//

import UIKit

class ChatsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var currentUser: User?
    var chatController: PrivateChatViewController!
    var matches: [Person]?
    var wallViewController: WallCollectionViewController?
    
    @IBOutlet weak var chatsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "FF7400")
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.title = "Chats"
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
//        let chat = Chat()
//        chat.getMatches() { (matchesArray: [Person]?) -> Void in
//            self.matches = matchesArray
//            self.chatsTable.reloadData()
//        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "FF7400")
        let chat = Chat()
        chat.getMatches() { (matchesArray: [Person]?) -> Void in
            if matchesArray != nil {
                self.matches = matchesArray
                self.chatsTable.reloadData()
            }
        }
        self.slideMenuController()!.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if self.matches != nil {
            return self.matches!.count
        } else {
            return 0
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatCell", forIndexPath: indexPath) as! ChatsTableViewCell

        let person = matches![indexPath.row] as Person
        cell.nameLabel.text = "\(person.name) (\(person.getPersonAge()))"
        let picURL = NSURL(string: "https://graph.facebook.com/\(person.facebookId)/picture?width=54&height=54")
        cell.profilePicture!.sd_setImageWithURL(picURL)
        cell.profilePicture!.layer.masksToBounds = true
        cell.profilePicture!.layer.cornerRadius = 26
        
        var query = PFUser.query()
        query?.getObjectInBackgroundWithId(person.objectId) { (object: PFObject?, error: NSError?) -> Void in
            if let user = object as? PFUser {
                let otherUserEvents = user["events"] as! NSArray
                for event in self.currentUser!.events! {
                    if otherUserEvents.containsObject(event["id"] as! String) {
                        cell.commonEventsLabel.text = event["name"] as? String
                        break
                    }
                }
            }
        }
        
        
        cell.cellView.layer.masksToBounds = false
        cell.cellView.layer.shadowOpacity = 0.3
        cell.cellView.layer.shadowRadius = 1.0
        cell.cellView.layer.shadowOffset = CGSize(width: 2, height: 2)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.chatController = PrivateChatViewController()
        self.chatController.otherUser = self.matches![indexPath.row] as Person
        self.chatController.currentUser = self.currentUser
        self.slideMenuController()?.navigationController?.pushViewController(self.chatController, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
}
