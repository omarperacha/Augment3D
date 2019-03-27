/**
 * Copyright (c) 2017-present, Viro, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  Text,
  View,
  StyleSheet,
  PixelRatio,
  TouchableHighlight,
} from 'react-native';

import {
  ViroARSceneNavigator
} from 'react-viro';

/*
 TODO: Insert your API key below
 */
var sharedProps = {
  apiKey:"D6A4619F-606D-49A2-9D33-18BA60A8D2F8",
}

// Sets the default scene you want for AR and VR
var InitialARScene = require('./js/HelloWorldSceneAR');

var UNSET = "UNSET";
var VR_NAVIGATOR_TYPE = "VR";
var AR_NAVIGATOR_TYPE = "AR";

// This determines which type of experience to launch in, or UNSET, if the user should
// be presented with a choice of AR or VR. By default, we offer the user a choice.
var defaultNavigatorType = UNSET;

export default class ViroSample extends Component {
  constructor() {
    super();

    this.state = {
      navigatorType : defaultNavigatorType,
      sharedProps : sharedProps,
      selected: false,
      infoSelected: false,
    infoText1: ''
        
    }
    this._getExperienceSelector = this._getExperienceSelector.bind(this);
    this._getARNavigator = this._getARNavigator.bind(this);
    this._getVRNavigator = this._getVRNavigator.bind(this);
    this._getExperienceButtonOnPress = this._getExperienceButtonOnPress.bind(this);
    this._exitViro = this._exitViro.bind(this);
    this._textStyle = this._textStyle.bind(this);
    this._infoTextStyle = this._infoTextStyle.bind(this);
  }

  // Replace this function with the contents of _getVRNavigator() or _getARNavigator()
  // if you are building a specific type of experience.
  render() {
    if (this.state.navigatorType == UNSET) {
      return this._getExperienceSelector();
    } else if (this.state.navigatorType == VR_NAVIGATOR_TYPE) {
      return this._getVRNavigator();
    } else if (this.state.navigatorType == AR_NAVIGATOR_TYPE) {
      return this._getARNavigator();
    }
  }

  // Presents the user with a choice of an AR or VR experience
  _getExperienceSelector() {
    return (
      <View style={localStyles.outer} >
        <View style={localStyles.inner} >

          <Text style={localStyles.titleText}>
            Augment3D
          </Text>

          <TouchableHighlight style={localStyles.buttons}
            onPress={this._getExperienceButtonOnPress(AR_NAVIGATOR_TYPE)}
            underlayColor={'#000000'}
            onShowUnderlay={() => this.setState({selected: true})}
            onHideUnderlay={() => this.setState({selected: false})}
            >

            <Text style={this._textStyle()}>Start</Text>
          </TouchableHighlight>

          <TouchableHighlight style={localStyles.buttons}
            onPress={this._getExperienceButtonOnPress(VR_NAVIGATOR_TYPE)}
            underlayColor={'#000000'}
            onShowUnderlay={() => this.setState({infoSelected: true})}
            onHideUnderlay={() => this.setState({infoSelected: false})}
            >

            <Text style={this._infoTextStyle()}>Info</Text>
          </TouchableHighlight>
        </View>
      </View>
    );
  }
    
  _textStyle() {
    return this.state.selected ? localStyles.buttonTextSelected : localStyles.buttonText;
  }
    
  _infoTextStyle() {
        return this.state.infoSelected ? localStyles.buttonTextSelected : localStyles.buttonText;
    }

  // Returns the ViroARSceneNavigator which will start the AR experience
  _getARNavigator() {
    return (
      <ViroARSceneNavigator {...this.state.sharedProps}
        initialScene={{scene: InitialARScene}} />
    );
  }
  
  // Returns the ViroSceneNavigator which will start the VR experience
  _getVRNavigator() {
    return (
      <View style={localStyles.infoPage}>
            <TouchableHighlight style={localStyles.exitButton}
            onPress={this._exitViro}
            underlayColor={'#000000'}
            onShowUnderlay={() => this.setState({infoSelected: true})}
            onHideUnderlay={() => this.setState({infoSelected: false})}
            >
            
            <Text style={this._infoTextStyle()}>{"<"}</Text>
            </TouchableHighlight>
            <Text style={localStyles.titleTextInfo}>About</Text>
            <Text style={localStyles.textBody}>{this.state.infoText1}
            </Text>
            <TouchableHighlight style={localStyles.exitButton}
            onPress={this._exitViro}
            underlayColor={'#000000'}
            onShowUnderlay={() => this.setState({infoSelected: true})}
            onHideUnderlay={() => this.setState({infoSelected: false})}
            >
            
            <Text style={this._infoTextStyle()}>{">"}</Text>
            </TouchableHighlight>
        </View>
    );
  }

  // This function returns an anonymous/lambda function to be used
  // by the experience selector buttons
  _getExperienceButtonOnPress(navigatorType) {
    return () => {
      this.setState({
        navigatorType : navigatorType,
        infoSelected: false,
                    infoText1 : 'Augment3D is an interactive piece of music powered by\nAR\n\nPress START in the main menu to see virtual objects placed in the world around you\n\nExplore the objects and the sounds they make by moving towards them. Interact with the music by exploring different spaces near the objects and rotating your device screen'
     })
    }
  }

  // This function "exits" Viro by setting the navigatorType to UNSET.
  _exitViro() {
    this.setState({
      navigatorType : UNSET,
      infoSelected: false,
      infoText1 : 'Augment3D is an interactive piece of music powered by\nAR\n\nPress START in the main menu to see virtual objects placed in the world around you\n\nExplore the objects and the sounds they make by moving towards them. Interact with the music by exploring different spaces near the objects and rotating your device screen'
    })
  }

}


var localStyles = StyleSheet.create({
  viroContainer :{
    flex : 1,
    backgroundColor: "black",
  },
  outer : {
    flex : 1,
    flexDirection: 'row',
    alignItems:'center',
    backgroundColor: "black",
  },
  inner: {
    flex : 1,
    flexDirection: 'column',
    alignItems:'center',
    backgroundColor: "black",
  },
                                    infoPage: {
                                    flex : 1,
                                    flexDirection: 'column',
                                    backgroundColor: "black",
                                    },
  titleText: {
    fontFamily: "Azonix",
    paddingTop: 5,
    paddingBottom: 150,
    color:'#fff',
    textAlign:'center',
    fontSize : 35,
  },
                                    
                                    titleTextInfo: {
                                    fontFamily: "Azonix",
                                    paddingTop: 5,
                                    paddingBottom: 75,
                                    color:'#fff',
                                    textAlign:'center',
                                    fontSize : 35,
                                    },
  buttonText: {
    fontFamily: "Azonix",
    color:'#000000',
    textAlign:'center',
    fontSize : 20,
  },
  buttonTextSelected: {
    fontFamily: "Azonix",
    color:'#fff',
    textAlign:'center',
    fontSize : 20,
  },
                                    textBody: {
                                    fontFamily: "Courier New",
                                    color:'#fff',
                                    textAlign:'center',
                                    marginLeft: 20,
                                    marginRight: 20,
                                    fontSize : 18,
                                    },
  buttons : {
    height: 80,
    width: 150,
    paddingTop:30,
    paddingBottom:20,
    marginTop: 10,
    marginBottom: 10,
    backgroundColor:'#ffffff',
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#fff',
  },
  exitButton : {
    height: 30,
    width: 30,
    paddingTop:5,
    paddingBottom:5,
    marginTop: 40,
    marginLeft: 20,
    marginBottom: 10,
    backgroundColor:'#ffffff',
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#fff',
  }
});

module.exports = ViroSample
