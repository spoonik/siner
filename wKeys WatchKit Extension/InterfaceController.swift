//
//  InterfaceController.swift
//  wKeys WatchKit Extension
//
//  Created by spoonik on 2018/03/21.
//  Copyright © 2018年 spoonikapps. All rights reserved.
//
import WatchKit
import Foundation

class InterfaceController: WKInterfaceController, NotifyLastFileEndDelegate {
  @IBOutlet var picker: WKInterfacePicker!
  var pickerItems: [WKPickerItem]! = []
  var current_key = 0
  var nextFilesPlayerSync: AudioFilesPlayerSync! = nil

  override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        let tone_names = ResourceManager.getPickerNames()
        for tone_name in tone_names {
            let pickerItem = WKPickerItem()
            pickerItem.title = tone_name
            pickerItems.append(pickerItem)
        }
    }
  
    @IBAction func pickerSelect(_ value: Int) {
        current_key = value
        playSoundFile(index: current_key)
    }
    @IBAction func tapped(_ sender: Any) {
        playSoundFile(index: current_key)
    }

    func playSoundFile(index: Int) {
        let filenames = [ResourceManager.getPureToneFileName(index: index)]
        nextFilesPlayerSync = AudioFilesPlayerSync(filenames: filenames, volume: 1.0, withContext: nil)
        nextFilesPlayerSync.startPlay()
    }
  
    func notifyLastFilePlayed(end:Bool) {
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
      
        picker.setItems(pickerItems)
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
