import geomerative.*;
import controlP5.*;

import com.getflourish.stt.*;

import ddf.minim.analysis.*;
import ddf.minim.*;

ParticleSystem emitter;
ForceField force;
int maxParticles = 200;

RFont font;

PShape3D model;

PFrame controlFrame;
ControlWindow controlWindow;

Fluid fluid;
float fluidSize = 2;

// Audio
Minim minim;
AudioInput microphone;
AudioPlayer sample;
FFT fftLog;
boolean mic = false;

// Modes
boolean showFluid = true;
boolean showParticles = false;
boolean showDebug = true;
boolean dome = false;

// STT
STT stt;

void setup() {
    if (dome) {
        size(1920, 1920, OPENGL);
    } else {
        size(800, 800, OPENGL);   
    }
    hint(ENABLE_OPENGL_4X_SMOOTH);
    
    // Zweites Fenster für die Slider in 2D
    controlFrame = new PFrame();
    
    // STT
    stt = new STT(this, false);
    stt.enableDebug();
    stt.setLanguage("de");
    
    // Font für geomerative
    RG.init(this);
    font = new RFont("lucon.ttf", 32, RFont.CENTER);
    
    // Font für Statusanzeige
    textFont(createFont("Courier", 12));
    
    // Fluid
    initMinim();
    fluid = new Fluid(this);
    
    // Partikelsystem mit maximal 1000 Partikeln erstellen
    emitter = new ParticleSystem(this, maxParticles);
    emitter.enableGravity(0);
    emitter.addGlobalVelocity(0, 0, 0);
    force = new ForceField(new PVector (width / 2, height / 2, 0)).setRadius(50).setStrength(100).show();
    emitter.addForceField(force);
    
    createCharacterDistribution();

}

void draw() {
    background(0);
    
    // Fluid
    if (showFluid) {
        disturb();
        fluid.draw();
    }
    
    // Lichter
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
    
    // Partikelsystem
    if (showParticles) {
        // Ein Partikel an der Mausposition hinzufügen und zufällige Richtung geben
        char surprise = char((byte) random(97, 122));

        if (mousePressed == true) {
            // CharParticle p = new CharParticle(surprise);
            // ModelParticle p = new ModelParticle(model);
            Particle p = new Particle();
            ForceField attraction = new ForceField(new PVector (random(width), random(height), 0)).setRadius(30).setStrength(-50);
            p.addForceField(attraction);
            attraction.influence(emitter.getParticles());
            force.influence(p);

            emitter.addParticle(p, mouseX, mouseY, 0).randomizeVelocity(1).addBehavior(new BounceOffWalls(0)).setLifeSpan(random(1000));
            p.addBehavior(new Friction(0.01));
        }
        
        emitter.updateAndDraw();
    }
    // Statusanzeigen mit FPS, Anzahl der Partikel
    if (showDebug) debug();   
    
    // Zweites Fenster mit Slidern
    controlWindow.redraw(); 
}

// Wird automatisch vom Partikelsystem aufgerufen
void drawParticle (Particle p) {
    fill(255 - p.progress * 255);
    noStroke();
    if (p instanceof CharParticle) {
        fill(255 - p.progress * 255);
        ((CharParticle) p).draw();      
    } 
    else if (p instanceof ModelParticle) {
        // Drehen
        float angle = atan2(p.y - height / 2, p.x - width / 2);
        pushMatrix();
            translate(p.x, p.y, p.z);
            rotate(angle);
            rotate(-HALF_PI);
        
            //  fill(255 - p.progress * 255);
            ((ModelParticle) p).draw(); 
        popMatrix();
        
    } 
    else {
        stroke(255 - p.progress * 255);
        point(p.x, p.y);
    }
}

// Buchstabenverteilung erstellen
void createCharacterDistribution () {
    int onePercent = emitter.getMaxParticles() / 100;
    HashMap<String, Float> d = Distribution.getDistribution();
    println(d);
    Iterator it = d.entrySet().iterator();
      while (it.hasNext()) {
          Map.Entry pairs = (Map.Entry) it.next();
          
          // Model laden
          model = (PShape3D)loadShape((String) pairs.getKey() + ".obj");
          model.scaleVertices(0.2);
          model.rotateVerticesX(-PI);
          
          for (int i = 0; i < 1 + (Float) pairs.getValue() * onePercent; i++) {
              
              char c = ((String) pairs.getKey()).charAt(0);
              // CharParticle p = new CharParticle(c);
              ModelParticle p = new ModelParticle(model, c);
              ForceField attraction = new ForceField(new PVector (random(width), random(height), 0)).setRadius(30).setStrength(-50);
              p.addForceField(attraction);
              attraction.influence(emitter.getParticles());
              force.influence(p);
              
              emitter.addParticle(p, random(width), random(height), random(0)).randomizeVelocity(1).addBehavior(new BounceOffWalls(1000)).setLifeSpan(random(10000000));
              p.addBehavior(new Friction(0.01));
          } 
      }
}

