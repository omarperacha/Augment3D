'use strict';

import React, { Component } from 'react';

import {StyleSheet, NativeModules} from 'react-native';

import {
  ViroARScene,
  ViroText,
  ViroConstants,
    ViroBox,
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
  }

  render() {
    return (
            <ViroARScene onTrackingUpdated={this._onInitialized} onCameraTransformUpdate={this._update}>
            <ViroBox position={[0, 0, -1]} scale={[.3, .3, .3]} />
      </ViroARScene>
    );
  }

  _onInitialized(state, reason) {
    if (state == ViroConstants.TRACKING_NORMAL) {
      this.setState({
        text : "Hello World!"
      });
        this.conductor.setup();
    } else if (state == ViroConstants.TRACKING_NONE) {
      // Handle loss of tracking
    }
  }
    
    _update(cameraTransform) {
        const pos = cameraTransform.position;
        const roll = cameraTransform.rotation[0]
        const yaw = cameraTransform.rotation[2]
        this.conductor.updateAmp(pos, roll, yaw);
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

module.exports = HelloWorldSceneAR;
