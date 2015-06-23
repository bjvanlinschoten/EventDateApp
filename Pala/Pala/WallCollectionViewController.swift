//
//  WallCollectionViewController.swift
//  Pala
//
//  Created by Boris van Linschoten on 09-06-15.
//  Copyright (c) 2015 bjvanlinschoten. All rights reserved.
//

import UIKit

let reuseIdentifier = "wallCell"

class WallCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var wallUserArray: [Person]?
    var currentUser: User?
    let wall: Wall = Wall()
    let sectionInsets = UIEdgeInsets(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0)
    var selectedEvents: [String]?
    var selectedUser: Person?
    
    @IBOutlet var wallCollection: UICollectionView!
    @IBOutlet var selectEventLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.wallCollection.delegate = self
        self.wallCollection.dataSource = self
        self.addLeftBarButtonWithImage(UIImage(named: "Pagoda.png")!)
        self.addRightBarButtonWithImage(UIImage(named: "Match.png")!)
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "FF7400", alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.wallCollection.hidden = true
        self.selectEventLabel.hidden = false
        self.wall.currentUser = self.currentUser
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! WallCollectionViewCell
        
        // Configure the cell
        let person = wallUserArray![indexPath.row] as Person
        let picURL: NSURL! = NSURL(string: "https://graph.facebook.com/\(person.facebookId)/picture?width=600&height=600")
        cell.imageView.frame = CGRectMake(10,10,150,230)
        cell.imageView.sd_setImageWithURL(picURL)
        cell.nameLabel.text = "\(person.name) (\(person.getPersonAge()))"
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
    
    @IBAction func likeUser(sender: UIButton){
        let cell = sender.superview! as! WallCollectionViewCell
        let indexPath = self.wallCollection.indexPathForCell(cell)
        let likedUser = wallUserArray![indexPath!.row] as Person
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.wall.likeUser(likedUser) {(result: Bool) -> Void in
            if result == true {
                println("MATCH!")
            } else {
                println("No match :(")
            }
            self.wallUserArray?.removeAtIndex(indexPath!.row)
            self.wallCollection.reloadData()
            MBProgressHUD.hideHUDForView(self.view, animated: true)

        }
    }
    
    @IBAction func dislikeUser(sender: UIButton){
        let cell = sender.superview! as! WallCollectionViewCell
        let indexPath = self.wallCollection.indexPathForCell(cell)
        let dislikedUser = wallUserArray![indexPath!.row] as Person
        self.wallUserArray?.removeAtIndex(indexPath!.row)
        self.wall.dislikeUser(dislikedUser.objectId)
        self.wallCollection.reloadData()
    }


}