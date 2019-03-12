//
//  room.swift
//  Augment3d
//
//  Created by Omar Peracha on 03/03/2019.
//  Copyright © 2019 Omar Peracha. All rights reserved.
//

import Foundation
import AudioKit

// MARK -- Convolution Room
class RoomConv: Room {
  
  private let distanceThresholds = [1.0]
  
  override init(){
    super.init()
    
    let fileUrl = Bundle(for: type(of: self)).url(forResource: "Locked bass IR_1", withExtension:"wav")
    
    let conv = AKConvolution(impulseResponseFileURL: fileUrl!)
    let convHP = AKHighPassFilter(nil, cutoffFrequency: 200, resonance: 0)
    let convReduce = AKBooster(nil, gain: -2)
    
    let flow0 = Flow(room: self,
                     //to do - make gen morphing oscillator
                     gens: [AKOscillator()],
                     FX: [[conv, convHP, convReduce, AKPeakLimiter()]],
                     distThresh: distanceThresholds[0],
                     pos: [0, 0, -5])
    
    flows.append(flow0)
    
  }
  
  func updateFlows(pos: NSArray, yaw: Double, gravY: Double){
    
    if flows.count == 0 {
      return
    }
    
    updateFlow0(pos: pos, yaw: yaw, gravY: gravY)
    
  }
  
  private func updateFlow0(pos: NSArray, yaw: Double, gravY: Double){
    
    let flow = flows[0]
    let sinVol = 0.3
    let distance = flow.calculateDist(pos: pos as! [Double])
    
    let gen = flow.generators[0]
    flow.genMixers[0].volume = distance < (flow.distanceThreshold - 0.1) ? sinVol : max(0, ((flow.distanceThreshold - distance)/0.1*sinVol))
    
    if let osc = gen as? AKOscillator {
      osc.frequency = 30 + 970 * (1 - (distance/(flow.distanceThreshold)))
    }
    
    var _yaw = yaw
    if gravY > 0 {
      let negative = (yaw < 0)
      
      if negative {
        _yaw = -1 - (abs(gravY))
      } else {
        _yaw = 1 + (abs(gravY))
      }
    }
    
    let conv = flow.drywets[0][0]
    conv.balance = max(0.01, (_yaw/4) + 0.25)
  }
  
}

// MARK -- Guitar Room
class RoomGuitar: Room {
  
  private let distanceThresholds = [1.0]
  
  override init(){
    super.init()
    
  }
  
  func updateFlows(pos: NSArray, yaw: Double, gravY: Double){
    
    if flows.count == 0 {
      return
    }
    
  }
  
  
}


// MARK -- Alien Room
class RoomAlien: Room {
  
  private let distanceThresholds = [0.9, 1.8]
  private var basePitchFactor = 0.875
  private var basePitch = 0.0
  
  override init(){
    super.init()
    
    let revFB = 0.4
    let revCO = 1200.0
    
    let file = try! AKAudioFile(readFileName: "alien lo.m4a")
    let sampler = AKWaveTable()
    let rev = AKCostelloReverb()
    rev.feedback = revFB
    rev.cutoffFrequency = revCO
    
    sampler.load(file: file)
    
    let flow0 = Flow(room: self,
      gens: [sampler],
      FX: [[AKPitchShifter(), AKBooster(gain: 2.5), rev]],
      distThresh: distanceThresholds[0],
      pos: [-0.4, -0.2, -1])
    
    flows.append(flow0)
    
    let rev2 = AKCostelloReverb()
    rev2.feedback = revFB
    rev2.cutoffFrequency = revCO
    
    let flow1 = Flow(room: self,
                     gens: [sampler],
                     FX: [[AKPitchShifter(), AKBooster(gain: 2.5), rev2]],
                     distThresh: distanceThresholds[0],
                     pos: [0.4, -0.2, -1])
    
    flows.append(flow1)
    
    sampler.loopStartPoint = 0
    sampler.loopEndPoint = (44100 * 18)
    
    let file2 = try! AKAudioFile(readFileName: "alien hi.m4a")
    let sampler2 = AKWaveTable()
    
    sampler2.load(file: file2)
    
    let flow2 = Flow(room: self,
                     gens: [sampler2],
                     FX: [[AKPanner(), AKPitchShifter(), AKCostelloReverb(feedback: 0.8, cutoffFrequency: 2400)]],
                     distThresh: distanceThresholds[1],
                     pos: [0, 0.2, -1.5])
    
    flows.append(flow2)
    
  }
  
  override func startFlows() {
    if let sampler = flows[0].generators[0] as? AKWaveTable {
      sampler.loopEnabled = true
      sampler.play(from: 44100, to: (44100*18))
    }
    
    if let sampler2 = flows[2].generators[0] as? AKWaveTable {
      sampler2.loopEnabled = false
    }
  }
  
  func updateFlows(pos: NSArray, yaw: Double, gravY: Double){
    
    if flows.count == 0 {
      return
    }
    
    // flows 0 && 1
    var currentFlow = -1
    for flow in flows[0...1]{
      currentFlow += 1
      let distance = flow.calculateDist(pos: pos as! [Double])
    
      flow.genMixers[0].volume = (1 - (distance/(flow.distanceThreshold)))
      
      var _yaw = yaw
      if gravY > 0 {
        let negative = (yaw < 0)
        
        if negative {
          _yaw = -1 - (abs(gravY))
        } else {
          _yaw = 1 + (abs(gravY))
        }
      }
      
      if currentFlow == 0 {
        _yaw -= 1.75
      } else if currentFlow == 1 {
        _yaw *= -1
        _yaw += 1.75
      }
      
      if let pitchShift = flow.effects[0][0] as? AKPitchShifter {
        pitchShift.shift = _yaw
      }
      
      
    }
    
    // flow 2
    
    let flow2 = flows[2]
    let flow2MaxVol = 0.7
    let flow2Vol = 0.2
    let distance = flow2.calculateDist(pos: pos as! [Double])
    flow2.genMixers[0].volume = distance < (flow2.distanceThreshold - 0.1) ? (flow2Vol + ((flow2.distanceThreshold - distance)/(flow2.distanceThreshold - 0.1)*(flow2MaxVol-flow2Vol))) : max(0, ((flow2.distanceThreshold - distance)/0.1*flow2Vol))
    basePitch = 1.75 - distance
    basePitchFactor = 0.875 + ((distanceThresholds[1] - distance)/2)
    
    if let pan = flows[2].effects[0][0] as? AKPanner {
      pan.pan = pos[0] as! Double
    }
  
  }
  
  
  func playSampler(){
    var pitchshift = basePitchFactor * (Int.random(in: 0 ..< 10))
    pitchshift += basePitch
    
    if let pitchShifter = flows[2].effects[0][1] as? AKPitchShifter {
      pitchShifter.shift = pitchshift
    }
    
    if let sampler = flows[2].generators[0] as? AKWaveTable {
      sampler.play()
    }
  }
  
}



// MARK -- Room Superclass
class Room {
  
  var mixer = AKMixer()
  open var flows = [Flow]()
  
  func startFlows(){
    for flow in flows {
      flow.startGens()
    }
  }
  
}
