'use strict';

import React, { Component } from 'react';

import {StyleSheet, NativeModules} from 'react-native';

import {
  ViroARScene,
  ViroText,
  ViroConstants,
    ViroBox,
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
            <ViroSphere position={[0.4, -0.2, -1]} radius={.2} />
            <ViroSphere position={[-0.4, -0.2, -1]} radius={.2} />
            <ViroSphere position={[0, 0.2, -1.8]} radius={.15} materials={["black"]} onClick={this._onTouchAlien} />
            <ViroBox position={[0, 0, -5]} scale={[.3, .3, .3]} />
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
