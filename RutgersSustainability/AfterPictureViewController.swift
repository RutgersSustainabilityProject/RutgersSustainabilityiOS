//
//  AfterPictureViewController.swift
//  RutgersSustainability
//
//  Created by Vineeth Puli on 1/14/17.
//  Copyright © 2017 Rutgers Sustainability Project. All rights reserved.
//

import UIKit
import AWSS3
import AWSDynamoDB
import AWSSQS
import AWSSNS
import AWSCognito
import CoreLocation

class AfterPictureViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tagsTextField: UITextField!
    
    let manager = CLLocationManager()
    var latitude : Double!
    var longitude : Double!
    var location : CLLocation! {
        didSet {
            latitude = location.coordinate.latitude;
            longitude = location.coordinate.longitude;
        }
    }
    var image: UIImage!
    var filename: URL!
    var keyName: String = ""
    var deviceID = UIDevice.current.identifierForVendor!.uuidString
    var tags: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageView.image = self.image;
        manager.delegate = self;       // manager.desiredAccuracy
        manager.desiredAccuracy = kCLLocationAccuracyBest;
        checkCoreLocationPermission();
    }
    
    func checkCoreLocationPermission(){
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            manager.startUpdatingLocation();
        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            manager.requestWhenInUseAuthorization();
        } else if CLLocationManager.authorizationStatus() == .restricted {
            //put an alert
            print("unauthorized to use location service")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = (locations as! [CLLocation]).last;
        manager.stopUpdatingLocation()
    }
    
    //override function get location

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendPictureButtonTapped(_ sender: Any) {
        tags = tagsTextField.text!
        manager.startUpdatingLocation();
        latitude = location.coordinate.latitude;
        longitude = location.coordinate.longitude;
        print("\(latitude)")
        print("\(longitude)")
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = self.filename
        uploadRequest?.key = self.keyName //ProcessInfo.processInfo.globallyUniqueString + ".jpg"
        uploadRequest?.bucket = "rusustainability"
        uploadRequest?.contentType = "image/jpeg"
        uploadRequest?.acl = .publicRead
        
        let transferManager = AWSS3TransferManager.default()
        
        transferManager.upload(uploadRequest!).continueWith(block: {task in
            
            if let error = task.error {
                print("Upload failed (\(error))")
            }

            if task.result != nil {
                let s3URL =  "http://rusustainability.s3.amazonaws.com/\(self.keyName)"
                print("Uploaded to:\n\(s3URL)")
                Networking.postTrash(userId: self.deviceID, picture: String(s3URL), latitude: self.latitude, longitude: self.longitude, epoch: 0, tags: self.tags, completionHandler: {
                    response, error in
                    
                    if (error != nil) {
                        print("error")
                    }
                    else {
                        print("successfully uploaded to server")
                    }
                }
                )
            }
            else {
                print("Unexpected empty result.")
            }
            return nil
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
