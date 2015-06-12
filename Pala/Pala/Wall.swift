//
//  Wall.swift
//  Pala
//
//  Created by Boris van Linschoten on 11-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//

import UIKit

class Wall: NSObject {
   
    var currentUser: User?
    
    func getUsersAtEvent(completion: ((wallUserArray: [PFUser]) -> Void)!) {
        if let userEvent = self.currentUser?.parseUser.valueForKey("currentEvent") as? NSString {
            var array: [PFUser] = []
            var query = PFUser.query()
            query?.whereKey("currentEvent", equalTo: userEvent)
            query?.findObjectsInBackgroundWithBlock{(objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil{
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            if let user = object as? PFUser {
                                let currentUserId = self.currentUser?.parseUser.valueForKey("facebookId") as? NSString
                                let otherUserId = user.valueForKey("facebookId") as? NSString
                                if otherUserId != currentUserId {
                                    array.append(user)
                                }
                            }
                        }
                    }
                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                }
                completion(wallUserArray: array)
            }
        }
    }
}
