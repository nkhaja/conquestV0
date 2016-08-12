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
import Spring

protocol BuildPinViewControllerDelegate {
    func updatePins()
}

class BuildPinViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var selectedPin:MKPlacemark? = nil
    let imagePicker = UIImagePickerController()
    var currentUser: PFUser?
    var delegate: BuildPinViewControllerDelegate?
    var annotationId: String = "defaultPin"
    

    
    @IBOutlet weak var titleField: DesignableTextField!
    @IBOutlet weak var locationField: DesignableTextField!
    @IBOutlet weak var dateLabel: DesignableLabel!
    @IBOutlet weak var pinPhoto: UIImageView!
    @IBOutlet weak var descriptionBox: DesignableTextView!
    @IBOutlet weak var iconImage: UIImageView!

    

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
            
            if(date != nil){
            
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Day , .Month , .Year], fromDate: date!)
            
            let year =  components.year
            let month = components.month
            let day = components.day
            
            let dateFormatter: NSDateFormatter = NSDateFormatter()
            let months = dateFormatter.shortMonthSymbols
            let monthSymbol = months[month-1] // month - from your date components
            
            
           
            self.dateLabel.text = "\(monthSymbol) \(day), \(year)"}
        }
    }
    

    
    @IBAction func submitPin(sender: DesignableButton) {
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pinIsSet" {
            if  let mapViewController = segue.destinationViewController as? MapViewController {
              
                
                let newPin = Pin(place: (selectedPin?.coordinate)!)
                
                newPin.title = titleField.text
                newPin.placeName = locationField.text
                newPin.date = dateLabel.text
                newPin.details = descriptionBox.text
                newPin.ownerName = PFUser.currentUser()?.username
                newPin.annotationId = self.annotationId
                
                let imagedata = UIImageJPEGRepresentation( pinPhoto.image!, 0.8)
                newPin.imageFile = PFFile(data: imagedata!)
                
                mapViewController.pinView?.canShowCallout = false // May not need this line
                mapViewController.mapView.removeAnnotations(mapViewController.mapView.annotations)
                addPin(newPin, controller: mapViewController)
            }
        }
        
        else if segue.identifier == "selectAnnotationFromBuilder" {
            if let annotationCollectionViewController = segue.destinationViewController as? AnnotationCollectionViewController{
                annotationCollectionViewController.sender = "builder"
            }
        }
    }
    
    

    
    
    @IBAction func unWindFromAnnotationCollection(sender: UIStoryboardSegue){
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
    
        if pin.title == nil{
            pin.title = ""
        }
        
        if pin.date == nil{
            pin.date = ""
        }
        
        if pin.placeName == nil{
            pin.placeName = ""
        }
        
        if pin.details == nil{
            pin.details = ""
        }
        
        let newPin = PFObject(className: "Pin")
        newPin["user"] = pin.user
        newPin["title"] = pin.title
        newPin["placeName"] = pin.placeName
        newPin["geoLocation"] = pin.geoPoint
        newPin["imageFile"] = pin.imageFile
        newPin["details"] = pin.details
        newPin["date"] = pin.date
        newPin["annotationId"] = pin.annotationId
        newPin["ownerName"] = pin.ownerName
//        newPin.saveInBackground()

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
    

