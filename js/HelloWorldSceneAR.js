'use strict';

import React, { Component } from 'react';

import {StyleSheet, NativeModules, AppState} from 'react-native';

import {
  ViroARScene,
  ViroText,
  ViroConstants,
    ViroCamera,
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
        appState: AppState.currentState,
        origin: [0,0,0]
    };

      this.conductor = NativeModules.Conductor
    // bind 'this' to functions
    this._onInitialized = this._onInitialized.bind(this);
      this._update = this._update.bind(this);
      this._onTouchAlien = this._onTouchAlien.bind(this);
      this._onTouchMetalLo = this._onTouchMetalLo.bind(this);
      this._onTouchMetalHi = this._onTouchMetalHi.bind(this);
      this._teleport1 = this._teleport1.bind(this);
      this._teleport2 = this._teleport2.bind(this);
      this._teleport3 = this._teleport3.bind(this);
      this._teleport4 = this._teleport4.bind(this);
      this._teleport5 = this._teleport5.bind(this);
      this._getPos = this._getPos.bind(this);
  }

  render() {
    return (
            <ViroARScene onTrackingUpdated={this._onInitialized} onCameraTransformUpdate={this._update}>
            < // guitar
            ViroBox position={this._getPos([0, 0, -1])} scale={[.3, .3, .3]} onClick={this._teleport1}/>
            <ViroBox position={this._getPos([0.5, 0.3, -1])} scale={[.22, .22, .22]} rotation={[20, -30, 0]} materials={["black"]} onClick={this._onTouchMetalHi} />
            <ViroBox position={this._getPos([-0.5, 0.3, -1])} scale={[.22, .22, .22]} rotation={[20, 30, 0]} materials={["black"]} onClick={this._onTouchMetalLo} />
            < // pure
            ViroPolyline position={this._getPos([-3, 0, 1])} points={[[0,-1,0], [0,1,0.15]]} thickness={0.2} onClick={this._teleport5}/>
            <ViroPolyline position={this._getPos([-1.9, 0, 0])} points={[[0,-1,0], [-0.15,1,0.15]]} thickness={0.2} onClick={this._teleport5}/>
            <ViroPolyline position={this._getPos([-4.1, 0, 0])} points={[[0,-1,0], [0.15,1,0.15]]} thickness={0.2} onClick={this._teleport5}/>
            < // bass
            ViroPolyline position={this._getPos([-3.5, -1.3, -1.75])} points={[[-.5,0,-.5], [0,.5,0], [.5,0,-.5], [0,.5,-1], [-.5,0,-.5]]} thickness={0.1} onClick={this._teleport4}/>
            < // alien
            ViroSphere position={this._getPos([-1.5, -0.2, -3.5])} radius={.25} onClick={this._teleport3}/>
            <ViroSphere position={this._getPos([-1.5, -0.2, -2.5])} radius={.25} onClick={this._teleport3}/>
            <ViroSphere position={this._getPos([-2.3, 0.2, -3])} radius={.15} materials={["black"]} onClick={this._onTouchAlien} />
            < // conv
            ViroBox position={this._getPos([0.8, 0, -3])} scale={[.3, .3, .3]} onClick={this._teleport2}/>
      </ViroARScene>
    );
  }
    
    componentDidMount() {
        AppState.addEventListener('change', this._handleAppStateChange);
    }
    
    componentWillUnmount() {
        AppState.removeEventListener('change', this._handleAppStateChange);
    }
    
    _handleAppStateChange = (nextAppState) => {
        if (
            nextAppState === 'inactive'
            ) {
            this.conductor.tearDown();
        }
        this.setState({appState: nextAppState});
    };
    
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
    
    _getPos(offset){
        const x = this.state.origin[0] + offset[0];
        const y = this.state.origin[1] + offset[1];
        const z = this.state.origin[2] + offset[2];
        
        return [x, y, z]
    }
    
    _teleport1(position, source){
        const toLocation = [0,0,0]
        this.setState({
                      origin : toLocation
                      });
        this.conductor.teleport(toLocation)
    }
    
    _teleport2(position, source){
        const toLocation = [-0.8,0,2]
        this.setState({
                      origin : toLocation
                      });
        this.conductor.teleport(toLocation)
    }
    
    _teleport3(position, source){
        const toLocation = [1,0,3]
        this.setState({
                      origin : toLocation
                      });
        this.conductor.teleport(toLocation)
    }
    
    _teleport4(position, source){
        const toLocation = [2.7,0,1.75]
        this.setState({
                      origin : toLocation
                      });
        this.conductor.teleport(toLocation)
    }
    
    _teleport5(position, source){
        const toLocation = [3,0,0]
        this.setState({
                      origin : toLocation
                      });
        this.conductor.teleport(toLocation)
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
