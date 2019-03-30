//
//  AudioUnitMIDISynth.swift
//  MIDISynth
//
//  Created by Gene De Lisa on 2/6/16.
//  Copyright © 2016 Gene De Lisa. All rights reserved.
//

import Foundation
import AudioToolbox
import CoreAudio

// swiftlint:disable function_body_length
// swiftlint:disable type_body_length
// swiftlint:disable file_length
// swiftlint:disable line_length

/// # A Core Audio MIDISynth `AudioUnit` example.
/// This will add a polyphonic `kAudioUnitSubType_MIDISynth` audio unit to the `AUGraph`.
///
/// - author: Gene De Lisa
/// - copyright: 2016 Gene De Lisa
/// - date: February 2016
class AudioUnitMIDISynth: NSObject, PlayChordProtocol {
  
    var processingGraph: AUGraph?
    var midisynthNode   = AUNode()
    var ioNode          = AUNode()
    var midisynthUnit: AudioUnit?
    var ioUnit: AudioUnit?
    var musicSequence: MusicSequence!
    var musicPlayer: MusicPlayer!
    let patch          = UInt32(0)    /// Piano
    var pitches: [UInt32] = []
  
    /// Initialize.
    /// set up the graph, load a sound font into the synth, create a sequence, create a player for
    /// that sequence, and start the graph.
    override init() {
        super.init()
      
        augraphSetup()
        loadMIDISynthSoundFont()
        initializeGraph()
        //loadPatches()
        startGraph()
    }
  
    /// Create the `AUGraph`, the nodes and units, then wire them together.
    func augraphSetup() {
        var status = OSStatus(noErr)
      
        status = NewAUGraph(&processingGraph)
        AudioUtils.CheckError(status)
      
        createIONode()
      
        createSynthNode()
      
        // now do the wiring. The graph needs to be open before you call AUGraphNodeInfo
        status = AUGraphOpen(self.processingGraph!)
        AudioUtils.CheckError(status)
      
        status = AUGraphNodeInfo(self.processingGraph!, self.midisynthNode, nil, &midisynthUnit)
        AudioUtils.CheckError(status)
      
        status = AUGraphNodeInfo(self.processingGraph!, self.ioNode, nil, &ioUnit)
        AudioUtils.CheckError(status)
      
      
        let synthOutputElement: AudioUnitElement = 0
        let ioUnitInputElement: AudioUnitElement = 0
      
        status = AUGraphConnectNodeInput(self.processingGraph!,
                                         self.midisynthNode, synthOutputElement, // srcnode, SourceOutputNumber
            self.ioNode, ioUnitInputElement) // destnode, DestInputNumber
      
        AudioUtils.CheckError(status)
    }
  
    /// Create the Output Node and add it to the `AUGraph`.
    func createIONode() {
        var cd = AudioComponentDescription(
            componentType: OSType(kAudioUnitType_Output),
            componentSubType: OSType(kAudioUnitSubType_RemoteIO),
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0, componentFlagsMask: 0)
        let status = AUGraphAddNode(self.processingGraph!, &cd, &ioNode)
        AudioUtils.CheckError(status)
    }
  
    /// Create the Synth Node and add it to the `AUGraph`.
    func createSynthNode() {
        var cd = AudioComponentDescription(
            componentType: OSType(kAudioUnitType_MusicDevice),
            componentSubType: OSType(kAudioUnitSubType_MIDISynth),
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0, componentFlagsMask: 0)
        let status = AUGraphAddNode(self.processingGraph!, &cd, &midisynthNode)
        AudioUtils.CheckError(status)
    }
  
    let soundFontFileName = "Perfect Sine"
    let soundFontFileExt = "sf2"
    //let soundFontFileName = "FluidR3 GM2-2"
    //let soundFontFileExt = "SF2"

    // there is a problem with drop out using this font
    //let soundFontFileName = "GeneralUser GS v1.471"
    //let soundFontFileExt = "sf2"
  
