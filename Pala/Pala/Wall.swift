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
    
    func getUsersToShow(completion: ((wallUserArray: [PFUser]) -> Void)!) {
        if let userEvent = self.currentUser?.parseUser.valueForKey("currentEvent") as? NSString {
            
            let currentUserObjectId = self.currentUser?.parseUser.objectId!
            
            let userGender = self.currentUser?.parseUser.valueForKey("gender") as! NSString
            var gender: String
            if userGender == "male" {
                gender = "female"
            } else {
                gender = "male"
            }
            
            
            var query = PFUser.query()
            query?.whereKey("gender", equalTo: gender)
            query?.whereKey("currentEvent", equalTo: userEvent)
            query?.whereKey("matches", notEqualTo: currentUserObjectId!)
            
            let likedUsers = self.currentUser?.parseUser.valueForKey("likedUsers") as? NSMutableArray
            let dislikedUsers = self.currentUser?.parseUser.valueForKey("dislikedUsers") as? NSArray
            if likedUsers != nil && dislikedUsers != nil {
                likedUsers!.addObjectsFromArray(dislikedUsers! as [AnyObject])
                query?.whereKey("objectId", notContainedIn: likedUsers! as [AnyObject])
            } else if likedUsers != nil {
                query?.whereKey("objectId", notContainedIn: likedUsers! as [AnyObject])
            } else if dislikedUsers != nil {
                query?.whereKey("objectId", notContainedIn: dislikedUsers! as [AnyObject])
            }
            
            query?.findObjectsInBackgroundWithBlock{(objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    if let array = objects as? [PFUser] {
                        completion(wallUserArray: array)
                    }
                }
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
                        self.currentUser?.parseUser.addUniqueObject(otherUserObjectId, forKey: "matches")
                        PFCloud.callFunctionInBackground("match", withParameters: ["otherUserId": otherUserObjectId, "currentUserId": currentUserObjectId]) {(response: AnyObject?, error: NSError?) -> Void in
                            if error == nil {
                                
                            } else {
                                println(error)
                            }
                        }
                    } else {
                        self.currentUser?.parseUser.addUniqueObject(otherUserObjectId, forKey: "likedUsers")
                        liked(result: false)
                    }
                } else {
                    self.currentUser?.parseUser.addUniqueObject(otherUserObjectId, forKey: "likedUsers")
                    liked(result: false)
                }
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
