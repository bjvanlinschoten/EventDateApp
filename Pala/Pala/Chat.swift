//
//  Chat.swift
//  Pala
//
//  Created by Boris van Linschoten on 19-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//


class Chat: NSObject {

    // Properties
    var currentUser: User?
    var otherUser: Person?
    var otherUserChannel: PNChannel?
    var chat: Chat?
    
    
    // Function to get matches
    func getMatches(completion: ((array: [Person]?) -> Void)!) {
        var matchesArray: [Person] = []
        if let matches = self.currentUser?.parseUser["matches"] as? NSArray {
            
            // Query all users contained in user's matches array
            var query = PFUser.query()
            query?.whereKey("objectId", containedIn: matches as [AnyObject])
            query?.findObjectsInBackgroundWithBlock{(objects: [AnyObject]?, error: NSError?) -> Void in
                if let array = objects as? [PFUser] {
                    for item in array {
                        
                        // Create person object for the other user to minimize queries
                        let person = Person(objectId: item.objectId!, facebookId: item["facebookId"] as! String, name: item["name"] as! String, birthday: item["birthday"] as! String)
                        
                        // Find earliest common event between the users
                        let otherUserEvents = item["events"] as! NSArray
                        for event in self.currentUser!.parseUser["events"] as! NSArray {
                            if otherUserEvents.containsObject(event["id"] as! String) {
                                person.commonEvent = event["name"] as? String
                                break
                            }
                        }
                        matchesArray.append(person)
                    }
                }
                completion(array: matchesArray)
            }
        }
    }
    
    // Get old messages of the chat with this user out of NSUserDefaults
    func getOldMessages() -> [LGChatMessage] {
        var oldMessages: [LGChatMessage] = []
        let defaults = NSUserDefaults.standardUserDefaults()
        if let data = defaults.objectForKey(PFUser.currentUser()!.objectId!) as? NSData {
            var dataDict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSDictionary
            if dataDict[self.otherUser!.objectId] != nil {
                oldMessages = dataDict[self.otherUser!.objectId] as! [LGChatMessage]
            }
        }
        return oldMessages
    }
    
    // Load all the unseen messages from the PubNub server
    func loadUnseenMessagesFromServer() {
        let currentUserChannel = PNChannel.channelWithName(currentUser?.parseUser.objectId) as! PNChannel
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // If there was an earlier save, get all messages since last save. Else get full message history.
        if let lastSaveDate = defaults.objectForKey("lastSaveDate") as? NSDate {
            let date = PNDate(date: lastSaveDate)
            PubNub.requestHistoryForChannel(currentUserChannel, from: date, to: PNDate(date: NSDate()), limit: 100, includingTimeToken: true) { (array: [AnyObject]!, channel: PNChannel!, startDate: PNDate!, endDate: PNDate!, error: NSError!) -> Void in
                if let array = array as? [PNMessage] {
                    
                    // For all PNMessages, make LGChatMessages and save to NSUserdefaults
                    for msg in array {
                        let msgDict = msg.message as! NSDictionary
                        let lgMsg = LGChatMessage(content: msgDict["message"] as! String, sentBy: .Opponent, timeStamp: nil)
                        if let data = defaults.objectForKey(PFUser.currentUser()!.objectId!) as? NSData {
                            var dataDict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSMutableDictionary
                            var oldMessages: [LGChatMessage] = []
                            if dataDict[msgDict["senderId"] as! String] != nil {
                                oldMessages = dataDict[msgDict["senderId"] as! String] as! [LGChatMessage]
                            }
                            oldMessages.append(lgMsg)
                            dataDict.setValue(oldMessages, forKey: msgDict["senderId"] as! String)
                            let saveObject = dataDict
                            let saveObjectData = NSKeyedArchiver.archivedDataWithRootObject(saveObject)
                            defaults.setObject(saveObjectData, forKey: PFUser.currentUser()!.objectId!)
                            defaults.setObject(NSDate(), forKey: "lastSaveDate")
                        }
                    }
                }
            }
        } else {
            PubNub.requestFullHistoryForChannel(currentUserChannel, includingTimeToken: false) { (array: [AnyObject]!, channel: PNChannel!, startDate: PNDate!, endDate: PNDate!, error: NSError!) -> Void in
                if error != nil {
                    println(error)
                } else {
                    if let array = array as? [PNMessage] {
                        
                        // For all PNMessages, make LGChatMessages and send to NSUserdefaults
                        for msg in array {
                            let msgDict = msg.message as! NSDictionary
                            let lgMsg = LGChatMessage(content: msgDict["message"] as! String, sentBy: .Opponent, timeStamp: nil)
                            var oldMessages: [LGChatMessage] = []
                            var dataDict: NSMutableDictionary = NSMutableDictionary()
                            if let data = defaults.objectForKey(PFUser.currentUser()!.objectId!) as? NSData {
                                dataDict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSMutableDictionary
                                if dataDict[msgDict["senderId"] as! String] != nil {
                                    oldMessages = dataDict[msgDict["senderId"] as! String] as! [LGChatMessage]
                                }
                            }
                            oldMessages.append(lgMsg)
                            dataDict.setObject(oldMessages, forKey: msgDict["senderId"] as! String)
                            let saveObject = dataDict
                            let saveObjectData = NSKeyedArchiver.archivedDataWithRootObject(saveObject)
                            defaults.setObject(saveObjectData, forKey: PFUser.currentUser()!.objectId!)
                            defaults.setObject(NSDate(), forKey: "lastSaveDate")
                        }
                    }
                }
            }
        }
    }
    
    func sendMessage(message: LGChatMessage) {
        if message.sentBy == .User {
            
            // Send message through PubNub
            PubNub.sendMessage(["message": message.content, "senderId": currentUser!.parseUser.objectId!], toChannel: self.otherUserChannel, storeInHistory: true)
            
            // Send push to other user
            PFCloud.callFunctionInBackground("chatPush", withParameters: ["otherUserId" : self.otherUser!.objectId as String, "currentUserName" : self.currentUser?.parseUser["name"] as! String, "messageContent" : message.content]) { (response: AnyObject? , error: NSError?) -> Void in
                if error == nil {
                    
                } else {
                    println(error)
                }
            }
        }
    }
    
    
    // Save message to user defaults
    func saveMessageToUserDefaults(msg: LGChatMessage, otherUserId: String){
        
        // Get and unarchive old messages from userdefaults
        var oldMessages: [LGChatMessage] = []
        let defaults = NSUserDefaults.standardUserDefaults()
        var dataDict: NSMutableDictionary = NSMutableDictionary()
        if let data = defaults.objectForKey(PFUser.currentUser()!.objectId!) as? NSData {
            dataDict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSMutableDictionary
            if dataDict[otherUserId] != nil {
                oldMessages = dataDict[otherUserId] as! [LGChatMessage]
            }
        }
        
        // Add new sent or received message to user defaults
        oldMessages.append(msg)
        dataDict.setObject(oldMessages, forKey: otherUserId)
        let saveObject = dataDict
        let saveObjectData = NSKeyedArchiver.archivedDataWithRootObject(saveObject)
        defaults.setObject(saveObjectData, forKey: PFUser.currentUser()!.objectId!)
        defaults.setObject(NSDate(), forKey: "lastSaveDate")
    }
}