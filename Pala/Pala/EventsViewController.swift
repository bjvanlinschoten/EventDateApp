//
//  EventsViewController.swift
//  Pala
//
//  Created by Boris van Linschoten on 07-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//

import UIKit


class EventsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var wallUserArray: [Person]?
    var wall: Wall?
    var currentUser: User?
    var wallViewController: WallCollectionViewController?
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 15.0, bottom: 10.0, right: 15.0)
    
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        if let id = self.currentUser?.parseUser.valueForKey("facebookId") as? NSString {
            let picURL: NSURL! = NSURL(string: "https://graph.facebook.com/\(id)/picture?width=600&height=600")
            self.profilePicture.sd_setImageWithURL(picURL)
//            self.profilePicture.layer.cornerRadius = self.profilePicture.frame.width / 2
            if let age = self.currentUser?.getUserAge() as NSInteger! {
                if let name = self.currentUser?.parseUser.valueForKey("name") as? String {
                        self.nameLabel.text = "\(name) (\(age))"
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.view.backgroundColor = UIColor.whiteColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let user = self.currentUser {
            if let events = user.events {
                return events.count
            }
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("eventCell", forIndexPath: indexPath) as! EventCollectionViewCell
        
        // Configure the cell
        let event = self.currentUser!.events?[indexPath.row] as! NSDictionary
        let eventId = event["id"] as! String
        let picURL: NSURL! = NSURL(string: "https://graph.facebook.com/\(eventId)/picture?width=600&height=600")
//        cell.imageView.frame = CGRectMake(10,10,150,230)
        cell.imageView.sd_setImageWithURL(picURL)
        cell.imageView.layer.cornerRadius = 10
        cell.eventLabel.text = event["name"] as? String
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! EventCollectionViewCell
        cell.imageView.alpha = 0.5
        
        self.wall = Wall()
        self.wall?.currentUser = self.currentUser
        let selectedEvent = self.currentUser?.events?[indexPath.row] as! NSDictionary
        let selectedEventId = selectedEvent["id"] as! String
        MBProgressHUD.showHUDAddedTo(self.wallViewController?.view, animated: true)
        self.wallViewController?.wallCollection.hidden = false
        self.wallViewController?.selectEventLabel.hidden = true
        self.closeLeft()
        self.currentUser?.parseUser.fetchInBackgroundWithBlock() { (object: PFObject?, error: NSError?) -> Void in
            self.wall?.getUsersToShow(selectedEventId) { (userArray: [Person]) -> Void in
                self.wallUserArray = userArray as [Person]
                self.wallViewController?.wallUserArray = self.wallUserArray
                self.wallViewController?.wallCollection.reloadData()
                MBProgressHUD.hideHUDForView(self.wallViewController?.view, animated: true)
                cell.imageView.alpha = 1
            }
        }

    }
//    
//    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
//        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! EventCollectionViewCell
//        cell.imageView.alpha = 1
//    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 240, height: 60)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "eventsToWall" {
            let nvc = segue.destinationViewController as! UITabBarController
            let wvc = nvc.viewControllers?.first as! WallCollectionViewController
            let cvc = nvc.viewControllers?[1] as! ChatsTableViewController
            wvc.currentUser = self.currentUser
            cvc.currentUser = self.currentUser
            wvc.wallUserArray = self.wallUserArray
        }
    }

}
