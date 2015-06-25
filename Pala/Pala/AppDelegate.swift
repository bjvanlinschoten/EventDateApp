//
//  AppDelegate.swift
//  EventDateApp
//
//  Created by Boris van Linschoten on 02-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PNDelegate {

    var window: UIWindow?
    var chat: Chat?
    var isInChat: Bool?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Status bar white text
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        // Set-up Parse/FB
        Parse.setApplicationId("p6rBrBXuiTkbkB3S247eXHBpLismFku4KpL7h1v1", clientKey: "AdAbwID3eViabd3AME6xQv8IASrKN8vkeEGXcrsk")
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        // Set-up chat
        PubNub.setDelegate(self)
        self.chat = Chat()
        
        var pnConfiguration: PNConfiguration!
        pnConfiguration = PNConfiguration(publishKey: "pub-c-17afe8c1-9836-4e02-8ca8-629ae092c506", subscribeKey: "sub-c-54a03d8c-12a7-11e5-825b-02ee2ddab7fe", secretKey: "sec-c-YTk5ZmJlNGUtMWIyZi00NmU5LWEwOWYtMTc1MGE2ODA4MTNj")
        
        PubNub.setConfiguration(pnConfiguration)
        PNLogger.loggerEnabled(false)
        
        // Setup push for iOS8 and 7
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let types: UIUserNotificationType = (.Alert | .Badge | .Sound)
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotificationTypes(.Alert | .Badge | .Sound)
        }
        
        // Setup notification UI
        LNNotificationCenter.defaultCenter().registerApplicationWithIdentifier("pala_app_identifier", name: "Pala", icon: UIImage(named: "DeleteIcon.png"), defaultSettings: LNNotificationDefaultAppSettings)
        
        // Listen if app is in chat, then disable push
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "isUserInChat", name: "Chat", object: nil)
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }


    // MARK: PubNubDelegate
    
    func pubnubClient(client: PubNub!, didReceiveMessage message: PNMessage!) {
        
        // Get content from message
        let msgDict = message.message as! NSDictionary
        let msg = LGChatMessage(content: msgDict["message"] as! String, sentBy: .Opponent)
        let otherUserId = msgDict["senderId"] as! String
        
        // Save the received message
        self.chat!.saveMessageToUserDefaults(msg, otherUserId: otherUserId)
        
        // Post notification that message from this sender has been received
        NSNotificationCenter.defaultCenter().postNotificationName(msgDict["senderId"] as! String, object: self, userInfo: ["message": msg])
    }
    
    func pubnubClient(client: PubNub!, didSendMessage message: PNMessage!) {
        
        // Get message content
        let msgDict = message.message as! NSDictionary
        let msg = LGChatMessage(content: msgDict["message"] as! String, sentBy: .User)
        let otherUserId = message.channel.name
        
        // Save the sent message
        self.chat!.saveMessageToUserDefaults(msg, otherUserId: otherUserId)
    }
    
    func pubnubClient(client: PubNub!, didFailMessageSend message: PNMessage!, withError error: PNError!) {
        println(error)
    }
    
    // MARK: Push notification methods
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        // Register installation with Parse, to send PushNotif to
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.saveInBackgroundWithBlock { (succeeded, e) -> Void in
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("failed to register for remote notifications:  \(error)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        // If application is active, show notifications on top of screen. Else let Parse handle the push.
        if application.applicationState == UIApplicationState.Active {
            let aps = userInfo["aps"] as! NSDictionary
            let message = aps["alert"] as! String
            
            // make sure that the user doesn't get an alert when he is in chat with the person he received a msg from
            if message == "New match!" || self.isInChat != true {
                PFUser.currentUser()?.fetchInBackground()
                let notification: LNNotification = LNNotification(message: message)
                LNNotificationCenter.defaultCenter().presentNotification(notification, forApplicationIdentifier: "pala_app_identifier")
            }
        } else {
            PFPush.handlePush(userInfo)
        }
    }
    
    
    // Track if user is in cha
    func isUserInChat() {
        if self.isInChat == true {
            self.isInChat = false
        } else {
            self.isInChat = true
        }
    }
}
