/*
 This code was developed by Federico Joselevich Puiggros <f@ludic.cc>
 www.ludic.cc
 
 Any modifications must include the text: "originaly developed by Federico Joselevich Puiggros, desing: 'intimidad romero'".
 
 
 
 */
#include "testApp.h"
#include "ofMain.h"

int main(){
	ofSetupOpenGL(768,1024, OF_FULLSCREEN);			// <-------- setup the GL context
	ofRunApp(new testApp);
}
