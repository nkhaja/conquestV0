//
//  BuildPinViewController.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-13.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit
import MapKit
import Parse

protocol BuildPinViewControllerDelegate {
    func updatePins()
}

class BuildPinViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var selectedPin:MKPlacemark? = nil
    let imagePicker = UIImagePickerController()
    var currentUser: PFUser?
    var delegate: BuildPinViewControllerDelegate?
    var mapViewController: MapViewController?
    
    
    @IBOutlet weak var dateField: UITextField!
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
    
    @IBAction func datePickerTapped(sender: AnyObject) {
        DatePickerDialog().show("DatePicker", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Date) {
            (date) -> Void in
            
    
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Day , .Month , .Year], fromDate: date!)
            
            let year =  components.year
            let month = components.month
            let day = components.day
            
            
            let dateFormatter: NSDateFormatter = NSDateFormatter()
            
            let months = dateFormatter.shortMonthSymbols
            let monthSymbol = months[month-1] // month - from your date components

 
            
            self.dateField.text = "\(monthSymbol) \(day), \(year)"
        }
    }
    

    
    @IBAction func submitPin(sender: UIButton) {
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pinIsSet" {
            if  let mapViewController = segue.destinationViewController as? MapViewController {
              
                
                let newPin = Pin(place: (selectedPin?.coordinate)!)
                
                newPin.title = titleField.text
                newPin.placeName = locationField.text
                //newPin.date = datePicker.date
                newPin.details = descriptionBox.text
                
                let imagedata = UIImageJPEGRepresentation( pinPhoto.image!, 0.8)
                newPin.imageFile = PFFile(data: imagedata!)
                
                mapViewController.pinView?.canShowCallout = false // May not need this line
                mapViewController.mapView.removeAnnotations(mapViewController.mapView.annotations)
                addPin(newPin, controller: mapViewController)
 
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
    
    func addPin(pin:Pin, controller: MapViewController){
        
        let newPin = PFObject(className: "Pin")
        newPin["user"] = pin.user
        newPin["title"] = pin.title
        newPin["placeName"] = pin.placeName
        newPin["geoLocation"] = pin.geoPoint
        newPin["imageFile"] = pin.imageFile
        newPin["details"] = pin.details
        //newPin["date"] = pin.date
        
        newPin.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("object saved")
                MapHelper.populatePins(controller.mapView) { (pins) in
                    controller.pins = pins
                    controller.clusters = MapHelper.prepareClustering(controller.pins + controller.friendPins)
                    controller.clusteringManager.setAnnotations(controller.clusters)
                }
            }
            else {
                print("error")
            }
        }
    }
}
    

