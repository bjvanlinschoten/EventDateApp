//
//  User.swift
//  Pala
//
//  Created by Boris van Linschoten on 05-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//

import UIKit

class User: NSObject {
    
    let parseUser: PFUser
    var facebookId: NSString
    var events: NSMutableArray?
    
    init (parseUser: PFUser) {
        self.parseUser = parseUser
        self.facebookId = ""
        super.init()
    }
    
    func saveUserToParse() {
        self.parseUser.saveInBackgroundWithBlock{(success: Bool, error: NSError?) -> Void in
            if (success) {
            }
            else {
                println(error)
            }
        }
    }
    
    func getUserAge() -> NSInteger {
        if let birthdayString =  self.parseUser.valueForKey("birthday") as? String {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let birthday = dateFormatter.dateFromString(birthdayString)
            var calendar: NSCalendar = NSCalendar.currentCalendar()
            let ageComponents = calendar.components(NSCalendarUnit.CalendarUnitYear, fromDate: birthday!, toDate: NSDate(), options: nil)
            return ageComponents.year
        }
        return 0 as NSInteger
    }
    
    func populateNewUserWithFBData(completion: (() -> Void)!) {
        let profileRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        profileRequest.startWithCompletionHandler{(connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            if let resultDict = result as? NSDictionary {
                self.parseUser.setValue(resultDict.valueForKey("id"), forKey: "facebookId")
                self.parseUser.setValue(resultDict.valueForKey("first_name"), forKey: "name")
                self.parseUser.setValue(resultDict.valueForKey("gender"), forKey:"gender")
                self.parseUser.setValue(resultDict.valueForKey("birthday"), forKey: "birthday")
                self.saveUserToParse()
                completion()
            }
        }
    }
    
    func getUserEvents(completion: (() -> Void)!) {
        let eventsRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath:"/me/events" , parameters: nil, HTTPMethod: "GET")
        eventsRequest.startWithCompletionHandler{(connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            if let result = result as? NSDictionary {
                if let events = result.valueForKey("data") as? NSMutableArray {
                    self.events = events as NSMutableArray
                }
            }
            completion()
        }

    }
    
    func logout() {
        let logMeOut: FBSDKLoginManager = FBSDKLoginManager()
        logMeOut.logOut()
        PFUser.logOut()
    }
}
