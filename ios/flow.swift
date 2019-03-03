//
//  flow.swift
//  Augment3d
//
//  Created by Omar Peracha on 03/03/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

import Foundation
import AudioKit


class Flow {
  
  private var generators = [AKNode]()
  private var genMixers = [AKMixer]()
  private var effects = [[AKNode]]()
  private var drywets = [[AKDryWetMixer]]()
  private var output = AKMixer()
  private var distanceThreshold: Double = 100
  
  private var distUpdate : ((Float)->Void)?
  private var rollUpdate : ((Float)->Void)?
  private var yawUpdate : ((Float)->Void)?
  
  // Mark - initialisation
  init(conductor: Conductor, gens: [AKNode], FX: [[AKNode]]? = nil, distThresh: Double){
    
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
          effects[i][j].connect(to: inMixer.outputNode)
          drywet = AKDryWetMixer(inMixer, effects[i][j])
        } else {
          effects[i][j].connect(to: drywets[i][j - 1].outputNode)
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
    
    output >>> conductor.mixer
    
    startGens()
  }
  
  func setupDistUpdate(withFunc: @escaping (Float)->Void){
    distUpdate = withFunc
  }
  
  func setupRollUpdate(withFunc: @escaping (Float)->Void){
    rollUpdate = withFunc
  }
  
  func setupYawUpdate(withFunc: @escaping (Float)->Void){
    yawUpdate = withFunc
  }
  
  // Mark - public functionality
  func update(distance: NSNumber, roll: NSNumber, yaw: NSNumber){
    if distUpdate != nil{
      distUpdate!(Float(truncating: distance))
    }
    
    if rollUpdate != nil{
      rollUpdate!(Float(truncating: roll))
    }
    
    if yawUpdate != nil{
      yawUpdate!(Float(truncating: yaw))
    }
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
  }
  
  
  
}
