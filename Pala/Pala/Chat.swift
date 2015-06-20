//
//  Chat.swift
//  Pala
//
//  Created by Boris van Linschoten on 19-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//


class Chat: NSObject {

    var currentUser: User?
    var otherUser: Person?
    var otherUserChannel: PNChannel?
    var chat: Chat?

    
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
    
    func loadUnseenMessagesFromServer() {
        
        let currentUserChannel = PNChannel.channelWithName(currentUser?.parseUser.objectId) as! PNChannel
        let defaults = NSUserDefaults.standardUserDefaults()
        if let lastSaveDate = defaults.objectForKey("lastSaveDate") as? NSDate {
            let date = PNDate(date: lastSaveDate)
            PubNub.requestHistoryForChannel(currentUserChannel, from: date, to: PNDate(date: NSDate()), limit: 100, includingTimeToken: true) { (array: [AnyObject]!, channel: PNChannel!, startDate: PNDate!, endDate: PNDate!, error: NSError!) -> Void in
                println("PNStartDate: \(startDate)")
                println("PNEndDate: \(endDate)")
                if let array = array as? [PNMessage] {
                    for msg in array {
                        let msgDict = msg.message as! NSDictionary
                        let lgMsg = LGChatMessage(content: msgDict["message"] as! String, sentBy: .Opponent, timeStamp: nil)
                        if let data = defaults.objectForKey(self.currentUser!.parseUser.objectId!) as? NSData {
                            var dataDict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSMutableDictionary
                            var oldMessages: [LGChatMessage] = []
                            if dataDict[msgDict["senderId"] as! String] != nil {
                                oldMessages = dataDict[msgDict["senderId"] as! String] as! [LGChatMessage]
                            }
                            oldMessages.append(lgMsg)
                            dataDict.setValue(oldMessages, forKey: msgDict["senderId"] as! String)
                            let saveObject = dataDict
                            let saveObjectData = NSKeyedArchiver.archivedDataWithRootObject(saveObject)
                            defaults.setObject(saveObjectData, forKey: self.currentUser!.parseUser.objectId!)
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
                        for msg in array {
                            let msgDict = msg.message as! NSDictionary
                            let lgMsg = LGChatMessage(content: msgDict["message"] as! String, sentBy: .Opponent, timeStamp: nil)
                            var oldMessages: [LGChatMessage] = []
                            var dataDict: NSMutableDictionary = NSMutableDictionary()
                            if let data = defaults.objectForKey(self.currentUser!.parseUser.objectId!) as? NSData {
                                dataDict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSMutableDictionary
                                if dataDict[msgDict["senderId"] as! String] != nil {
                                    oldMessages = dataDict[msgDict["senderId"] as! String] as! [LGChatMessage]
                                }
                            }
                            oldMessages.append(lgMsg)
                            dataDict.setObject(oldMessages, forKey: msgDict["senderId"] as! String)
                            let saveObject = dataDict
                            let saveObjectData = NSKeyedArchiver.archivedDataWithRootObject(saveObject)
                            defaults.setObject(saveObjectData, forKey: self.currentUser!.parseUser.objectId!)
                            defaults.setObject(NSDate(), forKey: "lastSaveDate")
                        }
                    }
                }
            }
        }
    }
    
    func sendMessage(message: LGChatMessage) {
        if message.sentBy == .User {
            PubNub.sendMessage(["message": message.content, "senderId": currentUser!.parseUser.objectId!], toChannel: self.otherUserChannel, storeInHistory: true)            
        }
        
    }
    
    func saveMessageToUserDefaults(msg: LGChatMessage, otherUserId: String){
        var oldMessages: [LGChatMessage] = []
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var dataDict: NSMutableDictionary = NSMutableDictionary()
        if let data = defaults.objectForKey(PFUser.currentUser()!.objectId!) as? NSData {
            dataDict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSMutableDictionary
            if dataDict[otherUserId] != nil {
                oldMessages = dataDict[otherUserId] as! [LGChatMessage]
            }
        }
        oldMessages.append(msg)
        dataDict.setObject(oldMessages, forKey: otherUserId)
        let saveObject = dataDict
        let saveObjectData = NSKeyedArchiver.archivedDataWithRootObject(saveObject)
        defaults.setObject(saveObjectData, forKey: PFUser.currentUser()!.objectId!)
        defaults.setObject(NSDate(), forKey: "lastSaveDate")
    }
}