    /// This will load the default sound font and set the synth unit"s property.
    /// - postcondition: `self.midisynthUnit` will have it"s sound font url set.
    func loadMIDISynthSoundFont() {
        if var bankURL = Bundle.main.url(forResource: soundFontFileName, withExtension: soundFontFileExt) {
            let status = AudioUnitSetProperty(
                self.midisynthUnit!,
                AudioUnitPropertyID(kMusicDeviceProperty_SoundBankURL),
                AudioUnitScope(kAudioUnitScope_Global),
                0,
                &bankURL,
                UInt32(MemoryLayout<URL>.size))
            
            AudioUnitSetParameter(self.midisynthUnit!,
                                  127,
                                  kAudioUnitScope_Global,
                                  0,
                                  127,
                                  0);
          
            AudioUtils.CheckError(status)
        } else {
            print("Could not load sound font")
        }
        print("loaded sound font")
    }
  
  
    /// Pre-load the patches you will use.
    ///
    /// Turn on `kAUMIDISynthProperty_EnablePreload` so the midisynth will load the patch data from the file into memory.
    /// You load the patches first before playing a sequence or sending messages.
    /// Then you turn `kAUMIDISynthProperty_EnablePreload` off. It is now in a state where it will respond to MIDI program
    /// change messages and switch to the already cached instrument data.
    ///
    /// - precondition: the graph must be initialized
    ///
    /// [Doug"s post](http://prod.lists.apple.com/archives/coreaudio-api/2016/Jan/msg00018.html)
    func loadPatches() {
        if !isGraphInitialized() {
            fatalError("initialize graph first")
        }
      
        let channel = UInt32(0)
        var enabled = UInt32(1)
      
        var status = AudioUnitSetProperty(
            self.midisynthUnit!,
            AudioUnitPropertyID(kAUMIDISynthProperty_EnablePreload),
            AudioUnitScope(kAudioUnitScope_Global),
            0,
            &enabled,
            UInt32(MemoryLayout<UInt32>.size))
        AudioUtils.CheckError(status)
      
        //        let bankSelectCommand = UInt32(0xB0 | 0)
        //        status = MusicDeviceMIDIEvent(self.midisynthUnit, bankSelectCommand, 0, 0, 0)
      
        let pcCommand = UInt32(0xC0 | channel)
        status = MusicDeviceMIDIEvent(self.midisynthUnit!, pcCommand, patch, 0, 0)
        AudioUtils.CheckError(status)
      
        enabled = UInt32(0)
        status = AudioUnitSetProperty(
            self.midisynthUnit!,
            AudioUnitPropertyID(kAUMIDISynthProperty_EnablePreload),
            AudioUnitScope(kAudioUnitScope_Global),
            0,
            &enabled,
            UInt32(MemoryLayout<UInt32>.size))
        AudioUtils.CheckError(status)
      
        // at this point the patches are loaded. You still have to send a program change at "play time" for the synth
        // to switch to that patch
    }
  
  
    /// Check to see if the `AUGraph` is Initialized.
    ///
    /// - returns: `true` if it"s running, `false` if not
    /// - seealso: [AUGraphIsInitialized](/https://developer.apple.com/library/prerelease/ios/documentation/AudioToolbox/Reference/AUGraphServicesReference/index.html#//apple_ref/c/func/AUGraphIsInitialized)
    func isGraphInitialized() -> Bool {
        var outIsInitialized = DarwinBoolean(false)
        let status = AUGraphIsInitialized(self.processingGraph!, &outIsInitialized)
        AudioUtils.CheckError(status)
        return outIsInitialized.boolValue
    }
  
    /// Initializes the `AUGraph.
    func initializeGraph() {
        let status = AUGraphInitialize(self.processingGraph!)
        AudioUtils.CheckError(status)
    }
  
    /// Starts the `AUGraph`
    func startGraph() {
        let status = AUGraphStart(self.processingGraph!)
        AudioUtils.CheckError(status)
    }
  
    /// Check to see if the `AUGraph` is running.
    ///
    /// - returns: `true` if it"s running, `false` if not
    func isGraphRunning() -> Bool {
        var isRunning = DarwinBoolean(false)
        let status = AUGraphIsRunning(self.processingGraph!, &isRunning)
        AudioUtils.CheckError(status)
        return isRunning.boolValue
    }
  
    /// Send a note on message using patch on channel 0
    func playPatchOn(bass: String?, chord: String?) {
        let channel = UInt32(0)
        let noteCommand = UInt32(0x90 | channel)
        let pcCommand = UInt32(0xC0 | channel)
        var status = OSStatus(noErr)
      
        playPatchOff()
        pitches = []
        var rootpos = 0
        if bass != nil {
          rootpos = ResourceManager.getRootNames().index(of: bass!)!
          if chord == nil {
            pitches.append(UInt32(ResourceManager.getMIDIKeys()[rootpos]))
          } else {
            pitches.append(UInt32(ResourceManager.getMIDIBass()[rootpos]))
          }
        } else {
          return
        }
        if chord != nil {
          let chord = ResourceManager.getChordIntervals(chord_style: chord!)
          for k in chord {
            pitches.append(UInt32(ResourceManager.getMIDIKeys()[(k+rootpos)%12]))
          }
        }
        for p in pitches {
            status = MusicDeviceMIDIEvent(self.midisynthUnit!, pcCommand, patch, 0, 0)
            AudioUtils.CheckError(status)
            status = MusicDeviceMIDIEvent(self.midisynthUnit!, noteCommand, p, 64, 0)
            AudioUtils.CheckError(status)
        }
    }
  
    /// Send a note off message using patch2 on channel 0
    func playPatchOff() {
        let channel = UInt32(0)
        let noteCommand = UInt32(0x80 | channel)
        var status = OSStatus(noErr)
        for p in pitches {
            status = MusicDeviceMIDIEvent(self.midisynthUnit!, noteCommand, p, 127, 0)
            AudioUtils.CheckError(status)
        }
    }
}
