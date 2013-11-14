#include "ofAppGlutWindow.h"
#include "testApp.h"

int main() {
	ofAppGlutWindow window;
	ofSetupOpenGL(&window, 612, 797, OF_WINDOW);
	ofRunApp(new testApp());
}
