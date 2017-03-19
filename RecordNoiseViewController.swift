//
//  RecordNoiseViewController.swift
//  RutgersSustainability
//
//  Created by Vineeth Puli on 3/19/17.
//  Copyright © 2017 Rutgers Sustainability Project. All rights reserved.
//

import UIKit
import AVFoundation


class RecordNoiseViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate{

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var fileName = "audioFile.m4a"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpRecorder()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpRecorder(){
        
        let recorderSettings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            soundRecorder = try AVAudioRecorder(url: getFileURL(), settings: recorderSettings)
            soundRecorder.delegate = self
          
            // soundRecorder.record()
            //recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
           // finishRecording(success: false)
            print("Error while recording")
        }
     
        
        /*   var error : NSError?
        soundRecorder = try AVAudioRecorder(URL : getFileURL(), settings : recorderSettings as [NSObject : AnyObject], error: &error)
        
        if error != nil{
            print("recorder set up error")
        }
        
        else {
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
        }
         */
        
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
            soundRecorder.record()
            sender.setTitle("Stop recording", for: .normal)
            playButton.isEnabled = false
        }
        else {
            soundRecorder.stop()
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
            
        }
    }
    
    func preparePlayer() {
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: getFileURL())
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
        }
        catch {
            print("Sound player did not load")
        }
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        playButton.isEnabled = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("finished playing")
        recordButton.isEnabled = true
        playButton.setTitle("Play", for: .normal)
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
