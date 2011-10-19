import msafluid.*;
 
import processing.opengl.*;
import javax.media.opengl.*;

import ddf.minim.analysis.*;
import ddf.minim.*;

// Audio
Minim minim;
AudioInput microphone;
FFT fftLog;

// Fluid 
MSAFluidSolver2D fluidSolver;
PImage imgFluid;
boolean drawFluid = true;
float FLUID_WIDTH = 120; 
float invWidth, invHeight;    // inverse of screen dimensions
float aspectRatio, aspectRatio2;

PVector center;
 
void setup() {
    size(800, 800, OPENGL);  
    hint( ENABLE_OPENGL_4X_SMOOTH );
 
    invWidth = 1.0f/width;
    invHeight = 1.0f/height;
    aspectRatio = width * invHeight;
    aspectRatio2 = aspectRatio * aspectRatio;
 
    // create fluid and set options
    fluidSolver = new MSAFluidSolver2D((int)(FLUID_WIDTH), (int)(FLUID_WIDTH * height/width));
    fluidSolver.enableRGB(true).setFadeSpeed(0.003).setDeltaT(0.5).setVisc(0.0001);
 
    // create image to hold fluid picture
    imgFluid = createImage(fluidSolver.getWidth(), fluidSolver.getHeight(), RGB);
	
	// init Minim and connect to microphone
	minim = new Minim(this);
	microphone = minim.getLineIn(Minim.STEREO, 2048);
    fftLog = new FFT(microphone.bufferSize(), microphone.sampleRate());
	fftLog.logAverages(22, 3);
	
	// init some fluid to distort later
    center = new PVector(width/2, height/2);
}
 
void draw() {
    disturb();
    fluidSolver.update();
    
    if(drawFluid) {
        for(int i=0; i<fluidSolver.getNumCells(); i++) {
            int d = 2;
            imgFluid.pixels[i] = color(fluidSolver.r[i] * d, fluidSolver.g[i] * d, fluidSolver.b[i] * d);
        }  
        imgFluid.updatePixels();  
        image(imgFluid, 0, 0, width, height);
    } 
}
 
// add force and dye to fluid, and create particles
void addForce(float x, float y, float dx, float dy) {
    float speed = dx * dx  + dy * dy * aspectRatio2;    // balance the x and y components of speed with the screen aspect ratio
 
    if (speed > 0) {
        if(x<0) x = 0; 
        else if(x>1) x = 1;
        if(y<0) y = 0; 
        else if(y>1) y = 1;
 
        float colorMult = 2;
        float velocityMult = 30.0f;
 
        int index = fluidSolver.getIndexForNormalizedPosition(x, y);
 
        color drawColor;
 
        colorMode(HSB, 360, 1, 1);
        // float hue = ((x + y) * 180 + frameCount) % 360;
        float hue = map(mouseX, 0, width, 0, 360);
        drawColor = color(hue, 0.5, 0.1);
        colorMode(RGB, 1);  
 
        fluidSolver.rOld[index]  += red(drawColor) * colorMult;
        fluidSolver.gOld[index]  += green(drawColor);
        fluidSolver.bOld[index]  += blue(drawColor);
 
        fluidSolver.uOld[index] += dx * velocityMult;
        fluidSolver.vOld[index] += dy * velocityMult;
    }
}

void addNebula() {
    for (int x = 0; x < width; x += 100) {
        for (int y = 0; y < height; y += 100) {
	        addForce(x * invWidth, y * invHeight, random(-10, 10), 
		    random(-10, 10));
        }
    }
}
    
public void disturb() {

    // update microphone data
    int specSize = fftLog.specSize();
    fftLog.forward(microphone.mix);
	for (int i = 0; i < fftLog.specSize(); i++) {
	    if(fftLog.getBand(i)>0.1) {
        	float x = (center.x + sin(TWO_PI / specSize * i) * 400) * invWidth;
                float y = (center.y + cos(TWO_PI / specSize * i) * 400) * invHeight;
	        addForce(x, y, -sin(TWO_PI / specSize * i) / 2000, cos(TWO_PI / specSize * i) * -fftLog.getBand(i)/2000);
	        addForce(1-x, 1-y, sin(TWO_PI / specSize * i) / 2000, -cos(TWO_PI / specSize * i) * -fftLog.getBand(i)/2000);
	    }
    }
}
