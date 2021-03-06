/*

 INTIMatic por Federico Joselevich Puiggros e "Intimidad Romero" se encuentra bajo una Licencia Creative Commons Atribución 3.0 Unported.
 
 This code was developed by Federico Joselevich Puiggros <f@ludic.cc>
 www.ludic.cc
 
 Any modifications must include the text: "originaly developed by Federico Joselevich Puiggros, desing: 'intimidad romero'".
 
 
 
 */
//
//  BuscaCaras.h
//  INTIMatic
//
//  Created by Federico Joselevich Puiggrós on 08/05/13.
//
//

#ifndef __INTIMatic__BuscaCaras__
#define __INTIMatic__BuscaCaras__

#include "Poco/Mutex.h"

#include "ofMain.h"
#include "ofxCvHaarFinder.h"


#include <iostream>

class BuscaCaras : public ofThread {
    
public:
    
    BuscaCaras();
    ~BuscaCaras();
    //-------------------------------
    // non blocking functions
    
    bool available() { return !processing; };
    
    //-------------------------------
    // blocking functions
    void search(unsigned char *pixels, int w, int h);
    void search(ofxCvGrayscaleImage img);
    void search(bool mirror);
    
    ofxCvColorImage colorImg;
    ofxCvHaarFinder finder;
    ofxCvGrayscaleImage grayscaleImage;
    
    // threading stuff
    void threadedFunction();
    
    // other stuff-------------------
    void setTimeoutSeconds(int t){
        //timeoutSeconds = t;
    }
    
    
    void start();
    void stop();
    
protected:
    bool processing;
    
    //--------------------------------    
    
};

#endif /* defined(__INTIMatic__BuscaCaras__) */
