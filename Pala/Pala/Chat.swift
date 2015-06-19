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
        if let data = defaults.objectForKey(otherUser!.objectId) as? NSData {
            oldMessages = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [LGChatMessage]
        }
        return oldMessages
    }
    
    func loadUnseenMessagesFromServer() {
        
        let currentUserChannel = PNChannel.channelWithName(currentUser?.parseUser.objectId) as! PNChannel
        let defaults = NSUserDefaults.standardUserDefaults()
        if let lastSaveDate = defaults.objectForKey("lastSaveDate") as? NSDate {
            let date = PNDate(date: lastSaveDate)
            PubNub.requestHistoryForChannel(currentUserChannel, from: PNDate(date: lastSaveDate), limit: 100, includingTimeToken: false) { (array: [AnyObject]!, channel: PNChannel!, startDate: PNDate!, endDate: PNDate!, error: NSError!) -> Void in
                if let array = array as? [PNMessage] {
                    for msg in array {
                        let msgDict = msg.message as! NSDictionary
                        let lgMsg = LGChatMessage(content: msgDict["message"] as! String, sentBy: .Opponent, timeStamp: nil)
                        if let data = defaults.objectForKey(msgDict["senderId"] as! String) as? NSData {
                            var oldMessages = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [LGChatMessage]
                            oldMessages.append(lgMsg)
                            let saveObject = oldMessages
                            let saveObjectData = NSKeyedArchiver.archivedDataWithRootObject(saveObject)
                            defaults.setObject(saveObjectData, forKey: msgDict["senderId"] as! String)
                            defaults.setObject(NSDate(), forKey: "lastSaveData")
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
                            if let data = defaults.objectForKey(msgDict["senderId"] as! String) as? NSData {
                                oldMessages = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [LGChatMessage]
                            }
                            oldMessages.append(lgMsg)
                            let saveObject = oldMessages
                            let saveObjectData = NSKeyedArchiver.archivedDataWithRootObject(saveObject)
                            defaults.setObject(saveObjectData, forKey: msgDict["senderId"] as! String)
                            defaults.setObject(NSDate(), forKey: "lastSaveData")
                        }
                    }
                }
            }
        }
        
//        let date = PNDate(date: lastSaveDate)
//        PubNub.requestHistoryForChannel(currentUserChannel, from: PNDate(date: lastSaveDate), limit: 100, includingTimeToken: false) { (array: [AnyObject]!, channel: PNChannel!, startDate: PNDate!, endDate: PNDate!, error: NSError!) -> Void in
//            if let msgArray = array as? [PNMessage] {
//                for msg in msgArray {
//                    let msgDict = msg.message as! NSDictionary
//                    let lgMsg = LGChatMessage(content: msgDict["message"] as! String, sentBy: .Opponent)
//                    oldMessages.append(lgMsg)
//                }
//                completion(oldMessageArray: oldMessages)
//            } else {
//                completion(oldMessageArray: oldMessages)
//            }
//        }
    }
    
    func sendMessage(message: LGChatMessage) {
        if message.sentBy == .User {
            PubNub.sendMessage(["message": message.content, "senderId": currentUser!.parseUser.objectId!], toChannel: self.otherUserChannel, storeInHistory: true)            
        }
        
    }
    
    func saveMessageToUserDefaults(msg: LGChatMessage, otherUserId: String){
        var oldMessages: [LGChatMessage] = []
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let data = defaults.objectForKey(otherUserId) as? NSData {
            oldMessages = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [LGChatMessage]
        }
        oldMessages.append(msg)
        let saveObject = oldMessages
        let saveObjectData = NSKeyedArchiver.archivedDataWithRootObject(saveObject)
        defaults.setObject(saveObjectData, forKey: otherUserId)
        defaults.setObject(NSDate(), forKey: "lastSaveData")
    }
}