void transcribe (String word, float confidence) {
    formWord(word.toUpperCase());
}

void formWord (String word) {
    for (int i = 0; i < word.length(); i++) {
        char c = word.charAt(i);
        boolean found = false;
        for (int j = 0; j < emitter.getParticles().size(); j++) {
            ModelParticle buh = (ModelParticle) emitter.getParticles().get(j);
               
                if (buh.character != (c)) {
                 emitter.removeParticle(buh);
                } else if (!found && buh.character == (c)){
                    emitter.clearForces(buh);
                    ForceField attraction = new ForceField(new PVector (width / 2 + i * 20, height / 2, 100)).setRadius(1000).setStrength(10);
                    emitter.addForceField(attraction);
                    attraction.influence(buh);
                    buh.addBehavior(new Friction(0.1));
                    found = true;
                    println(c);
                }
          
        }
        if (!found) {
            // Model laden
            model = (PShape3D)loadShape(c + ".obj");
            // model.scaleVertices(0.2);
            // model.rotateVerticesX(-PI);
            
            ModelParticle buh = new ModelParticle(model, c);
            emitter.addParticle(buh, random(width), random(height), random(100)).randomizeVelocity(1).setLifeSpan(random(10000000));
            ForceField attraction = new ForceField(new PVector (width / 2 + i * 20, height / 2, 100)).setRadius(1000).setStrength(10);
            emitter.addForceField(attraction);
            attraction.influence(buh);
            //buh.addBehavior(new Friction(0.1));
            println(c);
        }

    }
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

public void initMinim () {
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

public void disturb() {
    // update microphone data
    int specSize = fftLog.specSize();
    if (mic) {
        fftLog.forward(microphone.mix);
    } else {
        fftLog.forward(sample.mix);
    }
    for (int i = 0; i < fftLog.specSize(); i++) {
	    if(fftLog.getBand(i)>0.1) {
        	float x = (fluid.center.x + sin(TWO_PI / specSize * i) * (width / fluidSize)) * fluid.invWidth;
            float y = (fluid.center.y + cos(TWO_PI / specSize * i) * (height / fluidSize) ) * fluid.invHeight;
	        fluid.addForce(x, y, -sin(TWO_PI / specSize * i) / 2000, cos(TWO_PI / specSize * i) * -fftLog.getBand(i)/2000);
	        fluid.addForce(1-x, 1-y, sin(TWO_PI / specSize * i) / 2000, -cos(TWO_PI / specSize * i) * -fftLog.getBand(i)/2000);
	    }
    }
}

public void keyPressed () {
    if (key == 'f') showFluid = !showFluid;
    if (key == 'p') showParticles = !showParticles;
    if (key == 'w') formWord("ESSEN");
}

void debug () {
    controlWindow.noStroke();
    controlWindow.fill(255);
    controlWindow.text("particles: " + emitter.getParticleCount(), width - 120, height - 40); 
    controlWindow.text("framerate: " + (int) frameRate, width - 120, height - 20); 
}

void stop() {
  if (mic) {
      microphone.close();
  } 
  else {
      sample.close();
  }
  minim.stop();
  super.stop();
}

// Zweites Fenster mit Controls
public class PFrame extends Frame 
{
    public PFrame() 
    {
        setBounds(100, 100, 200, 300);
        controlWindow = new ControlWindow();
        add(controlWindow);
        controlWindow.init();
        show();
    }
}

public class ControlWindow extends PApplet 
{
    ControlP5 controlP5;
    
    public void setup() {
        size(200, 300);
        controlP5 = new ControlP5(this);
        //// Slider für das ForceField
        controlP5 = new ControlP5(this);
        controlP5.addSlider("radius", 0, 1000, 100, 10, 40, 100, 20).setId(1);
        controlP5.addSlider("strength", -50, 50, 10, 10, 65, 100, 20).setId(2);
        controlP5.addSlider("ramp", 0, 2, 1, 10, 90, 100, 20).setId(3);
        controlP5.addSlider("fade speed", 0, 0.1, 0.05, 10, 115, 100, 20).setId(4);
        controlP5.addSlider("delta time", 0, 1, 0.06, 10, 140, 100, 20).setId(5);
        controlP5.addSlider("viscosity", 0, 0.001, 0.00004, 10, 165, 100, 20).setId(6);
        controlP5.addSlider("fluid size", 1, 4, 2, 10, 190, 100, 20).setId(7);
        controlP5.addSlider("force z", -100, 100, 0, 10, 215, 100, 20).setId(8);
    }

    public void draw() {
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
            case(7):
                fluidSize = v;
                break;
            case(8):
                force.setPosition(force.x, force.y, v);
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