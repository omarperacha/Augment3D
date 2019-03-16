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
    
    let table0 = AKTable(.sine)
    let table1 = AKTable(.triangle)
    let tables = [table0, table0, table1, table1]
    
    let flow0 = Flow(room: self,
                     //to do - make gen morphing oscillator
                     gens: [AKMorphingOscillator(waveformArray: tables)],
                     FX: [[conv, convHP, convReduce, AKPeakLimiter()]],
                     distThresh: distanceThresholds[0],
                     pos: [0, 0, -5])
    
    flows.append(flow0)
    
  }
  
  func updateFlows(pos: NSArray, yaw: Double, gravY: Double, forward: Double){
    
    if flows.count == 0 {
      return
    }
    
    updateFlow0(pos: pos, yaw: yaw, gravY: gravY, forward: forward)
    
  }
  
  private func updateFlow0(pos: NSArray, yaw: Double, gravY: Double, forward: Double){
    
    let flow = flows[0]
    let sinVol = 0.3
    let distance = flow.calculateDist(pos: pos as! [Double])
    
    let gen = flow.generators[0]
    flow.genMixers[0].volume = distance < (flow.distanceThreshold - 0.1) ? sinVol : max(0, ((flow.distanceThreshold - distance)/0.1*sinVol))
    
    if let osc = gen as? AKMorphingOscillator {
      osc.frequency = 30 + 970 * (1 - (distance/(flow.distanceThreshold)))
      osc.index = (1 + forward) * 1.5
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


// MARK -- Bass Room
class RoomBass: Room {
  
  private let distanceThresholds = [1.8]
  
  private var tables = [AKTable]()
  
  override init(){
    super.init()
    
    let fileUrl = Bundle(for: type(of: self)).url(forResource: "death clock lo", withExtension:"wav")
    let file = try! AKAudioFile(forReading: fileUrl!)
    
    
    let table0 = AKTable(.zero)
    for i in 0..<table0.count {
      table0[i] = file.floatChannelData![0][i + 88200]
    }
    table0.invert()
    tables.append(table0)
    let table1 = AKTable(.triangle)
    tables.append(table1)
    let table2 = AKTable(.zero)
    for i in 0..<table2.count {
      table2[i] = AKTable.Element(random(in: -1...1))
    }
    tables.append(table2)
    let table3 = AKTable(.square)
    tables.append(table3)
    
    let gen = AKMorphingOscillator(waveformArray: tables)
    gen.frequency = 53.434
    
    let gen2 = AKOscillator()
    gen2.frequency = (gen.frequency/2)
    gen2.amplitude = 0.2
    
    let flow = Flow(room: self,
                    gens: [gen, gen2],
                    FX: [[AKPitchShifter(),
                          AKKorgLowPassFilter(cutoffFrequency: 30, resonance: 1.4),
                      AKBooster(gain: 1),
                      AKCostelloReverb()]],
                    distThresh: distanceThresholds[0],
                    pos: [-2, -1.6, -1])
    
    flows.append(flow)
  }
  
  func updateFlows(pos: NSArray, yaw: Double, gravY: Double, forward: Double){
    
    if flows.count == 0 {
      return
    }
    let flow = flows[0]
    
    let vol = 0.5
    let distance = flow.calculateDist(pos: pos as! [Double])
    
    if let gen = flow.generators[0] as? AKMorphingOscillator {
      gen.index = (1 + (forward))
    }
    
    flow.genMixers[0].volume = distance < (flow.distanceThreshold - 0.2) ? vol : max(0, ((flow.distanceThreshold - distance)/0.2*vol))
    
    var _yaw = yaw
    if gravY > 0 {
      let negative = (yaw < 0)
      
      if negative {
        _yaw = -1 - (abs(gravY))
      } else {
        _yaw = 1 + (abs(gravY))
      }
      
      _yaw *= 0.875
    }
    
    if let pitch = flow.effects[0][0] as? AKPitchShifter {
      pitch.shift = _yaw
    }
    
    if let filter = flow.effects[0][1] as? AKKorgLowPassFilter {
      filter.cutoffFrequency = 30 + ((distanceThresholds[0] - distance) * 2000)
    }
    
  }
  
  override func startFlows() {
    super.startFlows()
    if let revDW = flows[0].drywets[0].last {
      revDW.balance = 0.3
    }
    if let gen = flows[0].generators[0] as? AKMorphingOscillator {
      gen.start()
    }
  }
  
  
}


// MARK -- Alien Room
class RoomAlien: Room {
  
  private let distanceThresholds = [0.95, 1.8]
  private let delFB = 0.22
  private let delLP = 1000.0
  private let boost = 3.0
  
  private var pulseStep = 0
  private var pulseProb = 0.99
  private var basePitchFactor = 0.875
  private var basePitch = 0.0
  
  override init(){
    super.init()
    
    let file = try! AKAudioFile(readFileName: "alien lo.m4a")
    let sampler = AKWaveTable()
    let del = AKDelay()
    del.lowPassCutoff = delLP
    
    sampler.load(file: file)
    
    let flow0 = Flow(room: self,
      gens: [sampler],
      FX: [[AKPitchShifter(), AKBooster(gain: boost), del]],
      distThresh: distanceThresholds[0],
      pos: [-0.5, -0.2, -3])
    
    flows.append(flow0)
    
    let del2 = AKDelay()
    del2.lowPassCutoff = delLP
    
    let flow1 = Flow(room: self,
                     gens: [sampler],
                     FX: [[AKPitchShifter(), AKBooster(gain: boost), del2]],
                     distThresh: distanceThresholds[0],
                     pos: [0.5, -0.2, -3])
    
    flows.append(flow1)
    
    let file2 = try! AKAudioFile(readFileName: "alien hi.m4a")
    let sampler2 = AKWaveTable()
    
    sampler2.load(file: file2)
    
    let flow2 = Flow(room: self,
                     gens: [sampler2],
                     FX: [[AKPanner(), AKPitchShifter(), AKCostelloReverb(feedback: 0.8, cutoffFrequency: 2400)]],
                     distThresh: distanceThresholds[1],
                     pos: [0, 0.2, -3.8])
    
    flows.append(flow2)
    
  }
  
  override func startFlows() {
    if let sampler = flows[0].generators[0] as? AKWaveTable {
      sampler.loopEnabled = true
    
      sampler.play(from: 0, to: 44100*36)
      sampler.loopStartPoint = 44100*6
      sampler.loopEndPoint = 44100*28
    }
    
    if let sampler2 = flows[2].generators[0] as? AKWaveTable {
      sampler2.loopEnabled = false
    }
    
    flows[0].drywets[0][2].balance = delFB
    flows[1].drywets[0][2].balance = delFB
    
  }
  
  func updateFlows(pos: NSArray, yaw: Double, gravY: Double){
    
    if flows.count == 0 {
      return
    }
    
    // flows 0 && 1
    
    if let sampler = flows[0].generators[0] as? AKWaveTable {
      let fadelength = 0.05
      
      //fadeout
      if sampler.position > (4*(Double(sampler.loopEndPoint) - 16*fadelength*44100)) {
        sampler.volume = max(0.01, 2*((Double(4*sampler.loopEndPoint) - sampler.position)/(16*fadelength*44100))-7)
      pulseStep = 0
      //fadein
      } else if sampler.position < (4*(Double(sampler.loopStartPoint) + 2*fadelength*44100)) {
        sampler.volume = max(0.01, -1 * ((Double(4*sampler.loopStartPoint) - sampler.position)/(8*fadelength*44100)))
      pulseStep = 0
      //do pulse
      } else if pulseStep == 0 && random(in: 0...1) > pulseProb {
        pulseStep += 1
        sampler.volume += 0.1
        
      //continue pulse
      } else if pulseStep != 0 {
        pulseStep = (pulseStep + 1) % 20
        let _pulseStep = pulseStep > 10 ? (20 - pulseStep) : pulseStep
        sampler.volume = 1 + (_pulseStep/10)
        
      //default
      } else if sampler.volume != 1 {
        sampler.volume = 1
      }
      
    }
    
    var currentFlow = -1
    for flow in flows[0...1]{
      currentFlow += 1
      let distance = flow.calculateDist(pos: pos as! [Double])
      let dist2 = flows[2].calculateDist(pos: pos as! [Double])
    
      flow.genMixers[0].volume = (1 - (distance/(flow.distanceThreshold)))
      if let del = flow.effects[0][2] as? AKDelay {
        del.lowPassCutoff = delLP + ((distanceThresholds[1] - dist2) * (3*delLP))
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
      
      if currentFlow == 0 {
        _yaw -= 1.75
        pulseProb = distance/(distanceThresholds[0]) + 0.66
      } else if currentFlow == 1 {
        _yaw *= -1
        _yaw += 1.75
      }
      
      if let pitchShift = flow.effects[0][0] as? AKPitchShifter {
        pitchShift.shift = _yaw
      }
    }
    
    // flow 2
    
    let flow2 = flows[2]
    let flow2MaxVol = 0.7
    let flow2Vol = 0.2
    let distance = flow2.calculateDist(pos: pos as! [Double])
    flow2.genMixers[0].volume = distance < (flow2.distanceThreshold - 0.1) ? (flow2Vol + ((flow2.distanceThreshold - distance)/(flow2.distanceThreshold - 0.1)*(flow2MaxVol-flow2Vol))) : max(0, ((flow2.distanceThreshold - distance)/0.1*flow2Vol))
    basePitch = 5.25 - distance
    basePitchFactor = 0.875 + ((distanceThresholds[1] - distance)/2)
    
    if let pan = flows[2].effects[0][0] as? AKPanner {
      pan.pan = pos[0] as! Double
    }
    
  
  }
  
  
  func playSampler(){
    var pitchshift = basePitchFactor * (Int.random(in: 0 ..< 4))
    pitchshift += basePitch
    
    if let pitchShifter = flows[2].effects[0][1] as? AKPitchShifter {
      pitchShifter.shift = pitchshift
    }
    
    if let sampler = flows[2].generators[0] as? AKWaveTable {
      sampler.play()
    }
  }
  
}


// MARK -- Pure Room
class RoomPure: Room {
  
  let distanceThresholds = [1.0]
  
  override init() {
    super.init()
    
    
    let noise = AKWhiteNoise()
    
    let flow1 = Flow(room: self,
                     gens: [noise],
                     FX: [[AKKorgLowPassFilter(cutoffFrequency: 30, resonance: 1.4, saturation: 1.1)]],
                     distThresh: self.distanceThresholds[0], pos: [0, 0, -1])
    flows.append(flow1)
  }
  
  func updateFlows(pos: NSArray, yaw: Double, gravY: Double, forward: Double){
    
    if flows.count == 0 {
      return
    }
    
    let flow = flows[0]
    
    let vol = 0.5
    let distance = flow.calculateDist(pos: pos as! [Double])
    
    flow.genMixers[0].volume = (distance < (flow.distanceThreshold - 0.2) ? vol : max(0, ((flow.distanceThreshold - distance)/0.2*vol)))*(forward)
    
    if let filter = flow.effects[0][0] as? AKKorgLowPassFilter {
      filter.cutoffFrequency = 30 + ((distanceThresholds[0] - distance) * 2000)
    }
    
    var _yaw = yaw
    if gravY > 0 {
      let negative = (yaw < 0)
      
      if negative {
        _yaw = -1 - (abs(gravY))
      } else {
        _yaw = 1 + (abs(gravY))
      }
      
      _yaw *= 0.875
    }
    
  }
  
  override func startFlows() {
    super.startFlows()
    
    if let noise = flows[0].generators[0] as? AKWhiteNoise {
      noise.start()
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
