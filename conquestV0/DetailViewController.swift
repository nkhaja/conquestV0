//
//  DetailViewController.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-28.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var thisPin:Pin?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pinImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = thisPin?.title
        dateLabel.text = thisPin?.date
        locationLabel.text = thisPin?.placeName
        descriptionLabel.text = thisPin?.details
        pinImage.image = thisPin?.image

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "seePicture" {
            if let pictureFrameViewController = segue.destinationViewController as? PictureFrameViewController{
                pictureFrameViewController.pictureHolder = thisPin?.image
                
            }
        }
    }
    

}
