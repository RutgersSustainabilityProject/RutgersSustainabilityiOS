//
//  RecordNoiseViewController.swift
//  RutgersSustainability
//
//  Created by Vineeth Puli on 3/19/17.
//  Copyright © 2017 Rutgers Sustainability Project. All rights reserved.
//

import UIKit
import AVFoundation
import AWSS3
import AWSDynamoDB
import AWSSQS
import AWSSNS
import AWSCognito
import CoreLocation

class RecordNoiseViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, CLLocationManagerDelegate, UITextFieldDelegate{

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var sendRecordingButton: UIButton!
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
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var deviceID = UIDevice.current.identifierForVendor!.uuidString
    var fileSuffix = "/" + UIDevice.current.identifierForVendor!.uuidString + "_decibelMeasurement.3gp"
    var fileName : URL!
    var keyName = ""
    var tags = ""
    var epoch : UInt64!
    var totalDecibelCounter = Float(0)
    var avgDecCount = Float(0)
    var avgDecibels = 0.0
    var levelTimer = Timer()
    var timerCounter = Float(0)
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendRecordingButton.isEnabled = false
        setUpRecorder()
        manager.delegate = self;       
        manager.desiredAccuracy = kCLLocationAccuracyBest;
        checkCoreLocationPermission();

        
        // Do any additional setup after loading the view.
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

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpRecorder(){
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(
                AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        let recorderSettings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            soundRecorder = try AVAudioRecorder(url: getFileURL(), settings: recorderSettings)
            soundRecorder.delegate = self
          
        } catch {

            print("Error while recording")
        }
        
    }
    
    func getCacheDirectory() -> String{
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) 
        
