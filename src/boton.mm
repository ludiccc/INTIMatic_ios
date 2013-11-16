/*
 This code was developed by Federico Joselevich Puiggros <f@ludic.cc>
 www.ludic.cc
 
 Any modifications must include the text: "originaly developed by Federico Joselevich Puiggros, desing: 'intimidad romero'".
 
 
 
 */
//
//  button.cpp
//  opencvHaarFinderExample
//
//  Created by Federico Joselevich Puiggrós on 28/09/12.
//
//

#include "boton.h"

void Boton::setup(int _x, int _y, string imgUp, string imgDown, bool setOnPress) {
    x = _x;
    y = _y;
    images[0].loadImage(imgUp);
    images[1].loadImage(imgDown);
    w = images[0].width;
    h = images[0].height;
    onPress = setOnPress;
    estado = true;
    upidx=1;
    downidx=0;
}

void Boton::setup(int _x, int _y, int _w, int _h) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    estado = true;
    upidx=1;
    downidx=0;
}

bool Boton::isPressed() {
    return (
        ofGetMouseX() > x && ofGetMouseX() < x+w &&
        ofGetMouseY() > y && ofGetMouseY() < y+h);
}
void Boton::render() {
    if (!estado) return;
    if (images[0].isAllocated()) {
        if (isPressed() && ofGetMousePressed()) ofSetColor(64);
        else ofSetColor(255);
        images[upidx].draw(x,y);
    } else {
        if (upidx == 0) ofSetColor(255);
        else ofSetColor(255,0,0);
        ofRect(x,y,w,h);
    }
}

void Boton::setActive(bool newEstado) {
    estado = newEstado;
}

void Boton::setSelected(bool pressed) {
    upidx=(pressed)?0:1;
    downidx=(pressed)?1:0;
}