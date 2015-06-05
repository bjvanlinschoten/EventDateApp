//
//  User.swift
//  Pala
//
//  Created by Boris van Linschoten on 05-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//

import UIKit

class User: NSObject {
    
    let parseUser : PFUser
    
    init (parseUser: PFUser) {
        self.parseUser = parseUser
    }
    
    func populateUserWithFBData() {
        let request: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        request.startWithCompletionHandler{(connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            let resultdict = result as! NSDictionary
            println("Result Dict: \(resultdict)")
        self.parseUser.setObject(resultdict.valueForKey("gender")!, forKey: "gender")
        }
    }
}
