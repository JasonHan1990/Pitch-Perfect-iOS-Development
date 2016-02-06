//
//  RecordSoundViewController.swift
//  Pitch Perfect
//
//  Created by Jason miew on 2/2/16.
//  Copyright © 2016 JasonHan. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundViewController: UIViewController, AVAudioRecorderDelegate {
    // outlet:
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var stopRecordBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var pauseAndResumeRecordBtn: UIButton!
    
    // var:
    var soundRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    var timer: NSTimer!
    var blinkStatus: Bool!
    var isPause: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        blinkStatus = false
        isPause = false
    }
    
    // For showing and hiding things
    override func viewWillAppear(animated: Bool) {
        
        stopRecordBtn.hidden = true
        recordLabel.hidden = false
        pauseAndResumeRecordBtn.hidden = true
        recordBtn.enabled = true
    }

    
    @IBAction func recordSound(sender: UIButton) {
        
        recordLabel.text = "Recording in progress"
        stopRecordBtn.hidden = false
        pauseAndResumeRecordBtn.hidden = false
        recordBtn.enabled = false
        
        // prepare to record
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        let nameOfRecordSound = "myRecord"
        let recordingName = nameOfRecordSound + ".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        print(filePath)
        
        // Setup audio session
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        // Initialize and prepare the recorder
        try! soundRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
        soundRecorder.delegate = self
        soundRecorder.meteringEnabled = true
        soundRecorder.prepareToRecord()
        soundRecorder.record()
        
        startTimer()
    }
    
    func startTimer() {
        if timer != nil {
            timer.invalidate()
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "recordLblBlink", userInfo: nil, repeats: true)
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if flag {
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            // Move to the next scene aka perform segue
            performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        } else {
            // Print out the err and enable the btn to record again
            print("Recording was not successful")
            recordBtn.enabled = true
            stopRecordBtn.hidden = true
            pauseAndResumeRecordBtn.hidden = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "stopRecording" {
            // segue.destinationViewController makes that when stopRecording is called the view will changed to the next wanted view
            let playSoundsVC:PlaySoundViewController = segue.destinationViewController as! PlaySoundViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    @IBAction func stopRecording(sender: UIButton) {
        
        recordLabel.hidden = true
        recordLabel.text = "Tap to Record"
        isPause = false
        pauseAndResumeRecordBtn.setImage(UIImage(named: "pauseImg"), forState: .Normal)
        
        
        // stop the record
        soundRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        
        timer.invalidate()
        
    }
    
    @IBAction func pauseAndResumeRecording(sender: UIButton) {
        
        if isPause == false {
            recordLabel.text = "Recording is Paused"
            soundRecorder.pause()
            pauseAndResumeRecordBtn.setImage(UIImage(named: "resumeImg"), forState: .Normal)
            isPause = true
        } else {
            recordLabel.text = "Recording in progress"
            soundRecorder.record()
            pauseAndResumeRecordBtn.setImage(UIImage(named: "pauseImg"), forState: .Normal)
            isPause = false
        }
        
        
    }
    
    func recordLblBlink() {
        
        if isPause == false {
            if blinkStatus == false {
                recordLabel.alpha = 0.4
                blinkStatus = true
            } else {
                recordLabel.alpha = 1
                blinkStatus = false
            }
        } else {
            recordLabel.alpha = 1
            blinkStatus = false
        }
        
    }

}

