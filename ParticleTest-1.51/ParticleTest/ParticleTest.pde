/*
*   »Buchstabensuppe« optimiert für Processing 1.51
*   2011-07-02 Beginn
*   2011-07-10 Umbau
*   
*/

import codeanticode.glgraphics.*;
import com.getflourish.stt.*;
import controlP5.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import geomerative.*;
import java.nio.ByteBuffer;
import java.nio.IntBuffer;
import javax.media.opengl.*;
import netP5.*;
import oscP5.*;

import processing.opengl.*;
import de.looksgood.ani.*;


AudioInput microphone;
AudioPlayer sample;
ByteBuffer byteBuffer;
Camera cam;
CharCloud cloud;
ControlWindow controlWindow;
FFT fftLog;
Fluid fluid;
ForceField force;
GL gl;
GLGraphicsOffScreen canvas;
GLModel distributionGraph;
GLSLShader cubeshader;
GLSLShader phongShader;
GLSLShader vertexShader;
GLSLShader glossyShader;
GLTexture backgroundTex;
GLTexture cloudTex;
GLTexture tex;
GLTexture[] textures;
IntBuffer intBuffer;
int[] envMapTextureID = {0};
Minim minim;
NetAddress myRemoteLocation;
OscP5 oscP5;
PFrame controlFrame;
PGraphicsOpenGL pgl;
PVector light;
RFont font;
Slider2D s;
String[] textureNames = {"+x.jpg", "-x.jpg", "+y.jpg", "-y.jpg", "+z.jpg", "-z.jpg"};
STT stt;

boolean applyShaders = false;
boolean dome = false;
boolean mic = true;
boolean showDebug = true;
boolean showFluid = false;
boolean showParticles = true;
boolean showTimeline = false;

float exposure, decay, density, weight;
float fluidSize = 2;
float dollyStep = 0;
int maxParticles = 500;

Scoreboard scoreboard;
ThreadedNGramGetter nGramGetter;
ArrayList words;
ArrayList words2;

/////////////////////////////////////////////////

public void setup() 
{
    // Grafik
    if (dome) {
        size(1920, 1920, GLConstants.GLGRAPHICS);
    } else {
        size(800, 800, GLConstants.GLGRAPHICS);   
    }
    colorMode(HSB, 360, 100, 100);
    frameRate(30);
    hint(ENABLE_OPENGL_4X_SMOOTH);
    
    // OSC
    oscP5 = new OscP5(this,12000);
    
    // Animation 
    Ani.init(this);
    
    // Kamera
    cam = new Camera(this, width / 2, height / 2, -900, 1, 10 * 1000);
    cam.aim(width / 2, height / 2, -1000);
    
    // Shader
    vertexShader = new GLSLShader(this, "ls.vert", "ls.frag");
    phongShader = new GLSLShader(this, "ps.vert", "ps.frag");
    glossyShader = new GLSLShader(this, "glossy.vert", "glossy.frag");
    
    canvas = new GLGraphicsOffScreen(this, width, height);
    
    backgroundTex = new GLTexture(this, "background.jpg");
    cloudTex = new GLTexture(this, "cloud.png");
    
    light = new PVector(0.5, 0.5);
    
    // Zweites Fenster für die Slider in 2D
    // controlFrame = new PFrame(this);
    // Font für Statusanzeige
    // controlWindow.textFont(createFont("Courier", 12));
    
    // STT
    stt = new STT(this, false);
    stt.enableDebug();
    stt.setLanguage("de");
    stt.disableAutoRecord();
    
    // Font für geomerative
    RG.init(this);
    font = new RFont("UbuntuTitling-Bold.ttf", 32, RFont.CENTER);
    
    // Minim
    initMinim();
    
    // Partikelsystem erstellen
    cloud = new CharCloud(this, maxParticles);

    // Shader stuff
    exposure = 1;
    decay = 0.7;
    density = 0.5;
    weight = 0.9;
    
    // cubemap
    
    pgl = (PGraphicsOpenGL) g;
    gl = pgl.gl;
    
    cubeshader = new GLSLShader(this, "fluxus.vert", "fluxus.frag");
    
    // init cubemap textures
    gl.glGenTextures(1, envMapTextureID, 0);
    gl.glBindTexture(GL.GL_TEXTURE_CUBE_MAP, envMapTextureID[0]);
    gl.glTexParameteri(GL.GL_TEXTURE_CUBE_MAP, GL.GL_TEXTURE_WRAP_S, GL.GL_CLAMP_TO_EDGE);
    gl.glTexParameteri(GL.GL_TEXTURE_CUBE_MAP, GL.GL_TEXTURE_WRAP_T, GL.GL_CLAMP_TO_EDGE);
    gl.glTexParameteri(GL.GL_TEXTURE_CUBE_MAP, GL.GL_TEXTURE_WRAP_R, GL.GL_CLAMP_TO_EDGE);
    gl.glTexParameteri(GL.GL_TEXTURE_CUBE_MAP, GL.GL_TEXTURE_MIN_FILTER, GL.GL_NEAREST);
    gl.glTexParameteri(GL.GL_TEXTURE_CUBE_MAP, GL.GL_TEXTURE_MAG_FILTER, GL.GL_NEAREST);
    
    textures = new GLTexture[6];
    for (int i = 0; i < 6; i++) {
        GLTexture tex = new GLTexture(this, textureNames[i]);
        textures[i] = tex;
    }
    
    for (int i = 0; i < 6; i++) {
        GLTexture tex = textures[i];
        int[] pix = new int[tex.width * tex.height];
        tex.getBuffer(pix, ARGB, GLConstants.TEX_BYTE);
        gl.glTexImage2D(GL.GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL.GL_RGBA, tex.width, tex.height, 0, GL.GL_RGBA, GL.GL_UNSIGNED_BYTE, IntBuffer.wrap(pix));
    }
    
    Ani.to(cam, 10.0, "theCameraZ", 1000, Ani.CUBIC_IN_OUT);
    
    scoreboard = new Scoreboard(90, 0.5, 0.9);
    words = new ArrayList();
    words.add("waschmittelwerbung");
    words.add("raumstation");
    words.add("zahnarzt");
    words.add("essen");
    
    words2 = new ArrayList();
    words2.add("essen");
    words2.add("zahnarzt");
    words2.add("raumstation");
    words2.add("waschmittelwerbung");
    
    nGramGetter = new ThreadedNGramGetter(this);
}

