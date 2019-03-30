//
//  ChordProgressController.swift
//  wKeys WatchKit Extension
//
//  Created by spoonik on 2018/08/25.
//  Copyright © 2018年 spoonikapps. All rights reserved.
//

import WatchKit
import Foundation

class ChordProgressController: WKInterfaceController {
    let chord_progress = ChordMemoryManager.sharedManager
    let pcpt = PlayChordPureTone.sharedManager
    var current_chord = 0
    var chordPickerItems: [WKPickerItem]! = []
  
    let picker_delay = 0.15   // Pickerをちょっと移動するたびに音を鳴らすとうざい。ちょっと止まった時に鳴らすための遅延(sec)
    var timer: Timer?   // その遅延を実装するためのタイマー

    @IBOutlet var progressPicker: WKInterfacePicker!
    
    func redisplayPicker() {
        chordPickerItems = []
        let chord_list = chord_progress.getChordStringList()
        if chord_list.count > 0 {
            for chord_name in chord_list {
                let pickerItem = WKPickerItem()
                pickerItem.title = chord_name
                chordPickerItems.append(pickerItem)
            }
        } else {
            let pickerItem = WKPickerItem()
            pickerItem.title = "(Empty)"
            chordPickerItems.append(pickerItem)
        }
        progressPicker.setItems(chordPickerItems)
        current_chord = 0
    }
  
    @IBAction func progressPickerChanged(_ value: Int) {
        current_chord = value
        schedulePlayChord()
    }
    @IBAction func pushClear() {
        chord_progress.clearProgress()
        redisplayPicker()
    }
    @IBAction func tapped(_ sender: Any) {
        schedulePlayChord()
    }
  
    func schedulePlayChord() {
        if self.timer != nil {
            self.timer?.invalidate()
        }
        self.timer = Timer.scheduledTimer(timeInterval: picker_delay, target: self, selector: #selector(ChordProgressController.playChordSoundFile), userInfo: nil, repeats: false)
    }
    @objc func playChordSoundFile() {
        self.chord_progress.playChord(index: current_chord, player: self.pcpt)
    }
  
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        redisplayPicker()
    }
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        redisplayPicker()
    }
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
