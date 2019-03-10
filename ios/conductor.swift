//
//  conductor.swift
//  Augment3d
//
//  Created by Omar Peracha on 02/03/2019.
//  Copyright © 2019 Omar Peracha. All rights reserved.
//

import Foundation
import AudioKit
import CoreMotion

@objc(Conductor)
class Conductor: NSObject {
  
  var mixer = AKMixer()
  private var initialised = false
  private var rooms = [Room]()
  var gravX = 0.0
  var gravY = 0.0
  
  private let lock = NSLock()
  private let motionManager = CMMotionManager()
  
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
    let roomAlien = RoomAlien()
    rooms.append(roomAlien)
    
    for room in rooms {
      room.mixer >>> mixer
    }
    
    AudioKit.output = mixer
    
    if motionManager.isDeviceMotionAvailable {
      
      motionManager.deviceMotionUpdateInterval = 0.1
      
      motionManager.startDeviceMotionUpdates(to: OperationQueue()) { (motion, error) -> Void in
        
        if let gravity = motion?.gravity {
          self.gravX = gravity.x
          self.gravY = gravity.y
        }
        
      }
      
      print("Device motion started")
    }
    else {
      print("Device motion unavailable")
    }
    
    do {
      try AudioKit.start()
    } catch {print(error.localizedDescription)}
    
    for room in rooms {
      room.startFlows()
    }
    
    initialised = true
  }
  
  @objc(updateAmp: forward:)
  func updateAmp(pos: NSArray, forward: NSArray) {
    
    if rooms.count == 0 {
      return
    }
    
    if let room0 = rooms[0] as? RoomConv {
      room0.updateFlows(pos: pos, yaw: gravX, gravY: gravY)
    }
    
    if let roomAlien = rooms[1] as? RoomAlien {
      roomAlien.updateFlows(pos: pos, yaw: gravX, gravY: gravY)
    }
  
  }
  
  
}
