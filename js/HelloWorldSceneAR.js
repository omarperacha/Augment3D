'use strict';

import React, { Component } from 'react';

import {StyleSheet} from 'react-native';

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
      text : "Initializing AR..."
    };

    // bind 'this' to functions
    this._onInitialized = this._onInitialized.bind(this);
      this._update = this._update.bind(this);
  }

  render() {
    return (
            <ViroARScene onTrackingUpdated={this._onInitialized} onCameraTransformUpdate={this._update}>
            <ViroText text={this.state.text} scale={[.5, .5, .5]} position={[0, 2, -2]} style={styles.helloWorldTextStyle} />
            <ViroBox position={[0, 0, -1]} scale={[.3, .3, .3]} />
      </ViroARScene>
    );
  }

  _onInitialized(state, reason) {
    if (state == ViroConstants.TRACKING_NORMAL) {
      this.setState({
        text : "Hello World!"
      });
    } else if (state == ViroConstants.TRACKING_NONE) {
      // Handle loss of tracking
    }
  }
    
    _update(cameraTransform) {
        const x = calculateDist(cameraTransform.position, [0, 0, -1]);
        this.setState({text : String(x)});
    }
    
}


function calculateDist(dist1, dist2){
    const x = dist1[0] - dist2[0];
    const y = dist1[1] - dist2[1];
    const z = dist1[2] - dist2[2];
    
    return Math.sqrt((x*x)+(y*y)+(z*z))
};

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
