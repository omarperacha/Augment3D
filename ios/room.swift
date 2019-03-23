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
  
  private let distanceThresholds = [1.5]
  private let dcBaseRate = 350
  
  private var callCount = 350
  private var dcModuLo = 500
  private var basePitchLo = 0.0
  private var pitchFactorLo = 1.0
  private var basePitchHi = 0.0
  private var pitchFactorHi = 1.0
  
  override init(){
    super.init()
    
    let fileUrl = Bundle(for: type(of: self)).url(forResource: "death clock lo", withExtension:"wav")
    let  dcFile = try! AKAudioFile(forReading: fileUrl!)
    let dcSampler = AKWaveTable(file: dcFile)
    
    let fileUrl1 = Bundle(for: type(of: self)).url(forResource: "death clock hi", withExtension:"m4a")
    let  dcHiFile = try! AKAudioFile(forReading: fileUrl1!)
    let dcHiSampler = AKWaveTable(file: dcHiFile)
    
    let fileUrl2 = Bundle(for: type(of: self)).url(forResource: "freaky hi", withExtension:"m4a")
    let  frHiFile = try! AKAudioFile(forReading: fileUrl2!)
    let frHiSampler = AKWaveTable(file: frHiFile)
    
    
    let flow0 = Flow(room: self,
                     gens: [dcSampler, dcHiSampler, frHiSampler],
                     FX: [[AKPitchShifter(), AKCostelloReverb(feedback: 0.4), AKCompressor()],
                          [AKCostelloReverb(feedback: 0.9, cutoffFrequency: 1000)],
                          [AKCostelloReverb(feedback: 0.9, cutoffFrequency: 1000)]],
                     distThresh: distanceThresholds[0],
                     pos: [0, 0, -1.5])
    
    flows.append(flow0)
    
    let fileUrl4 = Bundle(for: type(of: self)).url(forResource: "metal lo", withExtension:"m4a")
    let  mlFile = try! AKAudioFile(forReading: fileUrl4!)
    let mlSampler = AKWaveTable(file: mlFile)
    
    let flow1 = Flow(room: self,
                     gens: [mlSampler],
                     FX: [[AKPanner(), AKPitchShifter()]],
                     distThresh: distanceThresholds[0],
                     pos: [-0.5, 0.3, -1.25])
    
    flows.append(flow1)
    
    let fileUrl5 = Bundle(for: type(of: self)).url(forResource: "metal hi", withExtension:"m4a")
    let  mhFile = try! AKAudioFile(forReading: fileUrl5!)
    let mhSampler = AKWaveTable(file: mhFile)
    
    let flow2 = Flow(room: self,
                     gens: [mhSampler],
                     FX: [[AKPanner(), AKPitchShifter()]],
                     distThresh: distanceThresholds[0],
                     pos: [-0.5, 0.3, -1.25])
    
    flows.append(flow2)
    
  }
  
  
  
  func updateFlows(pos: NSArray, yaw: Double, gravY: Double, forward: Double){
    
    if flows.count == 0 {
      return
    }
    
    let flow0 = flows[0]
    let distance = flow0.calculateDist(pos: pos as! [Double])
    
    if (pos[2] as! Double) < -1.5 || distance > flow0.distanceThreshold {
      callCount = 0
    } else {
      callCount += 1
    }
    
    if callCount >= dcModuLo {
      playSamplerDCLo()
      callCount = 0
    }
    
    let flow0MaxVol = 0.5
    let flow0Vol = 0.1
    flow0.drywets[0][1].balance = distance/3
    flow0.genMixers[0].volume = distance < (flow0.distanceThreshold - 0.1) ? (flow0Vol + ((flow0.distanceThreshold - distance)/(flow0.distanceThreshold - 0.1)*(flow0MaxVol-flow0Vol))) : max(0, ((flow0.distanceThreshold - distance)/0.1*flow0Vol))
    
    dcModuLo = 1 + Int(distance*dcBaseRate)
    
    var _yaw = yaw
    if gravY > 0 {
      let negative = (yaw < 0)
      
      if negative {
        _yaw = -1 - (abs(gravY))
      } else {
        _yaw = 1 + (abs(gravY))
      }
      
    }
    
    // hi samplers
    for i in 1...2 {
      
      let _forward = forward * ((i == 1) ? -1 : 1)
      
      flow0.drywets[i][0].balance = distance/4
      
      let volMul = max(0, 0.5 * Double.minimum(1, _forward + 0.5))
      
      flow0.genMixers[i].volume = max(0.0, ((_yaw + 1) * volMul))
      
    }
    
    // flows 1 & 2
    var currentFlow = 0
    for flow in flows[1...2] {
      
      currentFlow += 1
      
      let flowMaxVol = 0.5
      let flowVol = 0.15
      let distance = flow.calculateDist(pos: pos as! [Double])
      flow.genMixers[0].volume = distance < (flow.distanceThreshold - 0.1) ? (flowVol + ((flow.distanceThreshold - distance)/(flow.distanceThreshold - 0.1)*(flowMaxVol-flowVol))) : max(0, ((flow.distanceThreshold - distance)/0.1*flowVol))
      
      if let pan = flow.effects[0][0] as? AKPanner {
        pan.pan = flow.calculatePan(pos: pos as! [Double], forward: forward)*2
      }
      
      if currentFlow == 1 {
        basePitchLo = 0.875 - distance
        pitchFactorLo = 0.875 + ((flow.distanceThreshold - distance)/2)
      } else if currentFlow == 2 {
        basePitchHi = 5.25 * (1 - (distance/flow.distanceThreshold))
        pitchFactorHi = 0.875 + ((flow.distanceThreshold - distance))
      }
      
    }

    
    
    
  }
  
  override func startFlows() {
    for i in flows[0].generators.indices {
      if let sampler = flows[0].generators[i] as? AKWaveTable {
        if i != 0 {
          sampler.loopEnabled = true
          sampler.start()}
      }
    }
    
  }
  
  func playSamplerLo(){
    var pitchshift = pitchFactorLo * (Int.random(in: 0 ..< 4))
    pitchshift += basePitchLo
    
    if let pitchShifter = flows[1].effects[0][1] as? AKPitchShifter {
      pitchShifter.shift = pitchshift
    }
    
    if let sampler = flows[1].generators[0] as? AKWaveTable {
      sampler.play()
    }
  }
  
  func playSamplerHi(){
    var pitchshift = pitchFactorHi * (Int.random(in: 0 ..< 5))
    pitchshift += basePitchHi
    
    if let pitchShifter = flows[2].effects[0][1] as? AKPitchShifter {
      pitchShifter.shift = pitchshift
    }
    
    if let sampler = flows[2].generators[0] as? AKWaveTable {
      sampler.play()
    }
  }
  
  private func playSamplerDCLo(){
    
    if let pitch = flows[0].effects[0][0] as? AKPitchShifter {
      let prob = 1.0 - (dcModuLo/dcBaseRate)
      if random(in: 0...1) < prob {
        pitch.shift = random(in: (-1 * prob)...(prob))
      }
    }
    
    if let sampler = flows[0].generators[0] as? AKWaveTable {
      if sampler.volume != 1 {
        // if mid-fade
        return
      }
      //fadeout
      repeat {sampler.volume -= 0.02} while (sampler.volume > 0)
      sampler.stop()
      sampler.volume = 1
      sampler.play()
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
      
    }
    _yaw *= 0.875
    
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
  private let delT = 1.75
  private let boost = 3.0
  private let fadelength = 0.5
  
  private var basePitchFactor = 0.875
  private var basePitch = 0.0
  private var fadeDue = "Out"
  
  override init(){
    super.init()
    
    let file = try! AKAudioFile(readFileName: "alien lo.m4a")
    let sampler = AKWaveTable()
    let del = AKDelay()
    del.lowPassCutoff = delLP
    del.time = delT
    
    sampler.load(file: file)
    
    let flow0 = Flow(room: self,
      gens: [sampler],
      FX: [[AKPitchShifter(), AKBooster(gain: boost), del]],
      distThresh: distanceThresholds[0],
      pos: [-0.5, -0.2, -3])
    
    flows.append(flow0)
    
    let del2 = AKDelay()
    del2.lowPassCutoff = delLP
    del2.time = delT
    
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
                     FX: [[AKPitchShifter(), AKCostelloReverb(feedback: 0.8, cutoffFrequency: 2400)]],
                     distThresh: distanceThresholds[1],
                     pos: [0, 0.2, -3.8])
    
    flows.append(flow2)
    
  }
  
  override func startFlows() {
    if let sampler = flows[0].generators[0] as? AKWaveTable {
      sampler.loopEnabled = true
      sampler.loopStartPoint = 44100*6
      sampler.loopEndPoint = 44100*18
      sampler.play(from: 0, to: 44100*18)
      
      
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
      //fadeout
      if sampler.position > (3*(Double(sampler.loopEndPoint) - 2*fadelength*44100)) {
        sampler.volume = max(0, -1 + (3*(Double(sampler.loopEndPoint)) - sampler.position)/(1.5*2*fadelength*44100))
        setDel(val: 1 - sampler.volume)
        
        
      //fadein
      } else if sampler.position < (3*(Double(sampler.loopStartPoint) + 2*fadelength*44100)) {
         sampler.volume = max(0, -1 * ((3*(Double(sampler.loopStartPoint)) - sampler.position)/(3*2*fadelength*44100)))
        setDel(val: 1 - sampler.volume)
        
        
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
    
  
  }
  
  
  func playSampler(){
    var pitchshift = basePitchFactor * (Int.random(in: 0 ..< 4))
    pitchshift += basePitch
    
    if let pitchShifter = flows[2].effects[0][0] as? AKPitchShifter {
      pitchShifter.shift = pitchshift
    }
    
    if let sampler = flows[2].generators[0] as? AKWaveTable {
      sampler.play()
    }
  }
  
  func setDel(val: Double){
    for flow in flows[0...1]{
      flow.drywets[0][2].balance = delFB + (val/2)
    }
  }
  
}


// MARK -- Pure Room
class RoomPure: Room {
  
  private let distanceThresholds = [1.0, 0.5]
  
  private var oscs0 = [AKOscillator(), AKOscillator(), AKOscillator()]
  private var baseFreq0 = 322.0
  
  private var oscs1 = [AKOscillator(), AKOscillator(), AKOscillator()]
  private let freq1 = 322.0 * 1.1125
  private var baseFreq1 = 322.0 * 1.1125 {
    didSet {
      oscs1[0].frequency = baseFreq1/1.1125
      oscs1[2].frequency = baseFreq1*1.1125
    }
  }
  
  private var oscs2 = [AKOscillator(), AKOscillator(), AKOscillator()]
  private let freq2 = 322.0 * (1.225*1.1125)
  private var baseFreq2 = 322.0 * (1.225*1.1125) {
    didSet {
      oscs2[0].frequency = baseFreq2*1.225*1.1125
      oscs2[2].frequency = baseFreq2*1.225*1.1125
    }
  }
  
  
  override init() {
    super.init()
    
    //flow0
    let noise = AKWhiteNoise()
    oscs0[0].frequency = baseFreq0/1.225
    oscs0[1].frequency = baseFreq0
    oscs0[2].frequency = baseFreq0*1.225
    let mixer0 = AKMixer(oscs0)
    mixer0.volume = 1
    
    let flow0 = Flow(room: self,
                     gens: [noise, mixer0],
                     FX: [[AKKorgLowPassFilter(cutoffFrequency: 30, resonance: 1.4, saturation: 1.1)],[AKCostelloReverb()]],
                     distThresh: self.distanceThresholds[0], pos: [-3, 0, -1])
    flows.append(flow0)
    
    //flow1
    oscs1[1].frequency = baseFreq1
    let mixer1 = AKMixer(oscs1)
    mixer1.volume = 1
    
    let flow1 = Flow(room: self,
                     gens: [mixer1],
                     FX: [[AKCostelloReverb()]],
                     distThresh: self.distanceThresholds[0], pos: [-4.1, 0, 0])
    flows.append(flow1)
    
    
    //flow2
    oscs2[1].frequency = baseFreq2
    let mixer2 = AKMixer(oscs2)
    mixer2.volume = 1
    
    let flow2 = Flow(room: self,
                     gens: [mixer2],
                     FX: [[AKCostelloReverb()]],
                     distThresh: self.distanceThresholds[0], pos: [-1.9, 0, 0])
    flows.append(flow2)
    
  }
  
  func updateFlows(pos: NSArray, yaw: Double, gravY: Double, forward: Double){
    
    if flows.count == 0 {
      return
    }
    
    let flow = flows[0]
    
    let vol = 0.5
    let distance = flow.calculateDist(pos: pos as! [Double])
    let distance1 = flows[1].calculateDist(pos: pos as! [Double])
    let distance2 = flows[2].calculateDist(pos: pos as! [Double])
    
    flow.genMixers[0].volume = (distance < (flow.distanceThreshold - 0.2) ? vol : max(0, ((flow.distanceThreshold - distance)/0.2*vol)))*(forward)
    
    flow.genMixers[1].volume = 0.3 * max(0, (distanceThresholds[0] - distance))*(-1*forward)
    
    if let filter = flow.effects[0][0] as? AKKorgLowPassFilter {
      filter.cutoffFrequency = 30 + ((distanceThresholds[0] - distance) * 2000)
    }
    
    flows[1].genMixers[0].volume = 0.3 * max(0, (distanceThresholds[0] - distance1))
    baseFreq1 = freq1 + 2*forward*(sqrt(freq1))
    
    flows[2].genMixers[0].volume = 0.3 * max(0, (distanceThresholds[0] - distance2))
    baseFreq2 = freq2 + -1*forward*(sqrt(freq2))
    
    
    var _yaw = yaw
    if gravY > 0 {
      let negative = (yaw < 0)
      
      if negative {
        _yaw = -1 - (abs(gravY))
      } else {
        _yaw = 1 + (abs(gravY))
      }
    
    }
    
    oscs0[1].frequency = baseFreq0 + (_yaw*(baseFreq0/10))
    oscs1[1].frequency = baseFreq1 - (_yaw*(baseFreq1/(10/1.1125)))
    oscs2[1].frequency = baseFreq2 - (_yaw*(baseFreq2/(10/(1.225*1.1125))))
  }
  
  override func startFlows() {
    super.startFlows()
    
    for osc in oscs0 {
      osc.start()
    }
    
    for osc in oscs1 {
      osc.start()
    }
    
    for osc in oscs2 {
      osc.start()
    }
    
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
