//
//  ViewController.swift
//  wKeys
//
//  Created by spoonik on 2018/03/21.
//  Copyright © 2018年 spoonikapps. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      
        // Background Sound On
        let session = AVAudioSession.sharedInstance()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        } catch  {
            fatalError("Failed Background mode set")
        }
        do {
            try session.setActive(true)
        } catch {
            fatalError("Failed activate audio session")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
