//
//  AudioRecorder.swift
//  Instagrad
//
//  Created by David Wale on 04/05/2023.
//

import Foundation
import AVFoundation

class AudioControl:NSObject,AVAudioRecorderDelegate{
    
    
    var recorder: AVAudioRecorder?
    var path: URL
    
    init(path: URL){
        self.path = path
        
        super.init()
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do{
            recorder = try AVAudioRecorder(url: path, settings: settings)
            recorder?.delegate = self
            recorder?.isMeteringEnabled = true
            recorder?.prepareToRecord()
            print("Recorder ready")
        }catch{
            print("There was an error creating the audio recorder")
            print(error.localizedDescription)
        }
    }
    
    func startRecord(){
        if(Int((recorder?.currentTime)!) > 0){
            recorder?.record(atTime: (recorder?.deviceCurrentTime)!)
        } else {
            recorder!.record()
        }
    }
    
    func pauseRecord() {
            recorder!.pause()
        }
        
        func stopRecord() {
            recorder!.stop()
        }
        
        func getTime() -> TimeInterval {
            return (recorder?.currentTime)!
        }
        
        func getValue() -> Float {
            recorder?.updateMeters()
            return (recorder?.averagePower(forChannel: 0))!
        }
    
    
    
}

