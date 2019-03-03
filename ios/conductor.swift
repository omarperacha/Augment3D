//
//  conductor.swift
//  Augment3d
//
//  Created by Omar Peracha on 02/03/2019.
//  Copyright © 2019 Omar Peracha. All rights reserved.
//

import Foundation
import AudioKit

@objc(Conductor)
class Conductor: NSObject {
  
  var mixer = AKMixer()
  
  private let distanceThresholds = [1.0]
  private var flows = [Flow]()
  
  @objc static func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  static let shared = Conductor()
  
  @objc(setup)
  func setup() {
    AKSettings.playbackWhileMuted = true
    
    let fileUrl = Bundle(for: type(of: self)).url(forResource: "Locked bass IR_1", withExtension:"wav")
    
    let conv = AKConvolution(impulseResponseFileURL: fileUrl!)
    
    let flow0 = Flow(conductor: self, gens: [AKOscillator()], FX: [[conv]], distThresh: distanceThresholds[0])
    flows.append(flow0)
    
    AudioKit.output = mixer
    
    do {
      try AudioKit.start()
    } catch {print(error.localizedDescription)}
    
    for flow in flows {
      flow.startGens()
    }
    
  }
  
  @objc(updateAmp: idx:)
  func updateAmp(distance: NSNumber, idx: NSInteger) {
    
    if flows.count == 0 {
      return
    }
    
    updateFlow0(distance: abs(Float(truncating: distance)))
    
  }
  
  func updateFlow0(distance: Float){
    let gen = flows[0].generators[0]
    flows[0].genMixers[0].volume = distance < 1 ? 0.5 : 0
    
    if let osc = gen as? AKOscillator {
      osc.frequency = 110 + 770 * (1 - (distance/(flows[0].distanceThreshold)))
    }
  }
  
}
