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
                     pos: [0, 0, -1])
    
    flows.append(flow0)
    
  }
  
  func updateFlows(pos: NSArray, yaw: NSNumber){
    
    if flows.count == 0 {
      return
    }
    
    updateFlow0(pos: pos, yaw: Float(truncating: yaw))
    
  }
  
  private func updateFlow0(pos: NSArray, yaw: Float){
    
    let flow = flows[0]
    let sinVol = 0.3
    let distance = flow.calculateDist(pos: pos as! [Double])
    
    let gen = flow.generators[0]
    flow.genMixers[0].volume = distance < (flow.distanceThreshold - 0.1) ? sinVol : max(0, ((flow.distanceThreshold - distance)/0.1*sinVol))
    
    if let osc = gen as? AKOscillator {
      osc.frequency = 30 + 970 * (1 - (distance/(flow.distanceThreshold)))
    }
    
    let conv = flow.drywets[0][0]
    conv.balance = max(0.01, ((-1 * yaw)/360) + 0.25)
  }
  
}

// MARK -- Guitar Room
class RoomGuitar: Room {
  
  private let distanceThresholds = [1.0]
  
  override init(){
    super.init()
    
  }
  
  func updateFlows(pos: NSArray, yaw: NSNumber){
    
    if flows.count == 0 {
      return
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