        return paths[0]
    }
    
    func getFileURL() -> URL{
        let path = (getCacheDirectory() as NSString).appendingPathComponent(fileSuffix)
        let filePath = URL(fileURLWithPath: path)
        self.fileName = filePath
        return filePath
        
    }
    
    @IBAction func record(_ sender: UIButton) {
        if (sender.currentTitle == "Record"){
            
            //Sets up recorder and starts recording
            soundRecorder.prepareToRecord()
            soundRecorder.isMeteringEnabled = true
            soundRecorder.record()

            // Repeating timer, calls timer function every 0.5 seconds while recording (Check if more frequency is needed)
            self.levelTimer = Timer.scheduledTimer(timeInterval: 0.50, target: self, selector: #selector(RecordNoiseViewController.levelTimerCallback), userInfo: nil, repeats: true)
            
            sender.setTitle("Stop recording", for: .normal)
            playButton.isEnabled = false
        }
        else {
            levelTimer.invalidate()
            soundRecorder.stop()
            avgDecCount = totalDecibelCounter/timerCounter
            print("this is the average Decibel counter: \(avgDecCount)")
            if (!sendRecordingButton.isEnabled) {
                sendRecordingButton.isEnabled = true
            }
            sender.setTitle("Record", for: .normal)
            playButton.isEnabled = false
        }
        
    }
    
    @IBAction func playSound(_ sender: UIButton) {
        if (sender.currentTitle == "Play"){
            recordButton.isEnabled = false
            preparePlayer()
            soundPlayer.play()
            sender.setTitle("Stop", for: .normal)
        }
        else {
            soundPlayer.stop()
            
            sender.setTitle("Play", for: .normal)
            recordButton.isEnabled = true
            
        }
    }
    
    func preparePlayer() {
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: getFileURL())
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 15.0
            soundPlayer.isMeteringEnabled = true
        }
        catch {
            print("Sound player did not load")
        }
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        playButton.isEnabled = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //print("finished playing")
        recordButton.isEnabled = true
        playButton.setTitle("Play", for: .normal)
    }
    

    @IBAction func sendRecording(_ sender: Any) {
        tagsTextField.resignFirstResponder()
        //return button doesn't close textfield, fix this error
    
        //Make the UI better for indicator, its not visble
        indicator.color = UIColor.magenta
        indicator.frame = CGRect(x:0,y:0,width:10.0,height:10.0)
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        indicator.bringSubview(toFront: self.view)
        indicator.startAnimating()
        print(avgDecCount)
        //decibels
        avgDecibels = Double(avgDecCount)
        
        //tags
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
        
        //latitude & longitude
        manager.startUpdatingLocation();
        self.latitude = location.coordinate.latitude;
        self.longitude = location.coordinate.longitude;
        
        //epoch
        let currentDate = NSDate()
        //let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        //let dateString = dateFormatter.string(from: currentDate as Date)
        self.epoch = UInt64(currentDate.timeIntervalSince1970 * 1000.0)
        
        //keyName for URL
       
        self.keyName = "" + self.deviceID + "_" + String(self.epoch) + "_decibelMeasurement.3gp"
        let s3url = "http://rusustainability.s3.amazonaws.com/\(self.keyName)"   //UserID_epoch_decibelmeasurement3gp
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = self.fileName
        uploadRequest?.key = self.keyName
        uploadRequest?.bucket = "rusustainability"
        uploadRequest?.contentType = "video/3gpp" //For Noise, video/3gpp
        uploadRequest?.acl = .publicRead
        
        let transferManager = AWSS3TransferManager.default()

        transferManager?.upload(uploadRequest!).continue( {task in
            
            if let error = task.error {
    
                //stops indicator loading
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
                
                print("Upload failed (\(error))")
               
                //sends alert to user that lets them know uploading failed
                let alertController1 = UIAlertController(title: "Error", message: "There was an error while uploading recording to server", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction1 = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                {
                    (result : UIAlertAction) -> Void in
                    print("You pressed OK")
                }
                alertController1.addAction(okAction1)
                self.present(alertController1, animated: true, completion: nil)
                
                
            }

            if task.result != nil {
                let s3URL =  "http://rusustainability.s3.amazonaws.com/\(self.keyName)"
                print("Uploaded to:\n\(s3URL)")

                Networking.postNoise(userId: self.deviceID, audio: s3url, latitude: self.latitude, longitude: self.longitude, decibels: self.avgDecibels, epoch: self.epoch, tags: self.tags, completionHandler: {
                    response, error in
            
                    if (error != nil) {
                        self.indicator.stopAnimating()
                        self.indicator.hidesWhenStopped = true
                       
                        print("error")
                        print("\(error?.description)")
                        
                        let alertController2 = UIAlertController(title: "Error", message: "There was an error while uploading recording to server", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let okAction2 = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                        {
                            (result : UIAlertAction) -> Void in
                            print("You pressed OK")
                        }
                        alertController2.addAction(okAction2)
                        self.present(alertController2, animated: true, completion: nil)

                        
                        
                    } else {
                        self.indicator.stopAnimating()
                        self.indicator.hidesWhenStopped = true
                        
                        print("successfully uploaded to server")
                        
                        let alertController3 = UIAlertController(title: "Trash Image Upload", message: "Image successfully uploaded to server", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let okAction3 = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                        {
                            (result : UIAlertAction) -> Void in
                            print("You pressed OK")
                            //Add segue that returns to main view controller
                            //self.performSegue(withIdentifier: "returnHomeSegue", sender: nil)
                            
                        }
                        alertController3.addAction(okAction3)
                        self.present(alertController3, animated: true, completion: nil)
                        
                    }
            
                }
                )
        
            }
            else {
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
                print("Unexpected empty result.")
            }
        
            return nil
        })
            
            
    }
    
//Timer Function
   
    //This selector/function is called every time timer fires
    func levelTimerCallback() {
        
        //updates the meters of the recording and the counter of the timer
        timerCounter += 1;
        soundRecorder.updateMeters()
        
        //prints the average decibel reading of the recording file
        print(soundRecorder.averagePower(forChannel: 0))
        if soundRecorder.averagePower(forChannel: 0) > -160 {
       

            //Converts the dbFS reading given by Apple into actual decibels, adds to total decibel count
            //The dbFS to dB returns a scale from 0-1, and this is converted to a 160 dB scale
            let currentReading = dBFS_convertTo_dB(dBFSValue: soundRecorder.averagePower(forChannel: 0))
            totalDecibelCounter += (currentReading * Float(160))
        }
    }
    
    
    /**
     Format dBFS to dB
     - parameter dBFSValue: raw value of averagePowerOfChannel
     
     - returns: formatted value
     */
    func dBFS_convertTo_dB (dBFSValue: Float) -> Float
    {
        var level:Float = 0.0
        let peak_bottom:Float = -60.0 // dBFS -> -160..0   so it can be -80 or -60
        
        if dBFSValue < peak_bottom
        {
            level = 0.0
        }
        else if dBFSValue >= 0.0
        {
            level = 1.0
        }
        else
        {
            let root:Float              =   2.0
            let minAmp:Float            =   powf(10.0, 0.05 * peak_bottom)
            let inverseAmpRange:Float   =   1.0 / (1.0 - minAmp)
            let amp:Float               =   powf(10.0, 0.05 * dBFSValue)
            let adjAmp:Float            =   (amp - minAmp) * inverseAmpRange
            
            level = powf(adjAmp, 1.0 / root)
        }
        return level
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
