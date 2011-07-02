/*
*   »Buchstabensuppe« optimiert für Processing 1.51
*   2011-07-02
*   
*/

import ddf.minim.analysis.*;
import ddf.minim.*;
import codeanticode.glgraphics.*;
import com.getflourish.stt.*;
import controlP5.*;
import geomerative.*;
import damkjer.ocd.*;

AudioInput microphone;
AudioPlayer sample;
Camera cam;
ControlWindow controlWindow;
FFT fftLog;
Fluid fluid;
ForceField force;
GLGraphicsOffScreen canvas;
GLSLShader vertexShader;
Minim minim;
ParticleSystem emitter;
PFrame controlFrame;
PVector light;
RFont font;
Slider2D s;
STT stt;

boolean dome = false;
boolean mic = true;
boolean applyShaders = true;
boolean showDebug = true;
boolean showFluid = false;
boolean showParticles = true;

float exposure, decay, density, weight;
float fluidSize = 2;
float dollyStep = 5;
int maxParticles = 300;

/////////////////////////////////////////////////

public void setup() 
{
    if (dome) {
        size(1920, 1920, GLConstants.GLGRAPHICS);
    } else {
        size(800, 800, GLConstants.GLGRAPHICS);   
    }
    
    frameRate(60);
    hint(ENABLE_OPENGL_4X_SMOOTH);
    
    // Kamera
    cam = new Camera(this, width / 2, height / 2, 1000, 1, 10 * 1000);
    cam.aim(width / 2, height / 2, 0);
    
    vertexShader = new GLSLShader(this, "ls.vert", "ls.frag");
    canvas = new GLGraphicsOffScreen(this, width, height);
    
    light = new PVector(0, 0);
    
    // Zweites Fenster für die Slider in 2D
    controlFrame = new PFrame(this);
    
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
    
    // Shader stuff
    exposure = 1;
    decay = 0.7;
    density = 0.5;
    weight = 0.9;

}

/////////////////////////////////////////////////

public void draw() {
    background(0);        

    // Fluid
    if (showFluid) {
        disturb();
        fluid.draw();
    }
    
    // Lichter
    ambient(250, 250, 250);
    pointLight(255, 255, 255, 500, height/2, 400);
    
    // // OpenGL Motion Blur
    // PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;
    // GL gl = pgl.beginGL();
    // gl.glEnable( GL.GL_BLEND );
    // 
    // fadeToColor(gl, 0, 0, 0, 0.05);
    // 
    // gl.glBlendFunc(GL.GL_ONE, GL.GL_ONE);
    // gl.glDisable(GL.GL_BLEND);
    // pgl.endGL();
    
    // Partikelsystem
    if (showParticles) {
        // Ein Partikel an der Mausposition hinzufügen und zufällige Richtung geben
        char surprise = char((byte) random(97, 122));

        if (mousePressed == true) {
            Particle p = new Particle();
            ForceField attraction = new ForceField(new PVector (random(width), random(height), 0)).setRadius(30).setStrength(-50);
            p.addForceField(attraction);
            attraction.influence(emitter.getParticles());
            force.influence(p);

            emitter.addParticle(p, mouseX, mouseY, 0).randomizeVelocity(1).addBehavior(new BounceOffWalls(0)).setLifeSpan(random(1000));
            p.addBehavior(new Friction(0.01));
        }
        if (applyShaders) {
            // Postprocessing Filter, der so tut als wenn Licht hinter den Buchstaben wäre und diese überstrahlt
            canvas.beginDraw();
                canvas.clear(0);
                // Kamera
                cam.dolly(dollyStep);
                cam.feed();
                emitter.updateAndDraw();

            canvas.endDraw();

            vertexShader.start();
                vertexShader.setFloatUniform("exposure", exposure);
                vertexShader.setFloatUniform("decay", decay);
                vertexShader.setFloatUniform("density", density);
                vertexShader.setFloatUniform("weight", weight);
                vertexShader.setVecUniform("lightPositionOnScreen", light.x, light.y);
                image(canvas.getTexture(), 0, 0, width, height);
            vertexShader.stop();
        } else {
            // Particle System zeichnen
            emitter.updateAndDraw();
        }
    
    }
    // Statusanzeigen mit FPS, Anzahl der Partikel
    if (showDebug) debug();   
    
    // Zweites Fenster mit Slidern
    controlWindow.redraw(); 
}

