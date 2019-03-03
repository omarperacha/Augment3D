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
  
  private var rooms = [Room]()
  private let lock = NSLock()
  
  @objc static func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  @objc(setup)
  func setup() {
    
    lock.lock()
    defer {
      lock.unlock()
    }
    
    AKSettings.playbackWhileMuted = true
    
    let room0 = RoomZero()
    rooms.append(room0)
    
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
    
  }
  
  @objc(updateAmp: idx:)
  func updateAmp(distance: NSNumber, idx: NSInteger) {
    
    if rooms.count == 0 {
      return
    }
    
    if let room0 = rooms[0] as? RoomZero {
      room0.updateFlows(distance: distance)
    }
  
  }
  
  
}
