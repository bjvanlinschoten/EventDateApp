//
//  WallCollectionViewController.swift
//  Pala
//
//  Created by Boris van Linschoten on 09-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//

import UIKit

let reuseIdentifier = "wallCell"

class WallCollectionViewController: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var wallUserArray: [PFUser]?
    var currentUser: User?
    let wall: Wall = Wall()
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // Do any additional setup after loading the view.
        self.wall.currentUser = self.currentUser
        println(self.wallUserArray)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let array = self.wallUserArray {
            return array.count
        } else {
            return 0
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! WallCollectionViewCell
        
        // Configure the cell
        let user = wallUserArray![indexPath.row] as PFUser
        if let userFbId = user.valueForKey("facebookId") as? NSString {
            let picURL: NSURL! = NSURL(string: "https://graph.facebook.com/\(userFbId)/picture?width=600&height=600")
            
            cell.imageView.frame = CGRectMake(10,10,150,240)
            cell.imageView.sd_setImageWithURL(picURL)
            cell.nameLabel.text = user.valueForKey("name") as? String
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 170, height: 300)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    @IBAction func likeUser(sender: UIButton){
        let cell = sender.superview! as! WallCollectionViewCell
        let indexPath = self.collectionView!.indexPathForCell(cell)
        let likedUser = wallUserArray![indexPath!.row] as PFUser
        self.wallUserArray?.removeAtIndex(indexPath!.row)
        if let likedUserFbId = likedUser.valueForKey("facebookId") as? NSString {
            self.currentUser?.addUserToLikedUsers(likedUserFbId)
        }
        self.collectionView?.reloadData()
    }
    
    @IBAction func dislikeUser(sender: UIButton){
        let cell = sender.superview! as! WallCollectionViewCell
        let indexPath = self.collectionView!.indexPathForCell(cell)
        let dislikedUser = wallUserArray![indexPath!.row] as PFUser
        self.wallUserArray?.removeAtIndex(indexPath!.row)
        if let dislikedUserFbId = dislikedUser.valueForKey("facebookId") as? NSString {
            self.currentUser?.addUserToDislikedUsers(dislikedUserFbId)
        }
        self.collectionView?.reloadData()
    }


    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
