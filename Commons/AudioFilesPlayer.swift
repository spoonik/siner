//
//  AudioFilesPlayer.swift
//  wKeys WatchKit Extension
//
//  Created by spoonik on 2018/03/27.
//  Copyright © 2018年 spoonikapps. All rights reserved.
//
import WatchKit
import AVFoundation

// ファイル再生完了を呼び出し元に知らせてくれるプロトコル
protocol NotifyLastFileEndDelegate {
    func notifyLastFilePlayed(end:Bool)
}

// 複数の音を、順番に連続して鳴らしてくれる
//
class AudioFilesPlayerSync: NSObject, AVAudioPlayerDelegate {
    var player: AVAudioPlayer! = nil
    var file_toplay: String = ""
    var next_filenames: [String] = []
    var nextFilesPlayerSync: AudioFilesPlayerSync! = nil
    var delegate: NotifyLastFileEndDelegate! = nil
    var volume: Float = 0.75
  
    init(filenames: [String], volume: Float, withContext context: Any?) {
        if filenames.count > 0 {
            file_toplay = filenames[0]
        }
        if filenames.count > 1 {
            for i in (1..<filenames.count) {
                next_filenames.append(filenames[i])
            }
        }
        self.volume = volume
        if context != nil {
            delegate = (context as? NotifyLastFileEndDelegate)!
        }
    }

    func startPlay() {
        let url = Bundle.main.url(forResource: file_toplay, withExtension: "m4a")
        do {
            try self.player = AVAudioPlayer(contentsOf: url!)
            self.player.volume = self.volume
            self.player.prepareToPlay()
            self.player.play()
            self.player.delegate = self
        } catch {
            print(error)
        }
    }
  
    func stopPlay() {
        //if self.delegate == nil { return }
        //self.player.delegate = nil
        if self.player != nil && self.player.isPlaying {
            self.player.stop()
        }
        self.player = nil
        if nextFilesPlayerSync != nil {
            nextFilesPlayerSync.stopPlay()
        }
        nextFilesPlayerSync = nil
    }
  
    func setVolume(volume: Float) {
        self.volume = volume
        if self.player != nil {
            self.player.volume = self.volume
        }
        if self.nextFilesPlayerSync != nil {
            self.nextFilesPlayerSync.setVolume(volume: volume)
        }
    }
  
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player = nil
        if next_filenames.count > 0 {
          self.nextFilesPlayerSync = AudioFilesPlayerSync(filenames: next_filenames, volume: self.volume, withContext: delegate)
            self.nextFilesPlayerSync.startPlay()
        }
        else if delegate != nil {
            self.delegate.notifyLastFilePlayed(end: true)
        }
        self.delegate = nil
    }
}
