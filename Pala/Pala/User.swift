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
    
    func getUserAge() -> NSInteger? {
        if let birthdayString =  self.parseUser.valueForKey("birthday") as? String {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let birthday = dateFormatter.dateFromString(birthdayString)
            var calendar: NSCalendar = NSCalendar.currentCalendar()
            let ageComponents = calendar.components(NSCalendarUnit.CalendarUnitYear, fromDate: birthday!, toDate: NSDate(), options: nil)
            return ageComponents.year
        } else {
            return nil
        }
    }
}
