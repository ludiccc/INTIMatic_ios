/*
 
 INTIMatic por Federico Joselevich Puiggros e "Intimidad Romero" se encuentra bajo una Licencia Creative Commons Atribución 3.0 Unported.
 
 
 This code was developed by Federico Joselevich Puiggros <f@ludic.cc>
 www.ludic.cc
 
 Any modifications must include the text: "originaly developed by Federico Joselevich Puiggros, desing: 'intimidad romero'".
 
 
 
 */
#include "testApp.h"

testApp::~testApp(){
    buscaCaras.stop();
}

//--------------------------------------------------------------
void testApp::setup(){
    cout << "INTIMatic v." << INTI_VERSION << std::endl;
    cout << "Dimentions: " << ofGetScreenWidth() << " x " << ofGetScreenWidth() << std::endl;
    cout << " app:" << ofGetWidth() << " x " << ofGetHeight() << std::endl;
	ofxiPhoneSetOrientation(OFXIPHONE_ORIENTATION_PORTRAIT);
    
    bigScreen = (ofGetHeight() >= 960);
    
    ofSetFrameRate(20);
    camWidth 		= 640;	// try to grab at this size.
	camHeight 		= 480;
	
    currentCamera = 1;
    twoCameras = false;
    startGrabber();

    vidGrabber.listDevices();
				
	marcos[0].loadImage("filtros/MarcoRedonBlanco.png");
    marcos[1].loadImage("filtros/MarcoRedonNegro.png");
    filtros[0].loadImage("filtros/map-5.png");
    filtros[1].loadImage("filtros/map-2.png");
    filtros[2].loadImage("filtros/map-1.png");
    filtros[3].loadImage("filtros/map-5.png");

    // buscaCaras necesita ser inicializado a mano:
    buscaCaras.finder.setup("haarcascade_frontalface_alt.xml");

    buscaCaras.colorImg.allocate(vidGrabber.width,vidGrabber.height);
    

    buscaCaras.grayscaleImage.allocate(vidGrabber.width,vidGrabber.height);

    tipo.loadFont("XG-pixo.TTF",8);
    
    currentMarco = 2;
    currentFiltro = 3;
    ofEnableAlphaBlending();
    tomarProxima = false;
    
    
    
    sObturador.loadSound("72714__horsthorstensen__shutter-photo.wav");
    sObturador.setLoop(false);
    
    string basePath = (bigScreen)?"960/":"480/";
    
    logo.loadImage(basePath+"logo.png");
    
    baseImg.loadImage(basePath+"bot_fondo.png");
    topImg.loadImage(basePath+"top_fondo.png");
    bajoFiltros.loadImage(basePath+"bajo_filtros.png");
    
    
    previewSize.width = MIN(ofGetWidth(), 612);
    previewSize.height = previewSize.width;
    previewSize.x = 0;
    previewSize.y = topImg.height+(ofGetHeight()-baseImg.height-topImg.height)/2-previewSize.height/2;
    
    cout << "PreviewSize: " << previewSize.x << "," <<  previewSize.y << "," <<  previewSize.width << "," <<  previewSize.height  << std::endl;

    obturador.setup(ofGetWidth()-((bigScreen)?166:83),ofGetHeight()-((bigScreen)?132:66),basePath+"obturador-up.png", basePath+"obturador-down.png");
    bsubir.setup(ofGetWidth()-((bigScreen)?90:45),(bigScreen)?14:7,basePath+"upload-down.png", basePath+"upload-up.png");
    botFiltros.setup(((bigScreen)?38:19),  ((bigScreen)?30:15), basePath+"menu.png", basePath+"menu.png");
    botMarcos.setup( ((bigScreen)?137:68), ((bigScreen)?30:15), basePath+"marco-menu.png", basePath+"marco-menu.png");
    
    swapCamera.setup(ofGetWidth()-((bigScreen)?210:110),(bigScreen)?30:15, basePath+"swap_camera.png", basePath+"swap_camera.png");
    
	ofAddListener(httpUtils.newResponseEvent,this,&testApp::newResponse);
	httpUtils.start();
    httpUtils.setVerbose(true);
    sprintf(lastfile, "");
    
    snapCapture = false;
    message.clear();
    lineaExtraY = -1;
    lastMinY = 300;
    
    fboCapture.allocate(vidGrabber.width,vidGrabber.height);
    fboCapture.begin();
	ofClear(0,0,0);
    fboCapture.end();
    
    stepper = 0;
    
    ofSetBackgroundAuto(false);
    buscaCaras.start();
    performeSubirProxima = false;
}

