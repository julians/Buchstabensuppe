/*
*   »Buchstabensuppe« optimiert für Processing 1.51
*   2011-07-02
*   
*/

import codeanticode.glgraphics.*;
import com.getflourish.stt.*;
import controlP5.*;
import damkjer.ocd.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import geomerative.*;
import netP5.*;
import oscP5.*;
import processing.opengl.*;

  
AudioInput microphone;
AudioPlayer sample;
Camera cam;
CharCloud cloud;
ControlWindow controlWindow;
FFT fftLog;
Fluid fluid;
ForceField force;
GLGraphicsOffScreen canvas;
GLModel distributionGraph;
GLSLShader phongShader;
GLSLShader vertexShader;
GLTexture backgroundTex;
GLTexture cloudTex;
Minim minim;
NetAddress myRemoteLocation;
OscP5 oscP5;
PFrame controlFrame;
PVector light;
RFont font;
Slider2D s;
STT stt;
Timeline timeline;


boolean dome = false;
boolean mic = true;
boolean applyShaders = true;
boolean showDebug = true;
boolean showFluid = false;
boolean showParticles = true;
boolean showTimeline = false;

float exposure, decay, density, weight;
float fluidSize = 2;
float dollyStep = -5;
int maxParticles = 100;

/////////////////////////////////////////////////

public void setup() 
{
    // Grafik
    if (dome) {
        size(1920, 1920, GLConstants.GLGRAPHICS);
    } else {
        size(800, 800, GLConstants.GLGRAPHICS);   
    }
    frameRate(30);
    hint(ENABLE_OPENGL_4X_SMOOTH);
    
    // OSC
    oscP5 = new OscP5(this,12000);
    
    // Kamera
    cam = new Camera(this, width / 2, height / 2, 5000, 1, 10 * 1000);
    cam.aim(width / 2, height / 2, 0);
    
    // Shader
    vertexShader = new GLSLShader(this, "ls.vert", "ls.frag");
    phongShader = new GLSLShader(this, "ps.vert", "ps.frag");
    canvas = new GLGraphicsOffScreen(this, width, height);
    
    backgroundTex = new GLTexture(this, "background.jpg");
    cloudTex = new GLTexture(this, "cloud.png");
    
    light = new PVector(0.5, 0.5);
    
    // Zweites Fenster für die Slider in 2D
    controlFrame = new PFrame(this);
    
    // STT
    stt = new STT(this, false);
    // stt.enableDebug();
    stt.setLanguage("de");
    
    // Font für geomerative
    RG.init(this);
    font = new RFont("lucon.ttf", 32, RFont.CENTER);
    
    // Font für Statusanzeige
    controlWindow.textFont(createFont("Courier", 12));
    
    // Fluid
    // initMinim();
    fluid = new Fluid(this);
    
    // Partikelsystem erstellen
    cloud = new CharCloud(this, maxParticles);
    cloud.enableGravity(0);
    cloud.addGlobalVelocity(0, 0, 0);
    force = new ForceField(new PVector (width / 2, height / 2, 5000)).setRadius(50).setStrength(100).show();
    cloud.addForceField(force);
    
    timeline = new Timeline();
    
    // Shader stuff
    exposure = 1;
    decay = 0.7;
    density = 0.5;
    weight = 0.9;

}

/////////////////////////////////////////////////

