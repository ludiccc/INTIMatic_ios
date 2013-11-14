#include "testApp.h"
#include "ofMain.h"

int main(){
	ofSetupOpenGL(768,1024, OF_FULLSCREEN);			// <-------- setup the GL context
	ofRunApp(new testApp);
}