//--------------------------------------------------------------
void testApp::update(){
	dbgtime = ofGetElapsedTimeMillis();
	vidGrabber.update();
	if (vidGrabber.isFrameNew() && !snapCapture){
        
        if (buscaCaras.available()) buscaCaras.colorImg.setFromPixels(vidGrabber.getPixels(), vidGrabber.width, vidGrabber.height);
        //buscaCaras.grayscaleImage = buscaCaras.colorImg;
        //buscaCaras.finder.findHaarObjects(buscaCaras.grayscaleImage);
        //buscaCaras.search(vidGrabber.getPixels(), vidGrabber.width, vidGrabber.height);
        buscaCaras.search(twoCameras && (currentCamera == 1));
	}
    
    if (performeSubirProxima) {
        subirProxima();
        performeSubirProxima = false;
    }
	
}

//--------------------------------------------------------------
void testApp::draw(){
	int minY = 612;
    int maxY = 0;

    ofSetColor(255);
    ofBackground(0);
    if (snapCapture) {
        //snap.draw(0,0);
    } else {
        fboCapture.begin();
        ofPushMatrix();
        buscaCaras.colorImg.blur(3);
        
        unsigned char * pixels = buscaCaras.colorImg.getPixels(); //vidGrabber.getPixels();
        
        buscaCaras.colorImg.draw(0, 0);
        
        ofNoFill();
                
        if (lineaExtraY > -1) {
            minY = lineaExtraY - 20;
            maxY = lineaExtraY + 20;
        }
        
        //
        for(int i = 0; i < buscaCaras.finder.blobs.size(); i++) {
            ofRectangle cur = buscaCaras.finder.blobs[i].boundingRect;
            if (cur.y < minY) minY = cur.y;
            if (cur.y+cur.height > maxY) maxY = cur.y+cur.height;
        }
        
        if (minY == 612) minY = lastMinY;
        if (maxY < minY) {
            if (minY == 300) maxY = minY + 80;
            else {
                maxY = lastMaxY;
            }
            
        }
        lastMinY = minY;
        lastMaxY = maxY;
        
        ofFill();
        float sqSize = (maxY-minY)/4;
        for (int x = 0; x < vidGrabber.width; x+= sqSize)
            for (int y = minY; y < maxY-sqSize*2; y+=sqSize) {
                ofSetColor(pixels[(y*vidGrabber.width+x)*3],
                           pixels[(y*vidGrabber.width+x)*3+1],
                           pixels[(y*vidGrabber.width+x)*3+2]);
                ofRect(x,y,sqSize,MIN(sqSize,maxY-y));
            }
        ofSetColor(255,255,255);
        ofPopMatrix();
        fboCapture.end();
    }
    int w = previewSize.width;
    int h = previewSize.width*vidGrabber.height/vidGrabber.width;

    if (vidGrabber.width > vidGrabber.height) {
        h = previewSize.height;
        w = previewSize.height*vidGrabber.width/vidGrabber.height;
    }
    int x = previewSize.x; // - abs(w-previewSize.width/2);
    int y = previewSize.y;
    fboCapture.draw(x, y, w, h);
    //cout  << x << " " << y<<  " " <<w <<  " " <<h <<" " << previewSize.width << " " << previewSize.height <<  std::endl;
    //else fboCapture.draw(0, topImg.height,ofGetWidth()*vidGrabber.width/vidGrabber.height, ofGetHeight());

    
    ofSetColor(255);
    
    ofEnableAlphaBlending();
    if ( currentFiltro < 3 ) filtros[currentFiltro].draw(previewSize.x, previewSize.y, previewSize.width, previewSize.height);
    
    if ( currentMarco < 2  ) marcos[currentMarco].draw(previewSize.x, previewSize.y, previewSize.width, previewSize.height);
    
    
        
    if (tomarProxima) {
        message.clear();
        releaseSnap();
        performeSubirProxima = true;
        tomarProxima = false;
        message = "Uploading photo to server... please wait...";
    }
    
    /**** interfaz ****/
    ofSetColor(255);
    baseImg.draw(0,ofGetHeight()-baseImg.height,ofGetWidth(),baseImg.height);
    topImg.draw(0,0, ofGetWidth(), topImg.height);
    
    logo.draw(((bigScreen)?58:29),ofGetHeight()-((bigScreen)?105:57));
    
    obturador.render();
    if (snapCapture) bsubir.render();
    botFiltros.render();
    botMarcos.render();
    swapCamera.render();
    //bverEnWeb.render();

    
    //char msj[256];
    //sprintf(msj, "v. %1.2f", INTI_VERSION);
    //ofSetColor(164,164,164);
    //tipo.drawString(msj, 500, 750);
    
    if (!message.empty()) {
        ofSetColor(0,0,0,50);
        ofRect(0,previewSize.y, ofGetWidth(), 30);
        ofSetColor(255);
        tipo.drawString(message, 0, previewSize.y+20);
    }
    

}

