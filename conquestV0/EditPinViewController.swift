//
//  EditPinViewController.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-31.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit
import Parse
import Spring

class EditPinViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {


    
    var thisPinIndex: Int = 0
    var thisPin: Pin?
    var updatedPin: Pin?
    let imagePicker = UIImagePickerController()
    var imageHolder: UIImage?
    
    @IBOutlet weak var pinImage: UIImageView!
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var dateText: DesignableLabel!
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var descriptionBox: DesignableTextView!
    

    @IBAction func selectImageButton(sender: UIButton) {
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.pinImage.contentMode = .ScaleAspectFit
            self.pinImage.image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
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
            
            self.dateText.text = "\(monthSymbol) \(day), \(year)"
        }
    }
    

    
    
    @IBAction func submitEdit(sender: UIButton) {
        
        let imagedata = UIImageJPEGRepresentation(self.pinImage.image!, 0.8)
        self.thisPin!.imageFile = PFFile(data: imagedata!)
        let p  = self.thisPin!
        p["title"] = self.titleText.text
        //p["date"] = self.dateText.text
        p["placeName"] = self.locationText.text
        p["description"] = self.descriptionBox.text
        p["imageFile"] = self.thisPin!.imageFile
       
        p.saveInBackground()

        
        let lat = self.thisPin!["geoLocation"].latitude
        let lon = self.thisPin!["geoLocation"].longitude
        let geo = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        updatedPin = Pin(place: geo)
        updatedPin?.title = self.titleText.text
        //updatedPin?.date = self.dateText.text
        updatedPin?.placeName = self.locationText.text
        updatedPin?.details = self.descriptionBox.text
        updatedPin?.imageFile = thisPin!.imageFile
        updatedPin?.image = pinImage.image
        
        performSegueWithIdentifier("edit", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "edit" {
            if let pinViewController = segue.destinationViewController as? PinViewController {
                pinViewController.updatedPin = self.updatedPin
                pinViewController.localPins[thisPinIndex] = self.updatedPin!
                pinViewController.tableView.reloadData()
            }
        }
    }
    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleText.text = thisPin?.title
        dateText.text = String(thisPin?.date)
        locationText.text = thisPin?.placeName
        descriptionBox.text = thisPin?.description
        self.pinImage.image = imageHolder
        imagePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}