/////////////////////////////////////////////////

public void draw() {
    background(0);
    
    // Partikelsystem
    if (showParticles) {
       //lights();
       // CubeShader
       cubeshader.start();
           cubeshader.setFloatUniform("RefractionIndex", 0.5);    
           cubeshader.setVecUniform("SpecularColour", 1.0, 1.0, 1.0);
           cubeshader.setVecUniform("LightPos", 1.0, 1.0, 1.0);
           cubeshader.setFloatUniform("Roughness", 0.5);
           cubeshader.setFloatUniform("SpecularIntensity", 1.0);
           
           GLGraphics renderer = (GLGraphics)g;
           //renderer.ambient(0, 0, 250);
           //renderer.directionalLight(175, 189, 255, 0.5, 0.5, 1);
           // renderer.pointLight(255, 255, 255, 100, 100, 100);
           
           cam.dolly(dollyStep);
           cam.feed();
           cloud.updateAndDraw();
       cubeshader.stop();
            
            // Glossy
            //glossyShader.start();
            //    glossyShader.setVecUniform("AmbientColour", 0.836, 0.85, 1);
            //    glossyShader.setFloatUniform("AmbientIntensity", 0.5);
            //    glossyShader.setVecUniform("DiffuseColour", 0.63, 1.0, 1.0);
            //    glossyShader.setFloatUniform("DiffuseIntensity", 0.43);
            //    glossyShader.setVecUniform("LightPos", 1.0, 0.5, 0.35);
            //    glossyShader.setFloatUniform("Roughness", 0.5);
            //    glossyShader.setFloatUniform("Sharpness", 0.0);
            //    glossyShader.setVecUniform("SpecularColour", 0.0, 1.0, 1.0);
            //    glossyShader.setFloatUniform("SpecularIntensity", 0.5);
            //    /*
            //    // draw
            //    GLGraphics renderer = (GLGraphics)g;
            //    // renderer.ambient(0, 0, 250);
            //    // renderer.directionalLight(175, 189, 255, 0.5, 0.5, 1);
            //    // renderer.pointLight(255, 255, 255, 100, 100, 100);
            //    
            //    cam.dolly(dollyStep);
            //    cam.feed();
            //    cloud.updateAndDraw();
            //    renderer.translate(mouseX, mouseY, 0);
            //    renderer.sphere(100);
            //    */
            //    pushMatrix();
            //    translate(0, 0, 500);
            //    scoreboard.draw();
            //    popMatrix();
            //glossyShader.stop();
                
        
        pushMatrix();
        translate(0, 0, 250);
        scoreboard.draw();
        popMatrix();
    }  
        
    // Statusanzeigen mit FPS, Anzahl der Partikel
    if (showDebug) debug(); 
}

/////////////////////////////////////////////////

public void debug () {
    stroke(255);
    fill(255);
    text("particles: " + cloud.getParticleCount(), 10, 10); 
    text("framerate: " + (int) frameRate, 10, 30); 
}

