//
//  Person.swift
//  Pala
//
//  Created by Boris van Linschoten on 18-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//

import Foundation

class Person: NSObject {
    
    var objectId: String
    var facebookId: String
    var name: String
    var birthday: String
    var commonEvent: String?
    
    init(objectId: String, facebookId: String, name: String, birthday: String) {
        self.objectId = objectId
        self.facebookId = facebookId
        self.name = name
        self.birthday = birthday
    }
    
    // Calculate age from user's birthdate
    func getPersonAge() -> NSInteger {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let birthday = dateFormatter.dateFromString(self.birthday)
        var calendar: NSCalendar = NSCalendar.currentCalendar()
        let ageComponents = calendar.components(NSCalendarUnit.CalendarUnitYear, fromDate: birthday!, toDate: NSDate(), options: nil)
        return ageComponents.year
    }
}