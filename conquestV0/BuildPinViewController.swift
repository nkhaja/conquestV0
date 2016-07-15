//
//  BuildPinViewController.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-13.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit
import MapKit

class BuildPinViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var selectedPin:MKPlacemark? = nil
    let imagePicker = UIImagePickerController()
    var currentUser:User! = nil
    
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var pinPhoto: UIImageView!
    
    @IBOutlet weak var descriptionBox: UITextView!

    @IBAction func setPhotoButton(sender: UIButton) {
        
        imagePicker.allowsEditing = false
        
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Action Sheet", message: "Swiftly Now! Choose an option!", preferredStyle: .ActionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        //Create and add first option action
        
        let takePictureAction: UIAlertAction = UIAlertAction(title: "Take Picture", style: .Default) { action -> Void in
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                self.imagePicker.cameraCaptureMode = .Photo
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
            
            else {
                // No Camera
            }
        }
        actionSheetController.addAction(takePictureAction)
        //Create and add a second option action
        
        let choosePictureAction: UIAlertAction = UIAlertAction(title: "Gallery", style: .Default) { action -> Void in
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        
        actionSheetController.addAction(choosePictureAction)
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    

    
    @IBAction func submitPin(sender: UIButton) {
        let newPin = Pin(user: currentUser, location: (selectedPin?.coordinate)!)
        newPin.date = datePicker.date
        newPin.image = pinPhoto.image
        newPin.details = descriptionBox.text
        newPin.title = titleField.text
        newPin.placeName = locationField.text
        currentUser.addPin(newPin)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pinIsSet" {
            if let mapViewController = segue.destinationViewController as? MapViewController {
                mapViewController.currentUser = currentUser
              
                mapViewController.pinView?.canShowCallout = false
            
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        locationField.text = (selectedPin?.name)! + ", " + (selectedPin?.locality)!
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pinPhoto.contentMode = .ScaleAspectFit
            pinPhoto.image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
    