// OpenGL Alternative zu backround(c, c, c, alpha);
public void fadeToColor(GL gl, float r, float g, float b, float speed) 
{
    gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA);
    gl.glColor4f(r, g, b, speed);
    gl.glBegin(GL.GL_QUADS);
    gl.glVertex2f(0, 0);
    gl.glVertex2f(width, 0);
    gl.glVertex2f(width, height);
    gl.glVertex2f(0, height);
    gl.glEnd();
}

public void initMinim () {
    // Minim entweder mit Mikrofon oder MP3 benutzen
	minim = stt.getMinimInstance();
	if (mic) {
	    microphone = minim.getLineIn(Minim.STEREO, 2048);
        fftLog = new FFT(microphone.bufferSize(), microphone.sampleRate());
    	fftLog.logAverages(22, 3);
	} else {
	    sample = minim.loadFile("sample.mp3", 2048);
	    fftLog = new FFT(sample.bufferSize(), sample.sampleRate());
    	fftLog.logAverages(22, 3);
	    sample.play();
	}
}

public void keyPressed () {
    if (key == 'p') showParticles = !showParticles;
    if (key == 's') applyShaders = !applyShaders;
    if (key == ' ') stt.begin();
    if (key == 'f') println(frameRate);
    if (key == 'e') {
        transcribe("Essen", 0.8, STT.SUCCESS);
    }
    if (key == 'z') {
        transcribe("Zahnarzt", 0.8, STT.SUCCESS);
    }
} 

public void keyReleased () {
    stt.end();
}

public void transcribe (String word, float confidence, int status) {
    switch (status) {
        case STT.SUCCESS:
            cloud.addWord(word);
            nGramGetter.getNGram(word);
            println("Getting ngram: " + word);
            break;
        case STT.RECORDING:
            cloud.reactOnRecord();
            break;
        case STT.ERROR:
            cloud.reactOnError();
            break;
    }
}

void nGramFound (NGram ngram)
{
    println("Found ngram: " + ngram.word);
    scoreboard.add(ngram); 
}

void oscEvent(OscMessage theOscMessage) {
    if (theOscMessage.addrPattern() == "status") {
        transcribe(theOscMessage.get(0).stringValue(), theOscMessage.get(1).floatValue(), theOscMessage.get(2).intValue());        
    } else if (theOscMessage.addrPattern() == "ngram") {
        String word = theOscMessage.get(0).stringValue();
        println("ngram! " + word);
    } else if (theOscMessage.addrPattern() == "/mrmr") {
        controlP5.Controller controller;
        float value = theOscMessage.get(0).floatValue() / 1000;
        if (theOscMessage.addrPattern() == "/mrmr/slider/horizontal/0/Aaaqw") {
            controller = controlWindow.controlP5.controller("radius");
            controller.setValue(value * controller.max());
        } 
        else if (theOscMessage.addrPattern() == "/mrmr/slider/horizontal/1/Aaaqw") {
            controller = controlWindow.controlP5.controller("strength");
            controller.setValue(value * controller.max());
        }
        else if (theOscMessage.addrPattern() == "/mrmr/slider/horizontal/2/Aaaqw") {
            controller = controlWindow.controlP5.controller("force z");
            controller.setValue(value * controller.max());
        }
        else if (theOscMessage.addrPattern() == "/mrmr/slider/horizontal/3/Aaaqw") {
            controller = controlWindow.controlP5.controller("exposure");
            controller.setValue(value * controller.max());
        }
        else if (theOscMessage.addrPattern() == "/mrmr/slider/horizontal/4/Aaaqw") {
            controller = controlWindow.controlP5.controller("density");
            controller.setValue(value * controller.max());
        }
        else if (theOscMessage.addrPattern() == "/mrmr/slider/horizontal/5/Aaaqw") {
            controller = controlWindow.controlP5.controller("decay");
            controller.setValue(value * controller.max());
        }
        else if (theOscMessage.addrPattern() == "/mrmr/slider/horizontal/6/Aaaqw") {
            controller = controlWindow.controlP5.controller("weight");
            controller.setValue(value * controller.max());
        }
        else if (theOscMessage.addrPattern() == "/mrmr/slider/horizontal/7/Aaaqw") {
            controller = controlWindow.controlP5.controller("dolly step");
            controller.setValue(value * controller.max());
        }
        else if (theOscMessage.addrPattern() == "/mrmr/accelerometerX/8/Aaaqw") {
            light.x = value;
        }
        else if (theOscMessage.addrPattern() == "/mrmr/accelerometer/8/Aaaqw") {
            light.y = value;
        }
    } else if (theOscMessage.addrPattern() == "arduino") {
        if (theOscMessage.get(0).intValue() == 0) stt.end(); else stt.begin();
    }
}

public void stop() 
{
  if (mic) {
      microphone.close();
  } 
  else {
      sample.close();
  }
  minim.stop();
  super.stop();
}
