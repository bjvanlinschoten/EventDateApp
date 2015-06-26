//
//  Wall.swift
//  Pala
//
//  Created by Boris van Linschoten on 11-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//

import UIKit

class Wall: NSObject {
    
    // Properties
    var currentUser: User?
    var selectedEvent: NSDictionary!
    var selectedGender: NSInteger?
    
    
    // Get the users to be shown on the wall
    func getUsersToShow(selectedEventId: String, selectedGender: NSInteger, completion: ((wallUserArray: [Person]) -> Void)!) {
        self.currentUser?.parseUser.fetchInBackgroundWithBlock({ (object: PFObject?, error: NSError?) -> Void in
            let currentUserObjectId = self.currentUser?.parseUser.objectId!
            
            // Get the gender preference of the user as string
            var gender: String
            if selectedGender == 1 {
                gender = "female"
            } else {
                gender = "male"
            }
            
            // specify the query
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
            
            // Query users asynchronously
            query?.findObjectsInBackgroundWithBlock{(objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    if let array = objects as? [PFUser] {
                        var wallUsersArray: [Person] = []
                        for person in array {
                            
                            // Make person object for the user, to store locally to minimize queries
                            let person = Person(objectId: person.objectId!, facebookId: person["facebookId"] as! String, name: person["name"] as! String, birthday: person["birthday"] as! String)
                            wallUsersArray.append(person)
                        }
                        completion(wallUserArray: wallUsersArray)
                    }
                }
            }
        })
    }
    
    
    // Like a user and see if (s)he liked you
    func likeUser (otherPerson: Person, liked: ((result: Bool) -> Void)!) {
        
        // Query the other user
        var query = PFUser.query()
        query?.getObjectInBackgroundWithId(otherPerson.objectId) {(object: PFObject?, error: NSError?) -> Void in
            if let otherUser = object as? PFUser {
                if let otherUserLikedUsers = otherUser["likedUsers"] as? NSArray, currentUserObjectId = self.currentUser?.parseUser.objectId {
                    
                    // If there is a match add users to eachother's Matches array else only to own LikedUsers array
                    if otherUserLikedUsers.containsObject(currentUserObjectId) {
                        liked(result: true)
                        self.currentUser?.parseUser.addUniqueObject(otherPerson.objectId, forKey: "matches")
                        
                        // Cloud function that edits the other PFUser and sends a push to the other user
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
                
                // Save user to parse
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
    
    
    // Add user to DislikedUsers array, to now show up in wall
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
