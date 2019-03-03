//
//  flow.swift
//  Augment3d
//
//  Created by Omar Peracha on 03/03/2019.
//  Copyright © 2019 Omar Peracha. All rights reserved.
//

import Foundation
import AudioKit


class Flow {
  
  var distanceThreshold: Double = 100
  var generators = [AKNode]()
  var drywets = [[AKDryWetMixer]]()
  var genMixers = [AKMixer]()
  
  
  private var output = AKMixer()
  private var effects = [[AKNode]]()
  
  // Mark - initialisation
  init(room: Room, gens: [AKNode], FX: [[AKNode]]? = nil, distThresh: Double){
    
    distanceThreshold = distThresh
    
    generators = gens
    if FX != nil {
      effects = FX!
    }
    
    for generator in generators{
      let mixer = AKMixer(generator)
      mixer.volume = 0
      genMixers.append(mixer)
    }
    
    for i in effects.indices{
      let inMixer = genMixers[i]
      var drywetChain = [AKDryWetMixer]()
      for j in effects[i].indices{
        
        var drywet = AKDryWetMixer()
        if j == 0 {
          inMixer.setOutput(to: effects[i][j].avAudioNode)
          drywet = AKDryWetMixer(inMixer, effects[i][j])
        } else {
          // to do - make iteration safe
          drywets[i][j - 1].connect(to: effects[i][j].avAudioNode)
          drywet = AKDryWetMixer(drywets[i][j - 1], effects[i][j])
        }
        
        drywet.balance = 0
        drywetChain.append(drywet)
      }
      
      drywets.append(drywetChain)
    }
  
    if let findalDW = drywets.last?.last {
      findalDW >>> output
    } else {
      genMixers.last! >>> output
    }
    
    output >>> room.mixer
  }
  
  
  // Mark - private functionality
  
  func startGens(){
    for generator in generators {
      if let gen = generator as? AKOscillator {
        gen.start()
      } else if let gen = generator as? AKWaveTable {
        gen.start()
      }
    }
    
    for i in effects.indices {
      for FX in effects[i] {
        
        if let fx = FX as? AKConvolution {
          fx.start()
        }
        
      }
    }
    
  }
  
  
  
}
