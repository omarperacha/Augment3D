//
//  room.swift
//  Augment3d
//
//  Created by Omar Peracha on 03/03/2019.
//  Copyright © 2019 Omar Peracha. All rights reserved.
//

import Foundation
import AudioKit

class RoomZero: Room {
  
  private let distanceThresholds = [1.0]
  
  override init(){
    super.init()
    
    let fileUrl = Bundle(for: type(of: self)).url(forResource: "Locked bass IR_1", withExtension:"wav")
    
    let conv = AKConvolution(impulseResponseFileURL: fileUrl!)
    
    let flow0 = Flow(room: self,
                     gens: [AKOscillator()],
                     FX: [[conv]],
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
    let distance = flow.calculateDist(pos: pos as! [Double])
    
    let gen = flow.generators[0]
    flow.genMixers[0].volume = distance < 1 ? 0.5 : 0
    
    if let osc = gen as? AKOscillator {
      osc.frequency = 110 + 770 * (1 - (distance/(flows[0].distanceThreshold)))
    }
    
    let conv = flows[0].drywets[0][0]
    conv.balance = max(0, ((-1 * yaw)/360) + 0.25)
  }
  
}

class Room {
  
  var mixer = AKMixer()
  open var flows = [Flow]()
  
  func startFlows(){
    for flow in flows {
      flow.startGens()
    }
  }
  
}
