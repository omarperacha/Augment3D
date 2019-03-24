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
    let roomBass = RoomBass()
    rooms.append(roomBass)
    let roomPure = RoomPure()
    rooms.append(roomPure)
    let roomGuitar = RoomGuitar()
    rooms.append(roomGuitar)
    
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
    
    lock.lock()
    defer {
      lock.unlock()
    }
    
    if let roomConv = rooms[0] as? RoomConv {
      roomConv.updateFlows(pos: pos, yaw: gravX, gravY: gravY, forward: forward[2] as! Double)
    }
    
    if let roomAlien = rooms[1] as? RoomAlien {
      roomAlien.updateFlows(pos: pos, yaw: gravX, gravY: gravY)
    }
    
    if let roomBass = rooms[2] as? RoomBass {
      roomBass.updateFlows(pos: pos, yaw: gravX, gravY: gravY, forward: forward[2] as! Double)
    }
    
    if let roomPure = rooms[3] as? RoomPure {
      roomPure.updateFlows(pos: pos, yaw: gravX, gravY: gravY, forward: forward[2] as! Double)
    }
    
    if let roomGuitar = rooms[4] as? RoomGuitar {
      roomGuitar.updateFlows(pos: pos, yaw: gravX, gravY: gravY, forward: forward[2] as! Double)
    }
  
  }
  
  @objc(touchDown:)
  func touchDown(location: NSString){
    
    if rooms.count <= 0 {
      return
    }
    
    if location == "alien" {
      if let roomAlien = rooms[1] as? RoomAlien {
        roomAlien.playSampler()
      }
    } else if location == "metalLo" {
      if let roomGuitar = rooms[4] as? RoomGuitar {
        roomGuitar.playSamplerLo()
      }
    } else if location == "metalHi" {
      if let roomGuitar = rooms[4] as? RoomGuitar {
        roomGuitar.playSamplerHi()
      }
    }
  }
  
  @objc(tearDown)
  func tearDown() {
    print("000_ CALLED TEAR DOWN")
  }
  
  
}
