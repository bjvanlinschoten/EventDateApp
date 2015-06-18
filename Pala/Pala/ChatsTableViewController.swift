//
//  ChatsTableViewController.swift
//  Pala
//
//  Created by Boris van Linschoten on 15-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//

import UIKit

class ChatsTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, LGChatControllerDelegate, PNDelegate {

    var currentUser: User?
    var otherUserChannel: PNChannel!
    var chatController: LGChatController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        PubNub.setDelegate(self)
        
        var pnConfiguration: PNConfiguration!
        pnConfiguration = PNConfiguration(publishKey: "pub-c-17afe8c1-9836-4e02-8ca8-629ae092c506", subscribeKey: "sub-c-54a03d8c-12a7-11e5-825b-02ee2ddab7fe", secretKey: "sec-c-YTk5ZmJlNGUtMWIyZi00NmU5LWEwOWYtMTc1MGE2ODA4MTNj")
        
        PubNub.setConfiguration(pnConfiguration)
        PNLogger.loggerEnabled(false)
        let userChannel: PNChannel = PNChannel.channelWithName(self.currentUser?.parseUser.objectId) as! PNChannel
        PubNub.connect()
        PubNub.subscribeOn([userChannel])
        
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
        if let matches = self.currentUser?.parseUser.valueForKey("matches") as? NSArray {
            return matches.count
        } else {
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatCell", forIndexPath: indexPath) as! UITableViewCell

        if let matches = self.currentUser!.parseUser.valueForKey("matches") as? NSArray {
            let otherUserObjectId = matches.objectAtIndex(indexPath.row) as! String
            
            var query = PFUser.query()
            query?.getObjectInBackgroundWithId(otherUserObjectId, block: {(user: PFObject?, error: NSError?) -> Void in
                if let user = user as? PFUser {
                    let cellText = user.valueForKey("name") as! NSString
                    cell.textLabel?.text = cellText as String
                }
            })
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.chatController = LGChatController()
        self.chatController.messages = []
        let matches = self.currentUser!.parseUser.valueForKey("matches") as! NSArray
        let otherUserObjectId = matches.objectAtIndex(indexPath.row) as! String
        let currentUserObjectId = self.currentUser!.parseUser.objectId! as String
        otherUserChannel = PNChannel.channelWithName(otherUserObjectId) as! PNChannel
        self.chatController.title = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text
        self.chatController.delegate = self
        self.navigationController?.pushViewController(self.chatController, animated: true)
    }
    
    
    // MARK: LGChatControllerDelegate
    
    func chatController(chatController: LGChatController, didAddNewMessage message: LGChatMessage) {
        if message.sentBy == .User {
            PubNub.sendMessage(message.content, toChannel: self.otherUserChannel)
        }
    }
    
    func shouldChatController(chatController: LGChatController, addMessage message: LGChatMessage) -> Bool {
        /*
        Use this space to prevent sending a message, or to alter a message.  For example, you might want to hold a message until its successfully uploaded to a server.
        */
        return true
    }
    
    // MARK: PubNubDelegate
    
    func pubnubClient(client: PubNub!, didReceiveMessage message: PNMessage!) {
        println("received: \(message)")
        let message = LGChatMessage(content: "MessageReceived", sentBy: .Opponent, timeStamp: nil)
        self.chatController.addNewMessage(message)
    }

    func pubnubClient(client: PubNub!, didSendMessage message: PNMessage!) {
        println("sent: \(message)")
    }
    
    func pubnubClient(client: PubNub!, didFailMessageSend message: PNMessage!, withError error: PNError!) {
        println(error)
    }
}
