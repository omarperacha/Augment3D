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
  
  private var osc0 = AKOscillator()
  var mixer = AKMixer()
  private var generators = [AKOscillator]()
  private var conv : AKConvolution!
  private var dryWet = AKDryWetMixer()
  private let distanceThresholds = [1.0]
  
  let fileUrl = Bundle(for: type(of: self) as! AnyClass).url(forResource: "Locked bass IR_1", withExtension:"wav")
  
  @objc static func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  static let shared = Conductor()
  
  @objc(setup)
  func setup() {
    AKSettings.playbackWhileMuted = true
    
    conv = AKConvolution(impulseResponseFileURL: fileUrl!)
    
    osc0 >>> conv
  
    osc0.amplitude = 0
    generators.append(osc0)
    
    dryWet = AKDryWetMixer(osc0, conv)
    dryWet.balance = 0.2
    
    dryWet >>> mixer
    
    AudioKit.output = mixer
    
    do {
      try AudioKit.start()
    } catch {print(error.localizedDescription)}
    
    conv.start()
    osc0.start()
  }
  
  @objc(updateAmp: idx:)
  func updateAmp(distance: NSNumber, idx: NSInteger) {
    
    if generators.count <= idx {
      return
    }
    
    let gen = generators[idx]
    
    gen.amplitude = Float(truncating: distance) < 1 ? 0 : 0.5
    
    gen.frequency = 110 + 770 * (1 - ((abs(Float(truncating: distance)))/(distanceThresholds[idx])))
    
  }
  
}
