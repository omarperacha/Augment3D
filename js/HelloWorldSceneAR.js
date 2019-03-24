'use strict';

import React, { Component } from 'react';

import {StyleSheet, NativeModules} from 'react-native';

import {
  ViroARScene,
  ViroText,
  ViroConstants,
    ViroBox,
    ViroPolyline,
    ViroSphere,
    ViroMaterials
} from 'react-viro';

export default class HelloWorldSceneAR extends Component {

  constructor() {
    super();

    // Set initial state here
    this.state = {
    };

      this.conductor = NativeModules.Conductor
    // bind 'this' to functions
    this._onInitialized = this._onInitialized.bind(this);
      this._update = this._update.bind(this);
      this._onTouchAlien = this._onTouchAlien.bind(this)
      this._onTouchMetalLo = this._onTouchMetalLo.bind(this)
      this._onTouchMetalHi = this._onTouchMetalHi.bind(this)
  }

  render() {
    return (
            <ViroARScene onTrackingUpdated={this._onInitialized} onCameraTransformUpdate={this._update}>
            < // guitar
            ViroBox position={[0, 0, -1]} scale={[.3, .3, .3]} />
            <ViroBox position={[0.5, 0.3, -1]} scale={[.22, .22, .22]} rotation={[20, -30, 0]} materials={["black"]} onClick={this._onTouchMetalHi}/>
            <ViroBox position={[-0.5, 0.3, -1]} scale={[.22, .22, .22]} rotation={[20, 30, 0]} materials={["black"]} onClick={this._onTouchMetalLo}/>
            < // pure
            ViroPolyline position={[-3, 0, 1]} points={[[0,-1,0], [0,1,0.15]]} thickness={0.2} />
            <ViroPolyline position={[-1.9, 0, 0]} points={[[0,-1,0], [-0.15,1,0.15]]} thickness={0.2} />
            <ViroPolyline position={[-4.1, 0, 0]} points={[[0,-1,0], [0.15,1,0.15]]} thickness={0.2} />
            < // bass
            ViroPolyline position={[-3.5, -1.3, -1.75]} points={[[-.5,0,-.5], [0,.5,0], [.5,0,-.5], [0,.5,-1], [-.5,0,-.5]]} thickness={0.1} />
            < // alien
            ViroSphere position={[-1.5, -0.2, -3.5]} radius={.25} />
            <ViroSphere position={[-1.5, -0.2, -2.5]} radius={.25} />
            <ViroSphere position={[-2.3, 0.2, -3]} radius={.15} materials={["black"]} onClick={this._onTouchAlien} />
            < // conv
            ViroBox position={[0.5, 0, -3]} scale={[.3, .3, .3]} />
      </ViroARScene>
    );
  }

  _onInitialized(state, reason) {
    if (state == ViroConstants.TRACKING_NORMAL) {
        this.conductor.setup();
    } else if (state == ViroConstants.TRACKING_NONE) {
      // Handle loss of tracking
    }
  }
    
    _update(cameraTransform) {
        const pos = cameraTransform.position;
        const forward = cameraTransform.forward;
        this.conductor.updateAmp(pos, forward);
    }
    
    _onTouchAlien(position, source)  {
        // user has clicked the object
        this.conductor.touchDown("alien");
    }
    
    _onTouchMetalLo(position, source)  {
        // user has clicked the object
        this.conductor.touchDown("metalLo");
    }
    
    _onTouchMetalHi(position, source)  {
        // user has clicked the object
        this.conductor.touchDown("metalHi");
    }
    
}


var styles = StyleSheet.create({
  helloWorldTextStyle: {
    fontFamily: 'Arial',
    fontSize: 30,
    color: '#ffffff',
    textAlignVertical: 'center',
    textAlign: 'center',  
  },
});

ViroMaterials.createMaterials({
    black: {
        diffuseTexture: require('./res/Black.jpg'),
    },
});

module.exports = HelloWorldSceneAR;
