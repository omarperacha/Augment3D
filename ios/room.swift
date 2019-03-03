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
    
    let flow0 = Flow(room: self, gens: [AKOscillator()], FX: [[conv]], distThresh: distanceThresholds[0])
    flows.append(flow0)
    
  }
  
  func updateFlows(distance: NSNumber){
    
    if flows.count == 0 {
      return
    }
    updateFlow0(distance: abs(Float(truncating: distance)))
    
  }
  
  private func updateFlow0(distance: Float){
    
    let gen = flows[0].generators[0]
    flows[0].genMixers[0].volume = distance < 1 ? 0.5 : 0
    
    if let osc = gen as? AKOscillator {
      osc.frequency = 110 + 770 * (1 - (distance/(flows[0].distanceThreshold)))
    }
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
