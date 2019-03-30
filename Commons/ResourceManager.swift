//
//  ResourceManager.swift
//  wKeys WatchKit Extension
//
//  Created by spoonik on 2018/04/01.
//  Copyright © 2018年 spoonikapps. All rights reserved.
//

import WatchKit

let touch_circle_radius = 90  // タッチ位置の差分を取る基準。もっと相対的に判断できるようにしたい TODO

let pitches_filename =
      ["F2", "Fs2", "G2", "Gs2", "A2", "As2", "B2", "C3", "Cs3", "D3", "Ds3", "E3",
       "F3", "Fs3", "G3", "Gs3", "A3", "As3", "B3", "C4", "Cs4", "D4", "Ds4", "E4", "F4"]

// UIに表示する音名。ショートネームとセットで管理すること
let key_picker_names =
      ["F2(Fa)", "F#2/Gb(Fi)", "G2(So)", "G#2/Ab(Si)", "A2(La)", "A#/Bb2(Te)", "B2(Ti)", "C3(Do)",
      "C#3/Db(Di)", "D3(Re)", "Eb/D#3(Ri)", "E3(Mi)", "F3(Fa)", "F#3/Gb(Fi)",
      "G3(So)", "G#3/Ab(Si)", "A3(La)", "A#/Bb3(Te)", "B3(Ti)",
      "C4(Do)", "C#4/Db(Di)", "D4(Re)", "D#4/Eb(Ri)", "E4(Mi)", "F4(Fa)"]
let key_short_names =
      ["F2", "F#2", "G2", "G#2", "A2", "Bb2", "B2", "C3",
      "C#3", "D3", "D#3", "E3", "F3", "F#3",
      "G3", "G#3", "A3", "Bb3", "B3",
      "C4", "C#4", "D4", "D#4", "E4", "F4"]

let interval_names = ["P1", "min2", "Maj2", "min3", "Maj3", "P4", "Dim5", "P5", "min6", "Maj6", "min7", "Maj7"]

let roots = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]
let chordstyles = ["M", "m", "7", "M7", "m7", "M9", "m9", "dim7", "aug9", "7sus4", "m7b5", "m7#5", "7#5"]
let chord_intervals = ["M":[0,4,7], "m":[0,3,7], "M7":[0,4,7,11], "7":[0,4,7,10], "M9":[0,2,4,7],
      "m7":[0,3,7,10], "m9":[0,2,3,7], "6":[0,4,7,9], "m6":[0,3,7,9], "m7#5":[0,3,8,10],
      "mM7":[0,3,7,11], "aug":[0,4,8], "aug9":[0,2,4,8],
      "dim":[0,3,6], "dim7":[0,3,6,9], "sus4":[0,5,7], "7sus4":[0,5,7,10], "7#5":[0,4,8,10],
      "m7b5":[0,3,6,10], "5":[0,7], "1":[0]]

// MIDIナンバーの定義。直下の音名ファイル名も同じ並びになるようにセットで管理すること
let midibass = [48,49,50,51,52,53,54,55,56,57,58,59]
let midikeys = [60,61,62,63,64,65,66,67,68,69,70,71]
// 以下のサイン波の周波数は、低めの音の方がrei harakamiっぽいので1オクターブシフト(MIDIの音高と合わせた)
let midibass_filename = ["C1", "Cs1", "D1", "Ds1", "E1", "F1", "Fs1", "G1", "Gs1", "A1", "As1", "B1"]
let midikeys_filename = ["C2", "Cs2", "D2", "Ds2", "E2", "F2", "Fs2", "G2", "Gs2", "A2", "As2", "B2"]
//let midibass_filename = ["C2", "Cs2", "D2", "Ds2", "E2", "F2", "Fs2", "G2", "Gs2", "A2", "As2", "B2"]
//let midikeys_filename = ["C3", "Cs3", "D3", "Ds3", "E3", "F3", "Fs3", "G3", "Gs3", "A3", "As3", "B3"]

let key_name_filename_suffix = "_name"


class ResourceManager: NSObject {
    static func getTouchAreaRadius() -> Int {
        return touch_circle_radius
    }

    static func getMaxSoundNum() -> Int {
        return pitches_filename.count
    }
  
    static func getMIDIBass() -> [Int] {
        return midibass
    }
    static func getMIDIKeys() -> [Int] {
        return midikeys
    }
    static func getMIDIBassFileNames() -> [String] {
        return midibass_filename
    }
    static func getMIDIKeysFileNames() -> [String] {
        return midikeys_filename
    }

    static func getPickerNames() -> [String] {
        return key_picker_names
    }
    static func getShortKeyNames() -> [String] {
        return key_short_names
    }
    static func getIntervalNames() -> [String] {
        return interval_names
    }
    static func getRootNames() -> [String] {
        return roots
    }
    static func getChordStyleNames() -> [String] {
        return chordstyles
    }
    static func getChordIntervals(chord_style: String) -> [Int] {
        return chord_intervals[chord_style]!
    }

    static func getPureToneFileName(index: Int) -> String {
        return pitches_filename[index]
    }
    static func getToneNameFileName(index: Int) -> String {
        return pitches_filename[index] + key_name_filename_suffix
    }

    static func createQuestionSoundSet() -> [Int] {
        let max_num: UInt32 = UInt32(ResourceManager.getMaxSoundNum())
        let tone_num = (Int)(arc4random_uniform(2)) + 2
        var tones: [Int] = []
      
        let start = (Int)(arc4random_uniform(max_num))
        tones.append(start)

        for _ in (1..<tone_num) {
            let interval = (Int)(arc4random_uniform(10)) + 1
            var next = tones.last! + interval
            if next >= max_num {
                next = tones.last! - interval
            } else if tones.last! - interval > 0 {
                if (Int)(arc4random_uniform(2)) == 0 {
                    next = tones.last! - interval
                }
            }
            tones.append(next)
        }
        return tones
    }
  
}
