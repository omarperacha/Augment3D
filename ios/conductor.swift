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
  private var mixer = AKMixer()
  private var generators = [AKOscillator]()
  private let distanceThresholds = [1.0]
  
  @objc(setup)
  func setup() {
    AKSettings.playbackWhileMuted = true
    
    osc0 >>> mixer
    osc0.amplitude = 0
    generators.append(osc0)
    
    AudioKit.output = mixer
    
    do {
      try AudioKit.start()
    } catch {print(error.localizedDescription)}
    
    osc0.start()
  }
  
  @objc(updateAmp: idx:)
  func updateAmp(distance: NSNumber, idx: NSInteger) {
    
    if generators.count <= idx {
      return
    }
    print("000_ disctance \(distance)")
    let gen = generators[idx]
    
    gen.amplitude = 1 - ((abs(Float(truncating: distance)))/(distanceThresholds[idx]))
    
  }
  
}
