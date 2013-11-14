//
//  BuscaCaras.cpp
//  INTIMatic
//
//  Created by Federico Joselevich Puiggrós on 08/05/13.
//
//

#include "BuscaCaras.h"

BuscaCaras::BuscaCaras() {
    processing = false;
    grayscaleImage.allocate(480,640);
}

BuscaCaras::~BuscaCaras() {
}

void BuscaCaras::search(unsigned char * pixels, int w, int h) {
    if (!processing) {
        cout << "Searching...\n";
        ofxCvColorImage img;
        img.allocate(w,h);
        img.setFromPixels(pixels, w, h);
        grayscaleImage = img;
        processing = true;
        finder.findHaarObjects(grayscaleImage); //, 80, 80);
        cout << "threaded encontró " << finder.blobs.size() << std::endl;
    }
    
}

void BuscaCaras::search(ofxCvGrayscaleImage img) {
    if (!processing) {
        cout << "Searching...\n";
        cout << img.width << " x " << img.height << std::endl;
        //processing = true;
        finder.findHaarObjects(img); //, 80, 80);
        cout << "Searching encontró " << finder.blobs.size() << std::endl;
    }
}

void BuscaCaras::search(bool mirror) {
    if (!processing) {
        //cout << "Searching...\n";
        colorImg.mirror(false,mirror);
        grayscaleImage = colorImg;        
        processing = true;
        //finder.findHaarObjects(grayscaleImage, 80, 80);
    }
    
}

void BuscaCaras::threadedFunction() {
    
    // loop through this process whilst thread running
    while( isThreadRunning() == true ){
		lock();
        
        if (processing) {
            finder.findHaarObjects(grayscaleImage, 100, 100);
            //
            //cout << "threaded encontró " << finder.blobs.size() << std::endl;
            processing = false;
        }
        unlock();
    	
    	ofSleepMillis(40);
    }
    
}

// ----------------------------------------------------------------------
void BuscaCaras::start() {
    startThread(true, false);
    printf("thread started\n");
}
// ----------------------------------------------------------------------
void BuscaCaras::stop() {
    stopThread();

}