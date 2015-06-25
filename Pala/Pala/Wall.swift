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
    
    func getUsersToShow(selectedEventId: String, selectedGender: NSInteger, completion: ((wallUserArray: [Person]) -> Void)!) {
        
            
        let currentUserObjectId = self.currentUser?.parseUser.objectId!
        
        
        var gender: String
        if selectedGender == 1 {
            gender = "female"
        } else {
            gender = "male"
        }
        
        
        var query = PFUser.query()
        query?.whereKey("gender", equalTo: gender)
        query?.whereKey("events", equalTo: selectedEventId)
        query?.whereKey("matches", notEqualTo: currentUserObjectId!)
        query?.whereKey("objectId", notEqualTo: currentUserObjectId!)
        
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
                    var wallUsersArray: [Person] = []
                    for person in array {
                        let person = Person(objectId: person.objectId!, facebookId: person.valueForKey("facebookId") as! String, name: person.valueForKey("name") as! String, birthday: person.valueForKey("birthday") as! String)
                        wallUsersArray.append(person)
                    }
                    completion(wallUserArray: wallUsersArray)
                }
            }
        }
        
    }
    
    func likeUser (otherPerson: Person, liked: ((result: Bool) -> Void)!) {
        
        var query = PFUser.query()
        
        query?.getObjectInBackgroundWithId(otherPerson.objectId) {(object: PFObject?, error: NSError?) -> Void in
            if let otherUser = object as? PFUser {
                if let otherUserLikedUsers = otherUser.valueForKey("likedUsers") as? NSArray, currentUserObjectId = self.currentUser?.parseUser.objectId {
                    if otherUserLikedUsers.containsObject(currentUserObjectId) {
                        liked(result: true)
                        self.currentUser?.parseUser.addUniqueObject(otherPerson.objectId, forKey: "matches")
                        PFCloud.callFunctionInBackground("match", withParameters: ["otherUserId": otherPerson.objectId, "currentUserId": currentUserObjectId]) {(response: AnyObject?, error: NSError?) -> Void in
                            if error == nil {
                                
                            } else {
                                println(error)
                            }
                        }
                    } else {
                        self.currentUser?.parseUser.addUniqueObject(otherUser.objectId!, forKey: "likedUsers")
                        liked(result: false)
                    }
                } else {
                    self.currentUser?.parseUser.addUniqueObject(otherUser.objectId!, forKey: "likedUsers")
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
