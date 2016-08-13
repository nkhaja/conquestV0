//
//  AnnotationCollectionViewController.swift
//  conquestV0
//
//  Created by Nabil K on 2016-08-06.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit

class AnnotationCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let reuseIdentifier = "collectionCell" // also enter this string as the cell identifier in the storyboard
    var items = ["bluePushPin", "yellowPushPin", "redGooglePin", "clothesPin", "baguette", "chili", "candy", "doughnut", "egg", "fish", "fruit", "fries", "gingerBreadMan", "glass", "ice-cream", "noodles", "knife", "pint", "glass", "pizza", "sandwich", "shwarma", "steak", "sushi", "turkey", "basketball", "bee", "bicycle", "books", "boxing", "burger", "candy", "coins", "cricket","cup", "deer", "exercise", "flask", "football", "goggles", "golf", "graduate", "hockey", "hummingbird", "lion", "martini", "money", "nemo", "olympics", "owl", "shopping-basket", "shopping-cart", "snorkel", "soccer", "spider-web", "fishing", "rollerSkates", "baseball", "football-helmet", "billiards", "medal", "volleyBall", "karate", "strategy", "swan", "video-camera", "tennis-ball"]
    var annotationId: String?
    var sender: String?
    
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // make a cell for each cell index path
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AnnotationCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        
        cell.annotationImage.image = UIImage(named: items[indexPath.item])
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        self.annotationId = items[indexPath.item]
        
        if (sender == "builder"){
            performSegueWithIdentifier("annotationSelected", sender: self)
        }
        else if (sender == "editor"){
            performSegueWithIdentifier("newAnnotationSelected", sender: self)
        }
  
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "annotationSelected"{
            if let buildPinViewController = segue.destinationViewController as? BuildPinViewController {
                buildPinViewController.annotationId = self.annotationId!
                buildPinViewController.annotationButton.setBackgroundImage(UIImage(named: annotationId!), forState: UIControlState.Normal)
                //buildPinViewController.iconImage.image = UIImage(named: annotationId!)
                
            }
        }
        
        else if segue.identifier == "newAnnotationSelected"{
            if let editPinViewController = segue.destinationViewController as? EditPinViewController{
                editPinViewController.annotationImage.image = UIImage(named: self.annotationId!)
                editPinViewController.annotationId  = self.annotationId!
            }
        }
    }
}