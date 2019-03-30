//
//  PlayChordPureTone.swift
//  wKeys WatchKit Extension
//
//  Created by spoonik on 2018/08/21.
//  Copyright © 2018年 spoonikapps. All rights reserved.
//

import Foundation
import AVFoundation

// 複数持ちのサイン音ファイルを非同期で再生してコードとして再生するクラス。これはiOS/watchOSで使える
// ただしファイルロードのタイミングが遅れて、ちょっとアルペジオ風になってしまう
//
class PlayChordPureTone: NSObject, PlayChordProtocol {
    //var bass_toners: [PlayPureTone] = []
    //var keys_toners: [PlayPureTone] = []
    var pitches: [PlayPureTone] = []
  
    // Singleton Pattern : PlayChordPureTone でインスタンスを取得
    static let sharedManager: PlayChordPureTone = {
        let instance = PlayChordPureTone()
        return instance
    }()
  
    fileprivate override init() {
        super.init()

        /*
        let basses = ResourceManager.getMIDIBass()
        for i in basses {
            bass_toners.append(PlayPureTone(index: i, volume: 0.4))
        }
        let keys = ResourceManager.getMIDIKeys()
        for i in keys {
            keys_toners.append(PlayPureTone(index: i, volume: 0.4))
        }
        */
    }

    func playPatchOn(bass: String?, chord: String?) {
        playPatchOff()
        pitches = []
        var rootpos = 0
        if bass != nil {
            rootpos = ResourceManager.getRootNames().index(of: bass!)!
            if chord == nil {
                //pitches.append(keys_toners[rootpos])
                pitches.append(PlayPureTone(index: ResourceManager.getMIDIKeys()[rootpos], volume: 0.95))
            } else {
                //pitches.append(bass_toners[rootpos])
                pitches.append(PlayPureTone(index: ResourceManager.getMIDIBass()[rootpos], volume: 0.75))
            }
        } else {
            return
        }
        if chord != nil {
            let chord = ResourceManager.getChordIntervals(chord_style: chord!)
            var i = 1
            for k in chord {
                //pitches.append(keys_toners[(k+rootpos)%12])
                pitches.append(PlayPureTone(index: midikeys[(k+rootpos)%12], volume: 0.75))
                i += 1
            }
        }
        var simultanous: TimeInterval = 0.05
        if pitches.count > 0 {
            simultanous = simultanous + pitches[0].player.deviceCurrentTime
        }
        for p in pitches {
            p.playSoundFile(vol: 0.5, atTime: simultanous)
        }
    }
    func playPatchOff() {
        for p in pitches {
            p.stopSoundFile()
        }
    }
}

class PlayPureTone: NSObject {
    var player: AVAudioPlayer! = nil
    var filename = ""

    init(index: Int, volume: Float) {
        if let id = ResourceManager.getMIDIKeys().index(of: index) {
            filename = ResourceManager.getMIDIKeysFileNames()[id]
        }
        if let id = ResourceManager.getMIDIBass().index(of: index) {
            filename = ResourceManager.getMIDIBassFileNames()[id]
        }
      
        let url = Bundle.main.url(forResource: filename, withExtension: "m4a")
        do {
            try self.player = AVAudioPlayer(contentsOf: url!)
            self.player.volume = volume
            self.player.prepareToPlay()
        } catch {
            print(error)
        }
    }
    func playSoundFile(vol: Float, atTime: TimeInterval) {
        //self.player.play()
        self.player.play(atTime: atTime)
    }
    func stopSoundFile() {
        if self.player != nil && self.player.isPlaying {
            self.player.stop()
            self.player.prepareToPlay()
        }
    }
}
