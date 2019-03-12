//
//  conductorBridge.m
//  Augment3d
//
//  Created by Omar Peracha on 02/03/2019.
//  Copyright © 2019 Omar Peracha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(Conductor, NSObject)

RCT_EXTERN_METHOD(setup)

RCT_EXTERN_METHOD(updateAmp:(nonnull NSArray *)pos forward:(nonnull NSArray *)forward)

RCT_EXTERN_METHOD(touchDown:(NSString *)location)

@end
