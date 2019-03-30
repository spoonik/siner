//
//  TouchableView.swift
//  wKeys
//
//  Created by spoonik on 2018/08/19.
//  Copyright © 2018年 spoonikapps. All rights reserved.
//

import Foundation
import UIKit

class TouchableView: UIView {
    var use_MIDI = true
    let touch_circle_radius = ResourceManager.getTouchAreaRadius()
    var last_bass: String? = nil
    var chord_player: PlayChordProtocol!

    var touchViews = [UITouch:TouchSpotView]()
    @IBOutlet weak var chordLabel: UILabel!
    @IBOutlet weak var keyboardView: UIImageView!
    @IBOutlet weak var chartImageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true
        initChordPlayer()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isMultipleTouchEnabled = true
        initChordPlayer()
    }

    func initChordPlayer() {
        if use_MIDI {  // MIDIを初期化すると、ミュージックアプリが一旦停止する
            // ただし、本アプリ起動後にミュージックアプリを起動して再生を始めれば使えるのでMIDIの方が動作が軽いのでこっちデフォルトでいく
            chord_player = AudioUnitMIDISynth()
        } else {
            chord_player = PlayChord()
        }
    }
  
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // ヘルプ表示中は、ヘルプ画像の切り替えをやる
        if self.chartImageView.isHidden == false {
          if self.chartImageView.image == UIImage(named: "Help") {
            self.chartImageView.image = UIImage(named: "Chart")
            return
          } else {
            // 最後のヘルプ画像の後は、ヘルプImageViewを隠すだけ
            self.chartImageView.isHidden = true
            return
          }
        }

        for touch in touches {
            createViewForTouch(touch: touch)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
           let view = viewForTouch(touch: touch)
           // Move the view to the new location.
           let newLocation = touch.location(in: self)
           view?.center = newLocation
        }
        if event != nil {
            playTouches(touches: event!.allTouches!)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
           removeViewForTouch(touch: touch)
        }
        chord_player.playPatchOff()
        chordLabel.text = ""
    }

     override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
           removeViewForTouch(touch: touch)
        }
     }

     // Other methods. . .
    func playTouches(touches: Set<UITouch>) {
        var points: [CGPoint] = []
        for touch in touches {
            points.append(touch.location(in: self))
        }
        let keyboard_frame = self.convert(self.keyboardView.frame, to: nil)
      
        var (bass, chord) = AnalyzeTouchForm.get_chord_pattern(points: points, bassrect: keyboard_frame)
        var chord_text = ""
        if bass != nil {
            chord_text = chord_text + bass!
        } else {
            if last_bass != nil {
              // BASS音を押しっぱなしの場合、音をぶつ切りにしないようにする
              bass = last_bass
              chord_text = chord_text + bass!
            }
        }
        if chord != nil {
            chord_text = chord_text + chord!
        }
        if chordLabel.text != chord_text {
            chordLabel.text = chord_text
            chord_player.playPatchOn(bass: bass, chord: chord)
        }
    }
  
    // UI操作
    @IBAction func pushChartButton(_ sender: Any) {
        self.chartImageView.image = UIImage(named: "Help")
        self.chartImageView.isHidden = false
    }
    @IBAction func pushUseMIDI(_ sender: UISwitch) {
        use_MIDI = sender.isOn
        initChordPlayer()
    }


    // 以下、(TouchSpotViewも含めて)タッチ入力の処理用定型処理 (Appleのサイトからコピペ) --------
    func createViewForTouch( touch : UITouch ) {
       let newView = TouchSpotView()
       newView.bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
       newView.center = touch.location(in: self)
    
       // Add the view and animate it to a new size.
       addSubview(newView)
       UIView.animate(withDuration: 0.2) {
          newView.bounds.size = CGSize(width: self.touch_circle_radius, height: self.touch_circle_radius)
       }
       // Save the views internally
       touchViews[touch] = newView
    }
    func viewForTouch (touch : UITouch) -> TouchSpotView? {
       return touchViews[touch]
    }
    func removeViewForTouch (touch : UITouch ) {
       if let view = touchViews[touch] {
          view.removeFromSuperview()
          touchViews.removeValue(forKey: touch)
       }
    }
}
class TouchSpotView : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.lightGray
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // Update the corner radius when the bounds change.
    override var bounds: CGRect {
      get { return super.bounds }
      set(newBounds) {
         super.bounds = newBounds
         layer.cornerRadius = newBounds.size.width / 2.0
      }
    }
}
