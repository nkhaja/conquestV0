//
//  pictureFrameViewController.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-28.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit

class PictureFrameViewController: UIViewController {
    
    var pictureHolder: UIImage?

    @IBOutlet weak var picture: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        picture.image = pictureHolder

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