//--------------------------------------------------------------
void testApp::saveImage() {
    sprintf(lastfile, "INTIMatic-%04i-%02i-%02i-%02i-%02i-%02i-.jpg", ofGetYear(), ofGetMonth(), ofGetDay(), ofGetHours(), ofGetMinutes(), ofGetSeconds());
    ofPixels pixels;
    
    snap.grabScreen(previewSize.x,previewSize.y,previewSize.height,previewSize.height);
    snap.saveImage(lastfile);
   
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, snap.getPixels(), (snap.getWidth()*snap.getHeight()*3), NULL);
    CGImageRef imageRef = CGImageCreate(snap.getWidth(), snap.getHeight(), 8, 24, 3*snap.getWidth(), CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrderDefault, provider, NULL, NO, kCGRenderingIntentDefault);
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithCGImage:imageRef]);
    UIImage *output = [UIImage imageWithData:imageData];
    UIImageWriteToSavedPhotosAlbum(output,nil,@selector(image:didFinishSavingWithError:contextInfo:),nil);
    
    
}

//--------------------------------------------------------------
void testApp::subirProxima() {
    if (!strcmp(lastfile, "")) return;
	
    /**** Otra alternativa: ****/
    /*
    size_t width = snap.width;
    size_t height = snap.height;
    size_t depth = 8;                     //bitsPerComponent
    //size_t depthXnChannels = 8;           //bitsPerPixel
    size_t widthStep = snap.width; //bytesPerRow
    
    CGContextRef ctx = CGBitmapContextCreate(snap.getPixels(), width, height, depth, widthStep,  CGColorSpaceCreateDeviceGray(), kCGImageAlphaNone);
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    //UIImage* rawImage = [UIImage imageWithCGImage:imageRef];
    
    NSData *imageData = (NSData *)CGDataProviderCopyData(CGImageGetDataProvider(imageRef));
    // fa2e7c977b3a3d6b985626672a6e515001a05a43
    /*
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&pixels pixelsWide:width pixelsHigh:height bitsPerSample:8 samplesPerPixel:3 hasAlpha:NO isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:0 bitsPerPixel:0];
    // create an NSData object from the NSBitmapImageRep
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:.7] forKey:NSImageCompressionFactor];
    NSData *imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    */
    NSURL *url = [NSURL URLWithString:@"http://www.intimatic.com.ar/cgi-bin/upload.cgi"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setUseKeychainPersistence:YES];
    //if you have your site secured by .htaccess
    
    //[request setUsername:@"login"];
    //[request setPassword:@"password"];
    
    cout << "Sending : " << ofToDataPath(lastfile) << std::endl;
    
    std::string newPhotoPath(ofToDataPath(lastfile));
    
    NSString *fileName = [NSString stringWithUTF8String:newPhotoPath.c_str()];
    //[request addPostValue:fileName forKey:@"photo"];
    
    // Upload an image
    //NSData *imageData = UIImageJPEGRepresentation([UIImage imageName:fileName])
    [request setFile:fileName forKey:@"photo"];
    
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        cout << "Received message: " << response << std::endl;
        
        NSURL *url = [NSURL URLWithString:response];
        NSLog(@"url = %@",url);
        [[UIApplication sharedApplication] openURL:url];
        
        std::string mensajeOK([response UTF8String]);
        message = mensajeOK;
    } else {
        NSString *response = [request responseString];
        cout << "Error:" << response << std::endl;
        NSLog(@"%@",[error localizedDescription]);
        //std::string mensajeFail([response UTF8String]);
        //message = mensajeFail;
    }
    /*
    ofxHttpForm form;
	form.action = "http://www.intimatic.com.ar/cgi-bin/upload.cgi";
	form.method = OFX_HTTP_POST;
	form.addFormField("name", "intimatic");
	form.addFile("photo",lastfile);
	httpUtils.addForm(form);
    cout << "[subirProxima] enviando foto a " << form.action << std::endl;
    message = "Sending image...";
    */
    message = "";
}
void testApp::uploadRequestFinished(ASIHTTPRequest *request)
{
    NSString *response = [request responseString];
    NSURL *url = [NSURL URLWithString:response];
    NSLog(@"url = %@",url);
    [[UIApplication sharedApplication] openURL:url];

    std::string mensajeOK([response UTF8String]);
    message = mensajeOK;
}

