//
//  ChordController.swift
//  wKeys WatchKit Extension
//
//  Created by spoonik on 2018/08/21.
//  Copyright © 2018年 spoonikapps. All rights reserved.
//

import WatchKit
import Foundation

class ChordController: WKInterfaceController {
    @IBOutlet var rootPicker: WKInterfacePicker!
    @IBOutlet var chordPicker: WKInterfacePicker!

    let root_names = ResourceManager.getRootNames()
    let chord_names = ResourceManager.getChordStyleNames()

    var rootPickerItems: [WKPickerItem]! = []
    var chordPickerItems: [WKPickerItem]! = []
  
    var current_root = 0
    var current_chord = 0
  
    let pcpt = PlayChordPureTone.sharedManager
    let chord_progress = ChordMemoryManager.sharedManager
    let picker_delay = 0.15   // Pickerをちょっと移動するたびに音を鳴らすとうざい。ちょっと止まった時に鳴らすための遅延(sec)
    var timer: Timer?   // その遅延を実装するためのタイマー

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        initPickers()
    }

    func schedulePlayChord() {
        if self.timer != nil {
            self.timer?.invalidate()
        }
        self.timer = Timer.scheduledTimer(timeInterval: picker_delay, target: self, selector: #selector(ChordController.playChordSoundFile), userInfo: nil, repeats: false)
    }
    @objc func playChordSoundFile() {
        self.pcpt.playPatchOff()
        self.pcpt.playPatchOn(bass: root_names[current_root], chord: chord_names[current_chord])
    }
  
    @IBAction func tapped(_ sender: Any) {
        playChordSoundFile()
    }
    func initPickers() {
        rootPickerItems = []
        chordPickerItems = []
      
        for root_name in root_names {
            let pickerItem = WKPickerItem()
            pickerItem.title = root_name
            rootPickerItems.append(pickerItem)
        }
        rootPicker.setItems(rootPickerItems)
      
        for chord_name in chord_names {
            let pickerItem = WKPickerItem()
            pickerItem.title = chord_name
            chordPickerItems.append(pickerItem)
        }
        chordPicker.setItems(chordPickerItems)
    }
  
    @IBAction func pushAddProgress() {
        playChordSoundFile()
        self.chord_progress.addNewChord(bass: root_names[current_root], chord_style: chord_names[current_chord])
    }
  
    @IBAction func rootPickerChanged(_ value: Int) {
        current_root = value
        schedulePlayChord()
    }
    @IBAction func chordPickerChanged(_ value: Int) {
        current_chord = value
        schedulePlayChord()
    }
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
