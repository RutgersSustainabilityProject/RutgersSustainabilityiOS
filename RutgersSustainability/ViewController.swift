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

    var image : UIImage!

    @IBOutlet weak var imageView: UIImageView!
    
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
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true

        }
    }

    @IBAction func segueButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "PictureTaken", sender: self)
    }
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject: AnyObject]!) {
        self.image = image
        imageView.image = self.image
        self.dismiss(animated: true, completion: {() -> Void in
            self.performSegue(withIdentifier: "PictureTaken", sender: nil)

            
            
        })
        
       
    }
    
  
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PictureTaken" {
        print("segue completed")
        let afterPic = segue.destination as! AfterPictureViewController
            if (self.image != nil) {
                afterPic.image = self.image!
            }
        }
    }
    
}