public void draw() {
    // background(65, 95, 170);   
    background(0);

    // Fluid
    if (showFluid) {
        disturb();
        fluid.draw();
    }
    
    // Lichter
    ambient(250, 250, 250);
    pointLight(255, 255, 255, 500, height/2, 400);
    
    // Statischer Hintergrund
    // image(backgroundTex, 0, 0, width, height);
    
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
            attraction.influence(cloud.getParticles());
            force.influence(p);

            cloud.addParticle(p, mouseX, mouseY, 0).randomizeVelocity(1).addBehavior(new BounceOffWalls(0)).setLifeSpan(random(1000));
            p.addBehavior(new Friction(0.01));
        }
        if (applyShaders) {
            // Postprocessing Filter, der so tut als wenn Licht hinter den Buchstaben wäre und diese überstrahlt
            canvas.beginDraw();
                // Die alten Pixel durch transparente ersetzen, sodass der Hintergrund sichtbar bleibt
                canvas.clear(0);
                canvas.background(0);
                // Lichter
                ambient(0, 0, 250);
                pointLight(175, 189, 255, width / 2, height/2, 9000);
                // Kamera
                cam.dolly(dollyStep);
                cam.feed();
                // Wolken
                // canvas.tint(255, 192);
                // for (int i = 0; i < 10; i++) {
                //     canvas.pushMatrix();
                //         canvas.translate(0, 0, i * 1000);
                //         canvas.image(cloudTex, 0, 0, cloudTex.width * i, cloudTex.height * i);
                //     canvas.popMatrix();
                // }
                    
                // Partikelsystem zeichnen
                cloud.updateAndDraw(canvas);
                if (showTimeline) {
                    canvas.pushMatrix();
                        canvas.translate(mouseX, mouseY, 5000);
                        timeline.draw(canvas);
                    canvas.popMatrix();
                }
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
            // Partikelsystem zeichnen
            // Kamera
            cam.dolly(dollyStep);
            cam.feed();
            cloud.updateAndDraw();
        }
    }  
        
    // Statusanzeigen mit FPS, Anzahl der Partikel
    if (showDebug) debug();
}

/////////////////////////////////////////////////

// Wird automatisch vom Partikelsystem aufgerufen

public void drawParticle (Particle p) {
    // In die Textur zeichnen wenn Shader aktiviert sind
    if(applyShaders) {
        canvas.fill(255 - p.progress * 255);
        if (p instanceof CharParticle) {
            canvas.fill(255);
            canvas.noStroke();
            // canvas.fill(255, 100, 0);
            // Drehen
            float angle = atan2(p.y - height / 2, p.x - width / 2);
            canvas.pushMatrix();
                canvas.translate(p.x, p.y, p.z);
                // canvas.rotate(angle);
                // canvas.rotate(-HALF_PI);
                ((CharParticle) p).draw(canvas); 
            canvas.popMatrix(); 
        } 
        else {
            canvas.beginShape(POINTS);
            canvas.stroke(255);
            canvas.vertex(p.x, p.y, p.z);
            canvas.endShape(CLOSE);
        }
    // Ganz normal zeichnen
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

void initDistributionGraph() {
    distributionGraph = new GLModel(this, Distribution.getCount(), LINE_STRIP, GLModel.STATIC);
    distributionGraph.beginUpdateVertices();
    
    int index = 0;
    HashMap<String, Float> d = Distribution.getDistribution();
    Iterator it = d.entrySet().iterator();
    while (it.hasNext()) 
    {
        Map.Entry pairs = (Map.Entry) it.next();
        char c = ((String) pairs.getKey()).charAt(0);
        float value = (Float) pairs.getValue();
        float size = 4;
        float x = (width / 2 + sin(TWO_PI / Distribution.getCount() * index) * (2 + width / value));
        float y = (height / 2 + cos(TWO_PI / Distribution.getCount() * index) * (2 + height / value));
        distributionGraph.updateVertex(index++, x, y, value);
    }
    distributionGraph.endUpdateVertices();
    distributionGraph.initColors();
    distributionGraph.setColors(255);
}
public void transcribe (String word, float confidence, int status) {
    switch (status) {
        case STT.SUCCESS:
            cloud.formWord(word, new PVector(width / 2, height / 2, cam.position()[2]));       
            break;
        case STT.RECORDING:
            cloud.reactOnRecord();
            break;
        case STT.ERROR:
            cloud.reactOnError();
            break;
    }
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
    if (key == 'e') cloud.formWord("Essen", new PVector(mouseX, mouseY, cam.position()[2]));
    if (key == 's') applyShaders = !applyShaders;
    if (key == 't') showTimeline = !showTimeline;
    println(cam.position()[2]);
    println(frameRate);
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
    }
}

public void debug () {
    stroke(255);
    fill(255);
    text("particles: " + cloud.getParticleCount(), 10, 10); 
    text("framerate: " + (int) frameRate, 10, 30); 
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