/////////////////////////////////////////////////

// Wird automatisch vom Partikelsystem aufgerufen

public void drawParticle (Particle p) {
    if(applyShaders) {
        canvas.fill(255 - p.progress * 255);
        canvas.noStroke();
        if (p instanceof CharParticle) {
            canvas.fill(255, 100, 0);
            // Drehen
            float angle = atan2(p.y - height / 2, p.x - width / 2);
            canvas.pushMatrix();
                canvas.translate(p.x, p.y, p.z);
                canvas.rotate(angle);
                canvas.rotate(-HALF_PI);
                ((CharParticle) p).draw(canvas); 
            canvas.popMatrix(); 
        } 
        else {
            canvas.stroke(255 - p.progress * 255);
            canvas.point(p.x, p.y);
        }
    } else {
        fill(255 - p.progress * 255);
        noStroke();
        if (p instanceof CharParticle) {
            fill(255, 100, 0);
            // Drehen
            float angle = atan2(p.y - height / 2, p.x - width / 2);
            pushMatrix();
                translate(p.x, p.y, p.z);
                rotate(angle);
                rotate(-HALF_PI);
                ((CharParticle) p).draw(); 
            popMatrix(); 
        } 
        else {
            stroke(255 - p.progress * 255);
            point(p.x, p.y);
        }
    }
}

// Buchstabenverteilung erstellen
public void createCharacterDistribution () 
{
    int onePercent = emitter.getMaxParticles() / 100;
    HashMap<String, Float> d = Distribution.getDistribution();
    Iterator it = d.entrySet().iterator();
    while (it.hasNext()) 
    {
        Map.Entry pairs = (Map.Entry) it.next();
        
        for (int i = 0; i < 1 + (Float) pairs.getValue() * onePercent; i++) {
            char c = ((String) pairs.getKey()).charAt(0);
            ForceField attraction = new ForceField(new PVector (random(width), random(height), 0)).setRadius(30).setStrength(-50);
            CharParticle p = new CharParticle(c);
            p.addForceField(attraction);
            attraction.influence(emitter.getParticles());
            force.influence(p);
            
            emitter.addParticle(p, random(width), random(height), random(-1000, 1000)).randomizeVelocity(1).addBehavior(new BounceOffWalls(100000)).setLifeSpan(random(10000000));
            p.addBehavior(new Friction(0.01));
        } 
    }
}

public void transcribe (String word, float confidence) {
    // formWord(word.toUpperCase(), new PVector(0, 0, 0));
}

public void formWord (String word, PVector pos) {
    for (int i = 0; i < word.length(); i++) {
        char c = word.charAt(i);
        boolean found = false;
        CharParticle p = getParticleForChar(c);
        ForceField attraction = new ForceField(new PVector(pos.x + i * p.w + 10, pos.y, pos.z)).setRadius(1000).setStrength(10);
        emitter.addForceField(attraction);
        attraction.influence(p);
    }
}

CharParticle getParticleForChar(char c) {
    for (int i = 0; i < emitter.getParticleCount(); i++) {
        if (emitter.getParticles().get(i) instanceof CharParticle) {
            CharParticle p = (CharParticle) emitter.getParticles().get(i);
            if (p.character == c && !p.used) {
                p.used = true;
                return p;   
            }
        }
    }
    CharParticle p = new CharParticle(c);
    emitter.addParticle(p, random(width), random(height), random(100));
    p.used = true;
    return p;
}
public void initMinim () {
    // Minim entweder mit Mikrofon oder MP3 benutzen
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
    // Aktuelles Spektrum holen
    int specSize = fftLog.specSize();
    if (mic) {
        fftLog.forward(microphone.mix);
    } else {
        fftLog.forward(sample.mix);
    }
    // Am Rand der Kuppel Nebel ausstoßen. Pro Frequenz gibt es einen Punkt auf dem Kreis aus dem der Lautstärke entsprechend was rauskommt.
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
    if (key == 'e') formWord("ESSEN", new PVector(mouseX, mouseY, 100));
    if (key == 's') applyShaders = !applyShaders;
    println(frameRate);
}

public void debug () {
    controlWindow.noStroke();
    controlWindow.fill(255);
    controlWindow.text("particles: " + emitter.getParticleCount(), width - 120, height - 40); 
    controlWindow.text("framerate: " + (int) frameRate, width - 120, height - 20); 
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