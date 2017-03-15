//
//  ViewController.swift
//  RutgersSustainability
//
//  Created by Vineeth Puli on 1/11/17.
//  Copyright © 2017 Rutgers Sustainability Project. All rights reserved.
//

import UIKit
import AWSS3
import AWSCognito

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var deviceIDdisplaySwitch: UISwitch!
    @IBOutlet weak var deviceIDLabel: UILabel!
    
    @IBAction func switchPressed(_ sender: Any) {
        if deviceIDdisplaySwitch.isOn {
            deviceIDLabel.text = deviceID
        } else {
            deviceIDLabel.text = "show device ID"
        }
        
    }
    
    
    var image : UIImage!
    var filename : URL!
    var keyName : String!
    var epoch : UInt64!
    var deviceID = UIDevice.current.identifierForVendor!.uuidString
    
    //Allow option for userID to be shown
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func photoTaken(_ sender: Any) {
       if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
            
        }
        else if
        UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    @IBAction func viewPhotoButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "viewPhotoSegue", sender: nil)
    
    }


   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject: AnyObject]!) {
        self.image = image
        let currentDate = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let dateString = dateFormatter.string(from: currentDate as Date)
        epoch = UInt64(currentDate.timeIntervalSince1970 * 1000.0)
        let fileBase = "JPEG_" + dateString + "_.jpg"
        self.keyName = fileBase
        let filename = getDocumentsDirectory().appendingPathComponent(fileBase)
        let data = UIImageJPEGRepresentation(self.image, 50.0)
        try? data?.write(to: filename)
        self.filename = filename
        self.dismiss(animated: true, completion: {() -> Void in
            self.performSegue(withIdentifier: "PictureTaken", sender: nil)

            
            
        })
        
       
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
  
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PictureTaken" {
        //print("segue completed")
        let afterPic = segue.destination as! AfterPictureViewController
            if (self.image != nil) {
                afterPic.image = self.image!
                afterPic.filename = self.filename!
                afterPic.keyName = self.keyName!
                afterPic.epoch = self.epoch!
            }
        }
    }
    
}

