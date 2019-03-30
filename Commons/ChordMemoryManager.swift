//
//  ChordMemoryManager.swift
//  wKeys
//
//  Created by spoonik on 2018/08/25.
//  Copyright © 2018年 spoonikapps. All rights reserved.
//

import Foundation

class ChordMemoryManager: NSObject {
    var chordProgressList: [(String, String)] = []  //0: bass, 1: chord_style
    let max_list_item = 20
    let plist_entry_key = "chordMemory"

    // Singleton Pattern : ChordMemoryManager.shareManager でインスタンスを取得
    static let sharedManager: ChordMemoryManager = {
        let instance = ChordMemoryManager()
        return instance
    }()
    fileprivate override init() {
        super.init()
        reloadPlist()
    }

    func addNewChord(bass: String, chord_style: String) {
        if self.chordProgressList.count >= max_list_item {
            self.chordProgressList.removeFirst()
        }
        self.chordProgressList.append((bass,chord_style))
        writePlist()
    }
    func clearProgress() {
        chordProgressList = []
        writePlist()
    }
    func getChordStringList() -> [String] {
        var ret: [String] = []
        for i in chordProgressList {
            ret.append(i.0 + i.1)
        }
        return ret
    }

    func playChord(index: Int, player: PlayChordProtocol) {
        if index < 0 || index >= self.chordProgressList.count {
            return
        }
        player.playPatchOff()
        player.playPatchOn(bass: self.chordProgressList[index].0, chord: self.chordProgressList[index].1)
    }

    func reloadPlist() {
        let userDefaults = UserDefaults.standard
        let chord_array: NSArray? = userDefaults.object(forKey: plist_entry_key) as? NSArray
      
        var str_pair: (String, String) = ("","")
        if chord_array != nil {
            for i in 0..<chord_array!.count {
                if i % 2 == 0 {
                    str_pair.0 = chord_array![i] as! String
                } else {
                    str_pair.1 = chord_array![i] as! String
                    chordProgressList.append(str_pair)
                }
            }
        }
    }
    func writePlist() {
        let userDefaults = UserDefaults.standard
        let chord_array: NSMutableArray = []
        for i in chordProgressList {
            chord_array.add(i.0)
            chord_array.add(i.1)
        }
        userDefaults.set(chord_array, forKey: plist_entry_key)
        userDefaults.synchronize()
    }
/*
    func writePlist() {
        let docsDir: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let plistFileName = docsDir + "/chordMemory.plist"
      
        let array: NSMutableArray = []
        for chord in chordProgressList {
            array.add(chord)
        }
        array.write(toFile: plistFileName, atomically: true)
    }
    func reloadPlist() {
        let docsDir: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let plistFileName = docsDir + "/chordMemory.plist"
        if FileManager.default.fileExists(atPath: plistFileName) {
            let ar = NSArray(contentsOfFile: plistFileName)!
            for i in ar {
              chordProgressList.append(i as! (String,String))
            }
        }
    }*/
}
