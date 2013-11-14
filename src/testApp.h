#pragma once


#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofTrueTypeFont.h"
#include "ofxCvHaarFinder.h"
#include "ofxHttpUtils.h"

#include "boton.h"
#include "buscaCaras.h"
#include <CoreGraphics/CGImage.h>
#include <UIKit/UIKit.h>
#include "ASIFormDataRequest.h"


#define CANT_MARCOS 5
#define INTI_VERSION 1.01


class testApp : public ofxiPhoneApp{
	
	public:
    
    ~testApp();
		
		void setup();
		void update();
		void draw();
        void exit();
    
        void touchDown(ofTouchEventArgs & touch);
        void touchMoved(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);
        void touchDoubleTap(ofTouchEventArgs & touch);
        void touchCancelled(ofTouchEventArgs & touch);
	
        void lostFocus();
        void gotFocus();
        void gotMemoryWarning();
        void deviceOrientationChanged(int newOrientation);



    ofImage marcos[CANT_MARCOS];
    ofImage filtros[CANT_MARCOS];
    int currentMarco, currentFiltro;
    
    
    
    //ofxBlurShader blur;
    
    float lineaExtraY;
    float lastMinY;
    float lastMaxY;
    
    ofVideoGrabber 		vidGrabber;
    unsigned char * 	videoInverted;
    ofTexture			videoTexture;
    int 				camWidth;
    int 				camHeight;
    unsigned int dbgtime;
    
    ofTrueTypeFont tipo;
    bool tomarProxima;
    
    void saveImage();
    
    bool twoCameras;
    
    /**** Interfaz ****/
    ofImage baseImg, topImg, bajoFiltros;
    ofImage logo;
    Boton obturador;
    ofSoundPlayer sObturador;
    Boton bsubir;
    Boton bverEnWeb;
    Boton botFiltros;
    Boton botMarcos;
    Boton swapCamera;
    int currentCamera;
    
    void startGrabber();
    
    bool bigScreen;
    
    void releaseSnap();
    
    /**** Send file ****/
    void newResponse(ofxHttpResponse & response);
    
    void uploadRequestFinished(ASIHTTPRequest *request);
    void uploadRequestFailed(ASIHTTPRequest *request);
    
    ofxHttpUtils httpUtils;
    
    BuscaCaras buscaCaras;
    
    char lastfile[256];
    string responseStr;
    
    void subirProxima();
    bool performeSubirProxima;
    
private:
    bool showingSnap;
    bool snapCapture;
    ofImage snap;
    
    ofFbo fboCapture;
    
    string message;
    
    ofRectangle previewSize;
    
    int stepper;
    
};


