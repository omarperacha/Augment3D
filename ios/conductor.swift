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
  
  @objc(setup)
  func setup() {
    AKSettings.playbackWhileMuted = true
    
    osc0 >>> mixer
    osc0.amplitude = 0.5
    AudioKit.output = mixer
    
    do {
      try AudioKit.start()
    } catch {print(error.localizedDescription)}
    
    osc0.start()
  }
  
}
