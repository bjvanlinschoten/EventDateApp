//
//  WallCollectionViewController.swift
//  Pala
//
//  Created by Boris van Linschoten on 09-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//

import UIKit

class WallCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // Properties
    var wallUserArray: [Person]?
    var currentUser: User?
    var wall: Wall?
    let sectionInsets = UIEdgeInsets(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0)
    var selectedGender: NSInteger?
    
    var refreshControl: UIRefreshControl!
    
    @IBOutlet var wallCollection: UICollectionView!
    @IBOutlet var centerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.wallCollection.delegate = self
        self.wallCollection.dataSource = self
        self.addLeftBarButtonWithImage(UIImage(named: "Pagoda.png")!)
        self.addRightBarButtonWithImage(UIImage(named: "Match.png")!)
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "FF7400", alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Pull to refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refreshWallCollectionView", forControlEvents: UIControlEvents.ValueChanged)
        self.wallCollection.addSubview(self.refreshControl)
        self.wallCollection.alwaysBounceVertical = true
        
        // appearance
        self.automaticallyAdjustsScrollViewInsets = false
        self.wallCollection.hidden = true
        self.centerLabel.hidden = false
    }
    
    // Reload collection view when Wall will appear from Event selection
    func appearsFromEventSelect() {
        if let selectedEventId = self.wall?.selectedEvent["id"] as? String {
            self.wall!.getUsersToShow(selectedEventId, selectedGender: self.wall!.selectedGender!) { (userArray: [Person]) -> Void in
                if userArray != [] {
                    self.wallUserArray = userArray as [Person]
                    self.centerLabel.hidden = true
                    self.wallCollection.reloadData()
                } else {
                    self.centerLabel.text = "You've either (dis)liked everyone already or you're the only one going!"
                }
                self.wallCollection.hidden = false
                self.title = self.wall?.selectedEvent["name"] as? String
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let array = self.wallUserArray {
            return array.count
        } else {
            return 0
        }
    }
    

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("wallCell", forIndexPath: indexPath) as! WallCollectionViewCell
        
        // Person shown in the cell
        let person = wallUserArray![indexPath.row] as Person
        
        // Set picture
        let picURL: NSURL! = NSURL(string: "https://graph.facebook.com/\(person.facebookId)/picture?width=600&height=600")
        cell.imageView.frame = CGRectMake(10,10,150,230)
        cell.imageView.sd_setImageWithURL(picURL)
        cell.nameLabel.text = "\(person.name) (\(person.getPersonAge()))"
        
        // Set images on buttons
        cell.dislikeButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        cell.likeButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit

        // Set drop shadow
        cell.layer.masksToBounds = false
        cell.layer.shadowOpacity = 0.3
        cell.layer.shadowRadius = 1.0
        cell.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 160, height: 280)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    
    // Liking a user
    @IBAction func likeUser(sender: UIButton){
        let cell = sender.superview! as! WallCollectionViewCell
        let indexPath = self.wallCollection.indexPathForCell(cell)
        let likedUser = wallUserArray![indexPath!.row] as Person
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.wall!.likeUser(likedUser) {(result: Bool) -> Void in
            if result == true {
                let matchAlert: UIAlertView = UIAlertView(title: "New match!", message: "It's a match! Go meet up!", delegate: self, cancelButtonTitle: "Nice!")
                matchAlert.show()
            }
            self.removeUserFromWall(indexPath!)
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
    }
    
    // Disliking a user
    @IBAction func dislikeUser(sender: UIButton){
        let cell = sender.superview! as! WallCollectionViewCell
        let indexPath = self.wallCollection.indexPathForCell(cell)
        let dislikedUser = wallUserArray![indexPath!.row] as Person
        self.wall!.dislikeUser(dislikedUser.objectId)
        self.removeUserFromWall(indexPath!)
    }
    
    // Remove user from wall after (dis)liking
    func removeUserFromWall(indexPath: NSIndexPath) {
        self.wallUserArray?.removeAtIndex(indexPath.row)
        if self.wallUserArray! == [] {
            self.centerLabel.text = "No more users left!"
            self.centerLabel.hidden = false
            self.wallCollection.hidden = true
        }
        self.wallCollection.reloadData()
    }
    
    // Pull to refresh voor wall collectionview
    func refreshWallCollectionView() {
        self.currentUser?.parseUser.fetchInBackgroundWithBlock({ (object: PFObject?, error: NSError?) -> Void in
            self.wall!.getUsersToShow(self.wall!.selectedEvent!["id"] as! String, selectedGender: self.wall!.selectedGender!) { (userArray: [Person]) -> Void in
                if userArray != [] {
                    self.wallUserArray = userArray as [Person]
                    self.wallCollection.hidden = false
                    self.centerLabel.hidden = true
                    self.wallCollection.reloadData()
                } else {
                    self.wallUserArray = []
                    self.wallCollection.hidden = true
                    self.centerLabel.hidden = false
                    self.centerLabel.text = "You've either (dis)liked everyone already or you're the only one going!"
                }
                self.refreshControl.endRefreshing()
            }
        })
    }

}