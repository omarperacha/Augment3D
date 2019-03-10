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


// MARK -- Metal Room
class RoomAlien: Room {
  
  private let distanceThresholds = [1.0]
  
  override init(){
    super.init()
    
    let file = try! AKAudioFile(readFileName: "alien lo.m4a")
    let sampler = AKWaveTable()
    
    sampler.load(file: file)
    
    let flow0 = Flow(room: self,
      gens: [sampler],
      FX: [[AKPitchShifter()]],
      distThresh: distanceThresholds[0],
      pos: [0, 0, -1])
    
    flows.append(flow0)
    
  }
  
  func updateFlows(pos: NSArray, yaw: Double, gravY: Double){
    
    if flows.count == 0 {
      return
    }
  
  }
  
  func playSampler(){
    
    if let sampler = flows[0].generators[0] as? AKWaveTable {
      flows[0].genMixers[0].volume = 1
      sampler.loopEnabled = true
      sampler.play()
    }
  }
  
  override func startFlows() {
    playSampler()
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
