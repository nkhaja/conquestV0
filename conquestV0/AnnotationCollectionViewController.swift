//
//  AnnotationCollectionViewController.swift
//  conquestV0
//
//  Created by Nabil K on 2016-08-06.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit

import UIKit

class AnnotationCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let reuseIdentifier = "collectionCell" // also enter this string as the cell identifier in the storyboard
    var items = ["bluePushPin", "yellowPushPin", "redGooglePin", "clothesPin"]
    var annotationId: String?
    
    
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
        performSegueWithIdentifier("annotationSelected", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "annotationSelected"{
            if let buildPinViewController = segue.destinationViewController as? BuildPinViewController {
                buildPinViewController.annotationId = self.annotationId
                
            }
        }
    }
}