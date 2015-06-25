//
//  User.swift
//  Pala
//
//  Created by Boris van Linschoten on 05-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//

import UIKit

class User: NSObject {
    
    // Properties
    let parseUser: PFUser
    var events: NSArray?
    
    init (parseUser: PFUser) {
        self.parseUser = parseUser
        super.init()
    }
    
    // Get age from user's birthdate
    func getUserAge() -> NSInteger {
        if let birthdayString =  self.parseUser["birthday"] as? String {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let birthday = dateFormatter.dateFromString(birthdayString)
            var calendar: NSCalendar = NSCalendar.currentCalendar()
            let ageComponents = calendar.components(NSCalendarUnit.CalendarUnitYear, fromDate: birthday!, toDate: NSDate(), options: nil)
            return ageComponents.year
        }
        return 0 as NSInteger
    }
    
    
    // Populate the new PFUser with their facebook data
    func populateNewUserWithFBData(completion: (() -> Void)!) {
        let profileRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        profileRequest.startWithCompletionHandler{(connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            if let resultDict = result as? NSDictionary {
                self.parseUser.setValue(resultDict["id"], forKey: "facebookId")
                self.parseUser.setValue(resultDict["first_name"], forKey: "name")
                self.parseUser.setValue(resultDict["gender"], forKey:"gender")
                self.parseUser.setValue(resultDict["birthday"], forKey: "birthday")
                self.parseUser.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        // The object has been saved.
                    } else {
                        // There was a problem, check error.description
                    }
                }
                completion()
            }
        }
    }
    
    // Query the events the user is attending to from Facebook
    func getUserEvents(completion: (() -> Void)!) {
        let eventsRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath:"/me/events" , parameters: nil, HTTPMethod: "GET")
        eventsRequest.startWithCompletionHandler{(connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            if let result = result as? NSDictionary {
                if let events = result["data"] as? NSMutableArray {
                    
                    // sort the events on date
                    let dateDescriptor = NSSortDescriptor(key: "start_time", ascending: true)
                    let sortDescriptors = NSArray(object: dateDescriptor)
                    let sortedEventArray = events.sortedArrayUsingDescriptors(sortDescriptors as [AnyObject]) as NSArray
                    var eventIdArray: NSMutableArray = []
                    
                    self.events = sortedEventArray
                    
                    // Save events to PArse
                    for event in sortedEventArray {
                        let event = event as! NSDictionary
                        eventIdArray.addObject(event["id"] as! String)
                        self.parseUser.saveInBackground()
                    }
                    self.parseUser.setObject(eventIdArray as [AnyObject], forKey: "events")
                }
            }
            completion()
        }

    }
    
    // Log out the user
    func logout() {
        let logMeOut: FBSDKLoginManager = FBSDKLoginManager()
        logMeOut.logOut()
        PFUser.logOut()
    }
    
}