void testApp::uploadRequestFailed(ASIHTTPRequest *request) {
    NSString *response = [request responseString];
    std::string mensajeFail([response UTF8String]);
    message = mensajeFail;
}
//--------------------------------------------------------------
void testApp::newResponse(ofxHttpResponse & response){
	responseStr = (std::string)response.responseBody;
    cout << "[newResponse] " << responseStr << std::endl;
    message = responseStr;
    
    if (responseStr.find("http://www.intimatic.com.ar/") != string::npos) {
        NSString *webPage1 = [NSString stringWithUTF8String:responseStr.c_str()];
        NSURL *url = [NSURL URLWithString:webPage1];
        NSLog(@"url = %@",url);
        [[UIApplication sharedApplication] openURL:url];
    }


}

void testApp::releaseSnap() {
    snapCapture = false;
    //bsubir.setActive(false);
    bsubir.setSelected(false);
    message.clear();
    
}


//--------------------------------------------------------------
void testApp::exit(){
    
}

void testApp::startGrabber() {
    vidGrabber.close();
    try {
        vidGrabber.setDeviceID(currentCamera);
        cout << "Init grabber on camera: " << currentCamera << std::endl;
        twoCameras = true;
    } catch (...) {
        currentCamera = 0;
        vidGrabber.setDeviceID(currentCamera);
    }
    vidGrabber.initGrabber(camWidth,camHeight);

    vidGrabber.setDesiredFrameRate(20);
}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch){
    /* Si hago click sobre la imagen, genera una línea de pixelado en ese lugar. Al hacer click de nuevo se va */
    cout << "Touched... " << std::endl;
    int y = ofGetMouseY(); //touch->mouseY;
    if (snapCapture && bsubir.isPressed()) {
        tomarProxima = true;
        cout << "Se subirá la próxima..." << std::endl;
    } else if (y < previewSize.height && y > topImg.height) {
        if (snapCapture) {
            releaseSnap();
        }
        //else lineaExtraY = (lineaExtraY>-1)?-1:y*(612/(float)vidGrabber.height);
        return;
    }
    
    if (obturador.isPressed()) {
        bsubir.setSelected(true);
        sObturador.play();
        message = "Press upload to send or image to cancel.";
        snapCapture = true;
        saveImage();
    }
    
    if (swapCamera.isPressed()) {
        if (currentCamera == 1) currentCamera = 0;
        else currentCamera = 1;
        startGrabber();
    }
    
    if (botFiltros.isPressed()) {
        currentFiltro++;
        if ( currentFiltro > 3)  currentFiltro = 0;
    }
    
    if (botMarcos.isPressed()) {
        currentMarco++;
        if ( currentMarco > 2)  currentMarco = 0;
    }
    
    
    /*if (bverEnWeb.isPressed()) {
     //NSURL *url = [NSURL URLWithString:@"http://www.google.com/"];
     //[[UIApplication sharedApplication] openURL: url];
     //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.apple.com"]];
     
     
     }*/
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs& touch){

}

//--------------------------------------------------------------
void testApp::lostFocus(){
    
}

//--------------------------------------------------------------
void testApp::gotFocus(){
    
}

//--------------------------------------------------------------
void testApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){
    
}


