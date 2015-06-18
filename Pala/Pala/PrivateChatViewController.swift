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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.otherUserChannel = PNChannel.channelWithName(self.otherUser!.objectId) as? PNChannel
        self.title = self.otherUser!.name
        self.messages = []
        self.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
