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
            let likedUsers = self.currentUser?.parseUser.valueForKey("likedUsers") as? NSArray
            let dislikedUsers = self.currentUser?.parseUser.valueForKey("dislikedUsers") as? NSArray
            var query = PFUser.query()
            query?.whereKey("currentEvent", equalTo: userEvent)
            query?.findObjectsInBackgroundWithBlock{(objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil{
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            if let user = object as? PFUser {
                                let currentUserObjectId = self.currentUser?.parseUser.objectId!
                                let otherUserObjectId = user.objectId!
                                if otherUserObjectId != currentUserObjectId {
                                    if likedUsers != nil && dislikedUsers != nil {
                                        if !likedUsers!.containsObject(otherUserObjectId) && !dislikedUsers!.containsObject(otherUserObjectId) {
                                            array.append(user)
                                        }
                                    } else if likedUsers != nil {
                                        if !likedUsers!.containsObject(otherUserObjectId) {
                                            array.append(user)
                                        }
                                    } else if dislikedUsers != nil {
                                        if !dislikedUsers!.containsObject(otherUserObjectId) {
                                            array.append(user)
                                        }
                                    } else {
                                        array.append(user)
                                    }
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
    
    
    
    func likeUser (otherUserObjectId: String, liked: ((result: Bool) -> Void)!) {
        
        var query = PFUser.query()
        
        query?.getObjectInBackgroundWithId(otherUserObjectId) {(object: PFObject?, error: NSError?) -> Void in
            if let otherUser = object as? PFUser {
                if let otherUserLikedUsers = otherUser.valueForKey("likedUsers") as? NSArray, currentUserObjectId = self.currentUser?.parseUser.objectId {
                    if otherUserLikedUsers.containsObject(currentUserObjectId) {
                        liked(result: true)
                    } else {
                        liked(result: false)
                    }
                } else {
                    liked(result: false)
                }
                
                self.currentUser?.parseUser.addUniqueObject(otherUserObjectId, forKey: "likedUsers")
                self.currentUser?.parseUser.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        // The object has been saved.
                    } else {
                        // There was a problem, check error.description
                    }
                }
            }
        }
    }
    
    func dislikeUser (otherUserObjectId: String) {
        self.currentUser?.parseUser.addUniqueObject(otherUserObjectId, forKey: "dislikedUsers")
        self.currentUser?.parseUser.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
            } else {
                // There was a problem, check error.description
            }
        }
    }
}
