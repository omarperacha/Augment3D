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
  private var initialised = false
  private var rooms = [Room]()
  private let lock = NSLock()
  
  @objc static func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  @objc(setup)
  func setup() {
    
    if initialised {
      return
    }
    
    lock.lock()
    defer {
      lock.unlock()
    }
    
    AKSettings.playbackWhileMuted = true
    
    let roomConv = RoomConv()
    rooms.append(roomConv)
    
    for room in rooms {
      room.mixer >>> mixer
    }
    
    AudioKit.output = mixer
    
    do {
      try AudioKit.start()
    } catch {print(error.localizedDescription)}
    
    for room in rooms {
      room.startFlows()
    }
    
    initialised = true
  }
  
  @objc(updateAmp: pitch: roll: yaw: forward:)
  func updateAmp(pos: NSArray, pitch: NSNumber, roll: NSNumber, yaw: NSNumber, forward: NSArray) {
    
    if rooms.count == 0 {
      return
    }
    
    //to-do mod yaw with forward vector[2]
    
    if let room0 = rooms[0] as? RoomConv {
      room0.updateFlows(pos: pos, yaw: yaw)
    }
    
  
  }
  
  
}
