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

class AfterPictureViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var tagsTextField: UITextField!
    
    let indicator : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)

    let manager = CLLocationManager()
    var latitude : Double!
    var longitude : Double!
    var location : CLLocation! {
        didSet {
            latitude = location.coordinate.latitude;
            longitude = location.coordinate.longitude;
        }
    }
    var epoch : UInt64!
    var image: UIImage!
    var filename: URL!
    var keyName: String = ""
    var deviceID = UIDevice.current.identifierForVendor!.uuidString
    var tags: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tagsTextField.delegate = self
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
        location = (locations).last;
        manager.stopUpdatingLocation()
    }
    
    //override function get location
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendPictureButtonTapped(_ sender: Any) {
        tagsTextField.resignFirstResponder()
        //delete below text
        indicator.color = UIColor.magenta
        indicator.frame = CGRect(x:0,y:0,width:10.0,height:10.0)
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        indicator.bringSubview(toFront: self.view)
        indicator.startAnimating()
        //delete above text
        let untrimmedTags = tagsTextField.text!
        let tagsArr = untrimmedTags.components(separatedBy: " ")
        for i in (0..<tagsArr.count)
        {
            if (i < tagsArr.count - 1)
            {
                tags = tags + "\(tagsArr[i]),"
            }
            else {
                tags = tags + "\(tagsArr[i])"
            }
        }
        
        manager.startUpdatingLocation();
        latitude = location.coordinate.latitude;
        longitude = location.coordinate.longitude;
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = self.filename
        uploadRequest?.key = self.keyName //ProcessInfo.processInfo.globallyUniqueString + ".jpg"
        uploadRequest?.bucket = "rusustainability"
        uploadRequest?.contentType = "image/jpeg"
        uploadRequest?.acl = .publicRead
        
        let transferManager = AWSS3TransferManager.default()
        
        transferManager?.upload(uploadRequest!).continue( {task in
            
            if let error = task.error {
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
                let alertController3 = UIAlertController(title: "Error", message: "There was an error while uploading image to server", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction3 = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                {
                    (result : UIAlertAction) -> Void in
                    print("You pressed OK")
                }
                alertController3.addAction(okAction3)
                self.present(alertController3, animated: true, completion: nil)
                print("Upload failed (\(error))")
            }
            
            if task.result != nil {
                let s3URL =  "http://rusustainability.s3.amazonaws.com/\(self.keyName)"
                print("Uploaded to:\n\(s3URL)")
                Networking.postTrash(userId: self.deviceID, picture: String(s3URL), latitude: self.latitude, longitude: self.longitude, epoch: self.epoch, tags: self.tags, completionHandler: {
                    response, error in
                    
                    if (error != nil) {
                        self.indicator.stopAnimating()
                        self.indicator.hidesWhenStopped = true
                        let alertController2 = UIAlertController(title: "Error", message: "There was an error while uploading image to server", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let okAction2 = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                        {
                            (result : UIAlertAction) -> Void in
                             print("You pressed OK")
                        }
                        alertController2.addAction(okAction2)
                        self.present(alertController2, animated: true, completion: nil)
                        print("error")
                    }
                    else {
                        self.indicator.stopAnimating()
                        self.indicator.hidesWhenStopped = true
                        print("successfully uploaded to server")
                        let alertController = UIAlertController(title: "Trash Image Upload", message: "Image successfully uploaded to server", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                        {
                            (result : UIAlertAction) -> Void in
                             //print("You pressed OK")
                             self.performSegue(withIdentifier: "returnHomeSegue", sender: nil)
                            
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                        
                    }
                   
                }
                )
            }
            else {
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
                print("Unexpected empty result.")
            }
            //add segue back to main view controller
            return nil
        })
    }
    
    //If screen is touched while editing, exits keyboard view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //If return is clicked, exits keyboard view
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
