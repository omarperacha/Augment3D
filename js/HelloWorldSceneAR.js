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
  }

  render() {
    return (
            <ViroARScene onTrackingUpdated={this._onInitialized} onCameraTransformUpdate={this._update}>
            < // pure
            ViroPolyline position={[0, 0, -1]} points={[[0,-1,0], [0,1,0.15]]} thickness={0.2} />
            <ViroPolyline position={[1, 0, 0]} points={[[0,-1,0], [-0.15,1,0.15]]} thickness={0.2} />
            <ViroPolyline position={[-1, 0, 0]} points={[[0,-1,0], [0.15,1,0.15]]} thickness={0.2} />
            < // bass
            ViroPolyline position={[-2, -1.6, -1]} points={[[-.5,0,-.5], [0,.5,0], [.5,0,-.5], [0,.5,-1], [-.5,0,-.5]]} thickness={0.1} />
            < // alien
            ViroSphere position={[0.6, -0.2, -3]} radius={.25} />
            <ViroSphere position={[-0.6, -0.2, -3]} radius={.25} />
            <ViroSphere position={[0, 0.2, -3.8]} radius={.15} materials={["black"]} onClick={this._onTouchAlien} />
            < // conv
            ViroBox position={[0, 0, -5]} scale={[.3, .3, .3]} />
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
