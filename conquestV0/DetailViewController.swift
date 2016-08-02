//
//  DetailViewController.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-28.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var currentTitle:String?
    var currentDate:String?
    var currentLocation:String?
    var currentDescription:String?
    var currentImage: UIImage?

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var pinImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = currentTitle
        dateLabel.text = currentDate
        locationLabel.text = currentLocation
        descriptionLabel.text = currentDescription
        pinImage.image = currentImage

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
