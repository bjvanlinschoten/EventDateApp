//
//  ChatViewController.swift
//  Pala
//
//  Created by Boris van Linschoten on 18-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//

import UIKit

class PrivateChatViewController: LGChatController, LGChatControllerDelegate {
    
    var currentUser: User?
    var otherUser: Person?
    var otherUserChannel: PNChannel?
    var chat: Chat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        
        // Channel of other user
        self.otherUserChannel = PNChannel.channelWithName(self.otherUser!.objectId) as? PNChannel
        
        // Init chat object
        self.chat = Chat()
        self.chat.currentUser = self.currentUser
        self.chat.otherUser = self.otherUser
        self.chat.otherUserChannel = self.otherUserChannel
        self.navigationController?.navigationBarHidden = false
        
        self.messages = self.chat.getOldMessages()
        
        // Set other user profile picture
        let picURL: NSURL! = NSURL(string: "https://graph.facebook.com/\(otherUser!.facebookId)/picture?width=100&height=100")
        let downloader = SDWebImageManager()
        downloader.downloadImageWithURL(picURL, options: nil, progress: nil) { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, finished: Bool, url: NSURL!) -> Void in
            if ((image) != nil) {
                self.opponentImage = image
            }
        }
        
        // Listen for new messages
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addMessageWithNotification:", name: otherUser!.objectId, object: nil)
        
        self.title = self.otherUser!.name
        self.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
//        self.chat.saveMessages(self.messages)
    }
    
    func addMessageWithNotification(notification: NSNotification) {
        let message = notification.userInfo!["message"] as! LGChatMessage
        self.addNewMessage(message)
    }
    
    
    // MARK: LGChatControllerDelegate
    
    func chatController(chatController: LGChatController, didAddNewMessage message: LGChatMessage) {
        self.chat.sendMessage(message)
    }
    
    func shouldChatController(chatController: LGChatController, addMessage message: LGChatMessage) -> Bool {
        /*
        Use this space to prevent sending a message, or to alter a message.  For example, you might want to hold a message until its successfully uploaded to a server.
        */
        return true
    }
    
    

}
