//
//  InterfaceController.swift
//  wKeys WatchKit Extension
//
//  Created by spoonik on 2018/03/21.
//  Copyright © 2018年 spoonikapps. All rights reserved.
//
import WatchKit
import Foundation

class TrainerController: WKInterfaceController, NotifyLastFileEndDelegate {
  @IBOutlet var toner1Label: WKInterfaceLabel!
  @IBOutlet var intervalLabel: WKInterfaceLabel!
  @IBOutlet var buttonPlay: WKInterfaceButton!
  
  var tones: [Int] = []
  var nextFilesPlayerSync: AudioFilesPlayerSync! = nil
  @IBOutlet var volumeSlider: WKInterfaceSlider!
  var volume: Float = 0.75
  
  override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    
        // Configure interface objects here.
        resetAnsers()
        volumeSlider.setValue(self.volume * 10)
    }
  
    func resetAnsers() {
        self.toner1Label.setText("Tones?")
        self.intervalLabel.setText("Interval?")
    }
  
    func displayAnsers() {
        var tonenames = ""
        var intervalnames = ""
        for tone in self.tones {
            if tonenames.count != 0 {
                tonenames += "→"
            }
            tonenames += ResourceManager.getShortKeyNames()[tone]
        }
        for i in (1..<self.tones.count) {
            if intervalnames.count != 0 {
                intervalnames += "→"
            }
            intervalnames += ResourceManager.getIntervalNames()[abs(self.tones[i]-self.tones[i-1])]
        }
        self.toner1Label.setText(tonenames)
        self.intervalLabel.setText(intervalnames)
    }
  
    func notifyLastFilePlayed(end:Bool) {
        if end {
            self.displayAnsers()
        }
    }

    @IBAction func pushPlay() {
        self.resetAnsers()
      
        self.tones = ResourceManager.createQuestionSoundSet()
        var filenames: [String] = []
        for tone in self.tones {
            filenames.append(ResourceManager.getPureToneFileName(index: tone))
        }
        filenames.append("silent")
        for tone in self.tones {
            filenames.append(ResourceManager.getToneNameFileName(index: tone))
        }
      
        nextFilesPlayerSync = AudioFilesPlayerSync(filenames: filenames, volume: self.volume, withContext: self)
        nextFilesPlayerSync.startPlay()
    }
  
    @IBAction func changeVolume(_ value: Float) {
        self.volume = Float(value) / 10.0
        if nextFilesPlayerSync != nil {
            nextFilesPlayerSync.setVolume(volume: self.volume)
        }
    }
  
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    override func willDisappear() {
        // This method is called when watch view controller is no longer visible
        super.willDisappear()
      
        if nextFilesPlayerSync != nil {
            nextFilesPlayerSync.stopPlay()
        }
    }
}

