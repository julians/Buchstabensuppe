import geomerative.*;
import controlP5.*;

import ddf.minim.analysis.*;
import ddf.minim.*;

ParticleSystem emitter;
ForceField force;

RFont font;

PShape3D model;

PFrame controlFrame;
ControlWindow controlWindow;

Fluid fluid;

// Audio
Minim minim;
AudioInput microphone;
AudioPlayer sample;
FFT fftLog;
boolean mic = false;

void setup()
{
    size(600, 600, OPENGL);
    hint(ENABLE_OPENGL_4X_SMOOTH);
    
    // Zweites Fenster für die Slider in 2D
    controlFrame = new PFrame();
    
    RG.init(this);
    font = new RFont("lucon.ttf", 32, RFont.CENTER);
    
    textFont(createFont("Courier", 12));
    
    emitter = new ParticleSystem(this, 1000);
    emitter.enableGravity(0);
    emitter.addGlobalVelocity(0, 0, 1);
    force = new ForceField(new PVector (width / 2, height / 2, 0)).setRadius(50).setStrength(100).show();
    emitter.addForceField(force);
    
    model = (PShape3D)loadShape("a.obj");
    model.scaleVertices(0.2);
    model.rotateVerticesX(-PI);
    
    initMinim();
    fluid = new Fluid(this);

}

void draw()
{
    background(0);

    disturb();
    fluid.draw();
    
    ambient(250, 250, 250);
    pointLight(255, 255, 255, 500, height/2, 400);
        
    // PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;
    // GL gl = pgl.beginGL();
    // gl.glEnable( GL.GL_BLEND );
   
    // Motion Blur!
    // fadeToColor(gl, 0, 0, 0, 0.05);
    
    // gl.glBlendFunc(GL.GL_ONE, GL.GL_ONE);
    // gl.glDisable(GL.GL_BLEND);
    // pgl.endGL();
    
    // Ein Partikel an der Mausposition hinzufügen und zufällige Richtung geben
    char surprise = char((byte) random(97, 122));
    
    if (mousePressed == true) {
        // CharParticle p = new CharParticle(surprise);
        ModelParticle p = new ModelParticle(model);
        // Particle p = new Particle();
        ForceField attraction = new ForceField(new PVector (random(width), random(height), 0)).setRadius(30).setStrength(-50);
        p.addForceField(attraction);
        attraction.influence(emitter.getParticles());
        force.influence(p);

        emitter.addParticle(p, mouseX, mouseY, 0).randomizeVelocity(1).addBehavior(new BounceOffWalls(0)).setLifeSpan(random(1000));
        p.addBehavior(new Friction(0.01));
    }
    
    emitter.updateAndDraw();
    debug();   
    
    // Zweites Fenster zeichnen
    controlWindow.redraw(); 
}

// Wird automatisch vom Partikelsystem aufgerufen
void drawParticle (Particle p) 
{
    fill(255 - p.progress * 255);
    noStroke();
    if (p instanceof CharParticle) {
        ((CharParticle) p).draw();      
    } 
    else if (p instanceof ModelParticle) {
        ((ModelParticle) p).draw(); 
    } 
    else {
        stroke(255 - p.progress * 255);
        point(p.x, p.y);
    }
}

void debug () 
{
    noStroke();
    fill(255);
    text("particles: " + emitter.getParticleCount(), width - 120, height - 40); 
    text("framerate: " + (int) frameRate, width - 120, height - 20); 
}

void sliderEvent (Slider s) {
    if (s.id == "radius") {
        force.setRadius(s.getValue());
    } 
    else if (s.id == "strength") {
        force.setStrength(s.getValue());
    }
    else if (s.id == "ramp") {
        force.setRamp(s.getValue());
    }
}

public void initMinim () 
{
    // init Minim and connect to microphone
	minim = new Minim(this);
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

void stop()
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

public void disturb() 
{
    // update microphone data
    int specSize = fftLog.specSize();
    if (mic) {
        fftLog.forward(microphone.mix);
    } else {
        fftLog.forward(sample.mix);
    }
    for (int i = 0; i < fftLog.specSize(); i++) {
	    if(fftLog.getBand(i)>0.1) {
        	float x = (fluid.center.x + sin(TWO_PI / specSize * i) * width / 2) * fluid.invWidth;
                float y = (fluid.center.y + cos(TWO_PI / specSize * i) * height / 2) * fluid.invHeight;
	        fluid.addForce(x, y, -sin(TWO_PI / specSize * i) / 2000, cos(TWO_PI / specSize * i) * -fftLog.getBand(i)/2000);
	        fluid.addForce(1-x, 1-y, sin(TWO_PI / specSize * i) / 2000, -cos(TWO_PI / specSize * i) * -fftLog.getBand(i)/2000);
	    }
    }
}

// Zweites Fenster mit Controls
public class PFrame extends Frame 
{
    public PFrame() 
    {
        setBounds(100,100,400,300);
        controlWindow = new ControlWindow();
        add(controlWindow);
        controlWindow.init();
        show();
    }
}

public class ControlWindow extends PApplet 
{
    ControlP5 controlP5;
    
    public void setup() 
    {
        size(200, 300);
        controlP5 = new ControlP5(this);
        //// Slider für das ForceField
        controlP5 = new ControlP5(this);
        controlP5.addSlider("radius", 0, 1000, 100, 10, 40, 100, 20).setId(1);
        controlP5.addSlider("strength", -50, 50, 10, 10, 65, 100, 20).setId(2);
        controlP5.addSlider("ramp", 0, 2, 1, 10, 90, 100, 20).setId(3);
        controlP5.addSlider("fade speed", 0, 0.1, 0.003, 10, 115, 100, 20).setId(4);
        controlP5.addSlider("delta time", 0, 1, 0.5, 10, 140, 100, 20).setId(5);
        controlP5.addSlider("viscosity", 0, 0.001, 0.0001, 10, 165, 100, 20).setId(6);
    }

    public void draw() 
    {
        background(0);
    }
    
    void controlEvent(ControlEvent theEvent) 
    {
        float v = theEvent.controller().value();

        switch(theEvent.controller().id()) {
            case(1):
                force.setRadius(v);
                break;
            case(2):
                force.setStrength(v);
                break;
            case(3):
                force.setRamp(v);
                break;  
            case(4):
                fluid.fluidSolver.setFadeSpeed(v);
                break;
            case(5):
                fluid.fluidSolver.setDeltaT(v);
                break;
            case(6):
                fluid.fluidSolver.setVisc(v);
                break;
        }
    }
}

// OpenGL Alternative zu backround(c, c, c, alpha);
// void fadeToColor(GL gl, float r, float g, float b, float speed) 
// {
//     gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA);
//     gl.glColor4f(r, g, b, speed);
//     gl.glBegin(GL.GL_QUADS);
//     gl.glVertex2f(0, 0);
//     gl.glVertex2f(width, 0);
//     gl.glVertex2f(width, height);
//     gl.glVertex2f(0, height);
//     gl.glEnd();
// }