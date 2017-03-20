//
//  RecordNoiseViewController.swift
//  RutgersSustainability
//
//  Created by Vineeth Puli on 3/19/17.
//  Copyright © 2017 Rutgers Sustainability Project. All rights reserved.
//

import UIKit
import AVFoundation


class RecordNoiseViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITextFieldDelegate{

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var sendRecordingButton: UIButton!
    @IBOutlet weak var tagsTextField: UITextField!
    
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var fileName = "audioFile.m4a"
    
  //test code
    
    var avgDecibels = 0.0
    var tags = ""
    var totalDecibelCounter = Float(0)
    var timerCounter = Float(0)
    
    var avgDecCount = Float(0)
    var levelTimer = Timer()
    var lowPassResults: Double = 0.0
  // ^^
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendRecordingButton.isEnabled = false
        setUpRecorder()
        

        // Do any additional setup after loading the view.
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
        let path = (getCacheDirectory() as NSString).appendingPathComponent(fileName)
        let filePath = URL(fileURLWithPath: path)
        return filePath
        
    }
    
    @IBAction func record(_ sender: UIButton) {
        if (sender.currentTitle == "Record"){
            
            //delete
            soundRecorder.prepareToRecord()
            soundRecorder.isMeteringEnabled = true
            // delete^
            
            soundRecorder.record()

            // extra code delete
            self.levelTimer = Timer.scheduledTimer(timeInterval: 0.50, target: self, selector: Selector("levelTimerCallback"), userInfo: nil, repeats: true)
            // delete^
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
            print("Is playing")
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
            soundPlayer.volume = 1.0
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
        print(avgDecCount)

    }
    
//TEST CODE DELETE AFTER
   
    
    //This selector/function is called every time our timer (levelTime) fires
    func levelTimerCallback() {
        //we have to update meters before we can get the metering values
       
        timerCounter += 1;
        soundRecorder.updateMeters()
        
        //print to the console if we are beyond a threshold value. Here I've used -7
        print(soundRecorder.averagePower(forChannel: 0))
        if soundRecorder.averagePower(forChannel: 0) > -160 {
         // print("Dis be da level I'm hearin' you in dat mic ")
         //  print(soundRecorder.averagePower(forChannel: 0))
         // print("Do the thing I want, mofo")
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

//^^^^^
    
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
