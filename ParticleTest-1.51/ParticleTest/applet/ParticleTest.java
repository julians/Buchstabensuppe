import processing.core.*; 
import processing.xml.*; 

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
import java.util.HashMap; 
import msafluid.*; 
import processing.opengl.*; 
import javax.media.opengl.*; 
import java.lang.reflect.InvocationTargetException; 
import java.lang.reflect.Method; 

import saito.objloader.*; 
import msafluid.*; 
import com.google.gson.annotations.*; 
import netP5.*; 
import com.google.gson.stream.*; 
import damkjer.ocd.*; 
import geomerative.*; 
import codeanticode.glgraphics.*; 
import processing.net.*; 
import controlP5.*; 
import oscP5.*; 
import com.google.gson.*; 
import org.apache.batik.svggen.font.table.*; 
import com.getflourish.stt.*; 
import com.google.gson.internal.*; 
import com.google.gson.reflect.*; 
import org.apache.batik.svggen.font.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class ParticleTest extends PApplet {

/*
*   \u00bbBuchstabensuppe\u00ab optimiert f\u00fcr Processing 1.51
*   2011-07-02
*   
*/












  
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
    
    light = new PVector(0.5f, 0.5f);
    
    // Zweites Fenster f\u00fcr die Slider in 2D
    controlFrame = new PFrame(this);
    
    // STT
    stt = new STT(this, false);
    // stt.enableDebug();
    stt.setLanguage("de");
    
    // Font f\u00fcr geomerative
    RG.init(this);
    font = new RFont("lucon.ttf", 32, RFont.CENTER);
    
    // Font f\u00fcr Statusanzeige
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
    decay = 0.7f;
    density = 0.5f;
    weight = 0.9f;

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
        // Ein Partikel an der Mausposition hinzuf\u00fcgen und zuf\u00e4llige Richtung geben
        char surprise = PApplet.parseChar((byte) random(97, 122));

        if (mousePressed == true) {
            Particle p = new Particle();
            ForceField attraction = new ForceField(new PVector (random(width), random(height), 0)).setRadius(30).setStrength(-50);
            p.addForceField(attraction);
            attraction.influence(cloud.getParticles());
            force.influence(p);

            cloud.addParticle(p, mouseX, mouseY, 0).randomizeVelocity(1).addBehavior(new BounceOffWalls(0)).setLifeSpan(random(1000));
            p.addBehavior(new Friction(0.01f));
        }
        if (applyShaders) {
            // Postprocessing Filter, der so tut als wenn Licht hinter den Buchstaben w\u00e4re und diese \u00fcberstrahlt
            canvas.beginDraw();
                // Die alten Pixel durch transparente ersetzen, sodass der Hintergrund sichtbar bleibt
                phongShader.start();
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
                phongShader.stop();
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

public void initDistributionGraph() {
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
    // Am Rand der Kuppel Nebel aussto\u00dfen. Pro Frequenz gibt es einen Punkt auf dem Kreis aus dem der Lautst\u00e4rke entsprechend was rauskommt.
    for (int i = 0; i < fftLog.specSize(); i++) {
	    if(fftLog.getBand(i)>0.1f) {
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

public void oscEvent(OscMessage theOscMessage) {
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
class Behavior 
{   
    Behavior () 
    {
    }
    public void apply (Particle p, Object data) 
    {

    }
    public void apply (Particle p) 
    {
        this.apply(p, null);
    }
}
class BounceOffWalls extends Behavior 
{
    float bz;
    
    BounceOffWalls (float bz)
    {
        super();
        this.bz = bz;
    }
    public void apply (Particle p) {
        // bounce of edges left and right
        if (p.position.x < 0 + p.size) {
            p.position.x = 0 + p.size;
            p.velocity.x *= -1;
        }
        else if (p.position.x > width - p.size) {
            p.position.x = width - p.size;
            p.velocity.x *= -1;
        }
        // top and bottom
        if (p.position.y < 0 + p.size) {
            p.position.y = 0 + p.size;
            p.velocity.y *= -1;
        }
        else if (p.position.y > height - p.size) {
            p.position.y = height - p.size;
            p.velocity.y *= -1;
        }
        // front and back
        if (p.position.z < -bz) {
            p.position.z = -bz;
            p.velocity.z *= -1;
        }
        else if (p.position.z > bz) {
            p.position.z = bz;
            p.velocity.z *= -1;
        }
    }
}
public class CharCloud extends ParticleSystem
{
    HashMap<String, Word> words;
    PVector target;
    int letterspacing = 20;
    
    public CharCloud (PApplet p5) {
        this(p5, -1);
    }
    
    public CharCloud (PApplet p5, int max) {
        super(p5, max);
        words = new HashMap<String, Word>();
        init();
    }
    
    public void addWord (String s) {}
    public void removeWord (String s) {} // aufl\u00f6sen oder so
    
    public void formWord () {}
    
    // public ArrayList<String> getKeys () {}
    // public ArrayList<String> getValues () {}
    
    public void init () 
    {
        // create characters based on their distribution in German language
        int onePercent = getMaxParticles() / 100;
        HashMap<String, Float> d = Distribution.getDistribution();
        Iterator it = d.entrySet().iterator();
        while (it.hasNext()) 
        {
            Map.Entry pairs = (Map.Entry) it.next();

            // todo: Find a better solution for lower and upper case distribution
            char c;
            for (int i = 0; i < 1 + (Float) pairs.getValue() * onePercent; i++) {
                if ((int) random(1) == 0) {
                    c = ((String) pairs.getKey()).charAt(0);
                } else {
                    c = (((String) pairs.getKey()).toLowerCase()).charAt(0); 
                }
                // ForceField attraction = new ForceField(new PVector (random(width), random(height), 0)).setRadius(30).setStrength(-50);            
                CharParticle p = new CharParticle(p5, c);
                // p.addForceField(attraction);
                // attraction.influence(emitter.getParticles());

                addParticle(p, random(width), random(height), random(1000, 10000)).randomizeVelocity(1).setLifeSpan(-1);
                p.addBehavior(new Friction(0.01f));
            } 
        }
    }
    
    public void formWord (String word, PVector pos) {
        println(word);
        target = pos;
        PVector displace = new PVector(0, 0, 0);
        for (int i = 0; i < word.length(); i++) {
            char c = word.charAt(i);
            CharParticle p = getParticleForChar(c);
            p.tweenTo(PVector.add(pos, displace));
            displace.add(new PVector(letterspacing, 0, 0));
            p.disableForces();
            p.resetRotation();
        }
        stopFXSpin();
    }
    public void reactOnRecord () {
        for (int i = 0; i < particles.size(); i++) {
            if (particles.get(i) instanceof CharParticle) {
                CharParticle p = (CharParticle) particles.get(i);
                if (!p.used) {
                    p.startFXSpin(); 
                }
            }
        }
    }
    public void reactOnError () {
        stopFXSpin();
    }
    public void stopFXSpin () {
        for (int i = 0; i < particles.size(); i++) {
            if (particles.get(i) instanceof CharParticle) {
                CharParticle p = (CharParticle) particles.get(i);
                if (!p.used) {
                    p.stopFXSpin(); 
                }
            }
        }
    }

    public CharParticle getParticleForChar(char c) {
        for (int i = 0; i < particles.size(); i++) {
            if (particles.get(i) instanceof CharParticle) {
                CharParticle p = (CharParticle) particles.get(i);
                if (p.character == c && !p.used) {
                    p.used = true;
                    return p;   
                }
            }
        }
        CharParticle p = new CharParticle(p5, c);
        addParticle(p, random(width), random(height), target.z + random(100)).randomizeVelocity(1).setLifeSpan(-1);
        p.used = true;
        return p;
    }
}
class CharParticle extends Particle
{
    boolean fxSpin = false;
    boolean flat = false;
    boolean used = false;
    char character;
    float extrusion = 3;
    float spin = random(0.2f);
    float spinAccel;
    float spinAccelStart;
    float maxSpin = 1;
    float width;
    GLModel vertices;
    float rx, ry;
    PApplet p;
    RMesh m1;
    RPoint[][] pnts;
    RShape shp;


    CharParticle (PApplet p, char c) {
      super();
      this.character = c;
      this.p = p;
      setup();
    }     

    public void setup() 
    { 
        shp = font.toShape(this.character);
        RCommand.setSegmentator(RCommand.UNIFORMSTEP);
        // RCommand.setSegmentStep(1);
        // RCommand.setSegmentAngle(HALF_PI);
        pnts = shp.getPointsInPaths();
        m1 = shp.toMesh();
        
        int verticeCount = 0;
        // for (int i = 0; i < m1.countStrips(); i++){
        //   for(int j=0;j<m1.strips[i].vertices.length;j++){
        //     verticeCount++;
        //   }
        // }
        
        for (int i = 0; i < m1.countStrips(); i++) {
            RPoint[] pts = m1.strips[i].getPoints();
            for(int j=0;j<pts.length;j++){
                    verticeCount++;
            }
        }
        
        // for (int i = 0; i < pnts.length; i++) {
        //      for (int ii = 0; ii < pnts[i].length; ii++)
        //      {
        //          verticeCount++;
        //      }
        // }
        
        // vertices = new GLModel(p, verticeCount, TRIANGLE_STRIP, GLModel.DYNAMIC);
        // generateModel();
        calcWidth();
        spinAccel = random(0.005f);
        spinAccelStart = spinAccel;
        
    }

    public void draw() 
    {
        pushMatrix();   
        
        // flat = (z < 0) ? true : false;

        if (flat) {
          text(character, 0, 0);
        } 
        else { 
            
            if (fxSpin && spin < 3) {
                spin *= spinAccel;
            } else if (!fxSpin && spin != 0){
                spin /= spinAccel;
            }
            
            ry += spin;
            rotateY(spin);
            
            for (int i = 0; i < pnts.length; i++) {
                 beginShape(QUAD_STRIP);
                 for (int ii = 0; ii < pnts[i].length; ii++)
                 {
                     vertex(pnts[i][ii].x, pnts[i][ii].y, 0);
                     vertex(pnts[i][ii].x, pnts[i][ii].y, extrusion);
                 }
                 endShape(CLOSE);
            
            }
            m1.draw();
            translate(0, 0, extrusion);
            m1.draw();
        }
        popMatrix();
    }
    public void draw (GLGraphicsOffScreen canvas) {
        int v;
        canvas.pushMatrix();   
        
        // flat = (z < 0) ? true : false;
        
        if (flat) {
            canvas.text(character, 0, 0);
        } 
        else 
        { 
            // stupid
            if (fxSpin && Math.abs(spin) < maxSpin) {
                spin += spinAccel;
            } else if (!fxSpin && spin != 0){
                spin -= spinAccel;
            } else {

            }
            ry += spin;
            if(ry > 0) canvas.rotateY(ry);
            else ry = 0;
            
            for (int i = 0; i < pnts.length; i++) {
                 canvas.beginShape(QUAD_STRIP);
                 for (int ii = 0; ii < pnts[i].length; ii++)
                 {
                     canvas.vertex(pnts[i][ii].x, pnts[i][ii].y, 0);
                     canvas.vertex(pnts[i][ii].x, pnts[i][ii].y, extrusion);
                 }
                 canvas.endShape(CLOSE);
           
            }
           
            drawFace(canvas);
            canvas.translate(0, 0, extrusion);
            drawFace(canvas);
            
            // 
            // canvas.beginGL();
            // canvas.fill(255);
            // canvas.model(vertices);
            // canvas.endGL();   
        }
        canvas.popMatrix();
    }
    public void drawFace(GLGraphicsOffScreen canvas) {
        for (int i = 0; i < m1.countStrips(); i++){
          canvas.beginShape(PConstants.TRIANGLE_STRIP);
          for(int j=0;j<m1.strips[i].vertices.length;j++){
            canvas.vertex(m1.strips[i].vertices[j].x,m1.strips[i].vertices[j].y);
          }
          canvas.endShape(PConstants.CLOSE);
        }
        
    }
    public void generateModel () {
        
        int v = 0;
        vertices.beginUpdateVertices();
        for (int i = 0; i < m1.countStrips(); i++) {
            RPoint[] pts = m1.strips[i].getPoints();
            for(int j=0;j<pts.length;j++){
                    vertices.updateVertex(v++, pts[j].x, pts[j].y, 0);
            }
        }
        // for (int i = 0; i < pnts.length; i++) {
        //      for (int ii = 0; ii < pnts[i].length; ii++)
        //      {
        //          vertices.updateVertex(v++, pnts[i][ii].x, pnts[i][ii].y, 0);
        //          vertices.updateVertex(v++, pnts[i][ii].x, pnts[i][ii].y, 3);
        //      }
        // }
        vertices.endUpdateVertices(); 
        vertices.initColors();
        vertices.setColors(255);
    }
    private void calcWidth () {
        for (int i = 0; i < pnts.length; i++) {
             for (int ii = 0; ii < pnts[i].length; ii++)
             {
                 if (pnts[i][ii].x > this.width) this.width = pnts[i][ii].x;
             }        
        }
    }
    public float getWidth () {
        return this.width;
    }
    public void startFXSpin() {
        fxSpin = true;
        spinAccel = spinAccelStart;
    }
    public void stopFXSpin () {
        fxSpin = false;
        spinAccel = spinAccelStart;
    }
      
    public void resetRotation() 
    {
        canvas.rotateX(-rx);
        canvas.rotateY(-ry);
    }
}

public static class Colors 
{
    public static float FLUID_H = 360;
    public static float FLUID_S = 100;
    public static float FLUID_B = 100;
    
}
public class ControlWindow extends PApplet 
{
    
    ControlP5 controlP5;
    PApplet p;
    Slider2D s;
    
    ControlWindow(PApplet p) 
    {
        this.p = p;
        this.controlP5 = new ControlP5(p);
    }
    
    public void setup() {
        size(200, 600);
        controlP5 = new ControlP5(this);
        //// Slider f\u00fcr das ForceField
        controlP5 = new ControlP5(this);
        controlP5.addSlider("radius", 0, 5000, 100, 10, 40, 100, 20).setId(1);
        controlP5.addSlider("strength", -50, 50, 10, 10, 65, 100, 20).setId(2);
        controlP5.addSlider("ramp", 0, 2, 1, 10, 90, 100, 20).setId(3);
        controlP5.addSlider("fade speed", 0, 0.1f, 0.05f, 10, 115, 100, 20).setId(4);
        controlP5.addSlider("delta time", 0, 1, 0.06f, 10, 140, 100, 20).setId(5);
        controlP5.addSlider("viscosity", 0, 0.001f, 0.00004f, 10, 165, 100, 20).setId(6);
        controlP5.addSlider("fluid size", 1, 4, 2, 10, 190, 100, 20).setId(7);
        controlP5.addSlider("force z", -100, 100, 0, 10, 215, 100, 20).setId(8);
        
        controlP5.addSlider("exposure", 0, 1, 1.0f, 10, 240, 100, 20).setId(9);
        controlP5.addSlider("decay", 0, 1, 0.7f, 10, 265, 100, 20).setId(10);
        controlP5.addSlider("density", 0, 1, 0.7f, 10, 290, 100, 20).setId(11);
        controlP5.addSlider("weight", 0, 1, 0.9f, 10, 315, 100, 20).setId(12);

        s = controlP5.addSlider2D("light position",10,340,100,100);
        s.setMaxX(1.0f);
        s.setMaxY(1.0f);
        s.setId(13);
        
        controlP5.addSlider("dolly step", -50, 50, 5, 10, 465, 100, 20).setId(14);
    
    }

    public void draw() {
        background(0);
    }
    
    public void controlEvent(ControlEvent theEvent) 
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
            case(9):
                exposure = v;
                break;
            case(10):
                decay = v;
                break;
            case(11):
                density = v;
                break;  
            case(12):
                weight = v;
                break;
            case(13):
                light.x = s.arrayValue()[0];
                light.y = s.arrayValue()[1];
                break;
            case(14):
                dollyStep = v;
                break;
        }
    }
}


public static class Distribution 
{
    final static float E = 17.40f;
    final static float N = 9.78f;
    final static float I = 7.55f;
    final static float S = 7.27f;
    final static float R = 7.00f;
    final static float A = 6.51f;
    final static float T = 6.15f;
    final static float D = 5.08f;
    final static float H = 4.76f;
    final static float U = 4.35f;
    final static float L = 3.44f;
    final static float C = 3.06f;
    final static float G = 3.01f;
    final static float M = 2.53f;
    final static float O = 2.51f;
    final static float B = 1.89f;
    final static float W = 1.89f;
    final static float F = 1.66f;
    final static float K = 1.21f;
    final static float Z = 1.13f;
    final static float P = 0.79f;
    final static float V = 0.67f;
    final static float J = 0.27f;
    final static float Y = 0.04f;
    final static float X = 0.03f;
    final static float Q = 0.02f;
    
    static HashMap<String, Float> distribution;
    static boolean ready = false;

    public Distribution () 
    {

    }
    
    public final static HashMap<String, Float> getDistribution () {
        if (!ready) {
            distribution = new HashMap<String, Float>();
            distribution.put("E", 17.40f);
            distribution.put("N", 9.78f);
            distribution.put("I", 7.55f);
            distribution.put("S", 7.27f);
            distribution.put("R", 7.00f);
            distribution.put("A", 6.51f);
            distribution.put("T", 6.15f);
            distribution.put("D", 5.08f);
            distribution.put("H", 4.76f);
            distribution.put("U", 4.35f);
            distribution.put("L", 3.44f);
            distribution.put("C", 3.06f);
            distribution.put("G", 3.01f);
            distribution.put("M", 2.53f);
            distribution.put("O", 2.51f);
            distribution.put("B", 1.89f);
            distribution.put("W", 1.89f);
            distribution.put("F", 1.66f);
            distribution.put("K", 1.21f);
            distribution.put("Z", 1.13f);
            distribution.put("P", 0.79f);
            distribution.put("V", 0.67f);
            distribution.put("J", 0.27f);
            distribution.put("Y", 0.04f);
            distribution.put("X", 0.03f);
            distribution.put("Q", 0.02f);
        }
        ready = true;
        return distribution;
    }
    public static float getChar (String c) {
        return distribution.get(c);
    }
    public static int getCount() {
        return distribution.size();
    }

}

 



public class Fluid 
{
    // PApplet
    PApplet p;

    // Fluid 
    public MSAFluidSolver2D fluidSolver;
    PImage imgFluid;
    boolean drawFluid = true;
    float FLUID_WIDTH = 120; 
    public float invWidth, invHeight;    // inverse of screen dimensions
    public float aspectRatio, aspectRatio2;

    PVector center;
    
    public Fluid (PApplet p) 
    {
        this.p = p;
        init();
    }
    
    public void init () {
        invWidth = 1.0f / p.width;
        invHeight = 1.0f / p.height;
        aspectRatio = p.width * invHeight;
        aspectRatio2 = aspectRatio * aspectRatio;

        // create fluid and set options
        fluidSolver = new MSAFluidSolver2D((int)(FLUID_WIDTH), (int)(FLUID_WIDTH * p.height / p.width));
        fluidSolver.enableRGB(true).setFadeSpeed(0.02f).setDeltaT(0.07f).setVisc(0.00004f);

        // create image to hold fluid picture
        imgFluid = createImage(fluidSolver.getWidth(), fluidSolver.getHeight(), RGB);

        center = new PVector(p.width / 2, p.height / 2);
    }

    public void draw () {
        fluidSolver.update();
        noFill();
        noTint();

        if(drawFluid) {
            for(int i=0; i<fluidSolver.getNumCells(); i++) {
                int d = 2;
                imgFluid.pixels[i] = color(fluidSolver.r[i] * d, fluidSolver.g[i] * d, fluidSolver.b[i] * d);
            }  
            imgFluid.updatePixels();  
            p.image(imgFluid, 0, 0, width, height);
        } 
    }

    // add force and dye to fluid, and create particles
    public void addForce(float x, float y, float dx, float dy) {
        float speed = dx * dx  + dy * dy * aspectRatio2;    // balance the x and y components of speed with the screen aspect ratio

        if (speed > 0) {
            if(x<0) x = 0; 
            else if(x>1) x = 1;
            if(y<0) y = 0; 
            else if(y>1) y = 1;

            float colorMult = 2;
            float velocityMult = 30.0f;

            int index = fluidSolver.getIndexForNormalizedPosition(x, y);

            int drawColor;

            colorMode(HSB, 360, 1, 1);
            // float hue = ((x + y) * 180 + frameCount) % 360;
            float hue = (int) p.map(mouseX, 0, width, 0, 360);
            float saturation = .5f;
            float brightness = .1f;
            drawColor = color(hue, saturation, brightness);
            colorMode(RGB, 1);  
            
            Colors.FLUID_H = hue;
            Colors.FLUID_S = saturation;
            Colors.FLUID_B = brightness;

            fluidSolver.rOld[index]  += red(drawColor) * colorMult;
            fluidSolver.gOld[index]  += green(drawColor);
            fluidSolver.bOld[index]  += blue(drawColor);

            fluidSolver.uOld[index] += dx * velocityMult;
            fluidSolver.vOld[index] += dy * velocityMult;
            
            // colorMode(RGB, 255);  
        }
    }

    public void addNebula() {
        for (int x = 0; x < width; x += 100) {
            for (int y = 0; y < height; y += 100) {
    	        addForce(x * invWidth, y * invHeight, p.random(-10, 10), 
    		    p.random(-10, 10));
            }
        }
    }
}
 
class ForceField extends Particle
{
    float radius;
    float strength;
    float ramp;
    boolean visible;
    ArrayList<Particle> particles;
    
    ForceField () 
    {
        super();
    }
    
    ForceField (PVector pos) 
    {
        this(pos, new PVector(0, 0, 0), 0, 0, 2);
    }
    ForceField (PVector pos, PVector vel, float radius) 
    {
        this(pos, vel, radius, 0, 2);
    }
    ForceField (PVector pos, PVector vel, float radius, float strength) 
    {
        this(pos, vel, radius, strength, 2);
        this.radius = radius;
        this.strength = strength;
    }
    ForceField (PVector pos, PVector vel, float radius, float strength, float ramp) 
    {
        this.init(pos, vel);
        this.radius = radius;
        this.strength = strength;
        this.ramp = ramp;
        this.particles = new ArrayList<Particle>();
    }
    public void influence (Particle p) 
    {
        particles.add(p);
    }
    public void influence (ArrayList<Particle> p) 
    {
        particles = p;
    }
    public void remove (Particle p) 
    {
        particles.remove(p);
    }
    public void apply () {
        Particle p;
        PVector delta;
        for (int i = 0; i < particles.size(); i++) {
            p = particles.get(i);
            delta = new PVector(this.position.x, this.position.y, this.position.z);
            delta.sub(p.position);
            float d = delta.mag();
            if (d > 0 && d < radius) {
                // calculate force
                float s = pow(d / radius, 1 / ramp);
                float f = s * strength * (1 / (s + 1) + ((s - 3) / 4)) / d;
                delta.mult(f);
                p.velocity.add(delta);
            }
        }
    }
    public void draw () 
    {
        noFill();
        stroke(255, 50);
        // sphereDetail(10);
        pushMatrix();
            translate(position.x, position.y, position.z);
            sphere(radius);
            // ellipse(0, 0, radius, radius);
        popMatrix();
    }
    public void draw (GLGraphicsOffScreen canvas) 
    {
        canvas.noFill();
        canvas.stroke(255, 50);
        // sphereDetail(10);
        canvas.pushMatrix();
            canvas.translate(position.x, position.y, position.z);
            canvas.sphere(radius);
            // ellipse(0, 0, radius, radius);
        canvas.popMatrix();
    }
    public ForceField setRadius (float r) 
    {   
        this.radius = r;
        return this;
    }
    public ForceField setStrength (float s) 
    {   
        this.strength = s;
        return this;
    }
    public ForceField setRamp (float r) 
    {   
        this.ramp = r;
        return this;
    }
    public ForceField show () {
        this.visible = true;
        return this;
    } 
    public ForceField hide () {
        this.visible = false;
        return this;
    }
    public void die () 
    {
        println("Force can\u2019t die!");
    }
    
}
class Friction extends Behavior 
{
    float friction;
    
    Friction (float friction)
    {
        super();
        this.friction = friction;
    }
    public void apply (Particle p) {
        if (friction > 1) friction = 1;
        p.velocity.mult(1-friction);
    }
}
class OutOfBounds extends Behavior 
{
    float bz;
    
    OutOfBounds (float bz)
    {
        super();
        this.bz = bz;
    }
    public void apply (Particle p) {
        // remove particle if they are out of screen bounds
        if (p.x < 0 + p.size || p.x > width - p.size || p.y < 0 + p.size || p.y > height - p.size) {
            p.die();
        }
    }
}
public class PFrame extends Frame 
{
    public PFrame(PApplet p) 
    {
        setBounds(100, 100, 200, 600);
        controlWindow = new ControlWindow(p);
        add(controlWindow);
        controlWindow.init();
        show();
    }
}
class Particle
{
    ArrayList<Behavior> behaviors;
    ArrayList<ForceField> forces;
    boolean alive;
    boolean useForces;
    boolean useTarget;
    float age;
    float alpha;
    float mass;
    float progress;
    float size;
    float span;
    float vx, vy, vz;
    float x, y, z;
    PVector target;
    PVector position;
    PVector velocity;

    
    public Particle () 
    {
        this.forces = new ArrayList<ForceField>();
    }
    
    public Particle (PVector pos, PVector vel) {
        this.init(pos, vel);
    }
    
    public void init(float x, float y, float z, float vx, float vy, float vz) 
    {
        this.position = new PVector(x, y, z);
        this.updatePosition();
        this.velocity = new PVector(vx, vy, vz);
        this.updateVelocity();
        this.size = 5;
        this.mass = random(0.1f, 1);
        this.alive = true;
        this.age = 0;
        this.span = 1 + (int) random(100);
        this.behaviors = new ArrayList<Behavior>();
        this.progress = 0;
        this.useForces = true;
        this.useTarget = false;
        this.target = new PVector();
    }
    public void init (PVector pos, PVector vel) 
    {
        this.init(pos.x, pos.y, pos.z, vel.x, vel.y, vel.z);
    }
    public void update () 
    {
        age++;
        progress = age / span;
        if (age > span && span != -1) die();
        
        if (useTarget) {
            PVector dir = PVector.sub(target, position);
            dir.mult(0.1f);
            velocity.set(dir);
        }
        // update position
        position.add(velocity);
        
        // apply behaviors
        for (int i = 0; i < behaviors.size(); i++) behaviors.get(i).apply(this);
        
        // update x, y, z to fit vectors
        updatePosition();
        updateVelocity();
        
        if (useForces) {
            for (int i = 0; i < forces.size(); i++) {
                ForceField f = forces.get(i);
                f.setPosition(this.position);
                f.apply();
            }   
        }
    }
    public void die () 
    {
        alive = false;
        forces.clear();
    }
    public Particle randomizeVelocity (float range) {
        return setVelocity(random(-range, range), random(-range, range), random(-range, range));
    }
    public void addVelocity (float vx, float vy, float vz) {
        this.addVelocity(new PVector(vx, vy, vz));
    }
    public void addVelocity (PVector v) {
        velocity.add(v);
        updateVelocity();
    }
    public void tweenTo (PVector target) {
        this.target = target;
        this.useTarget = true;
    }
    public void updatePosition () {
        x = position.x;
        y = position.y;
        z = position.z;
    }
    public void updateVelocity () {
        vx = velocity.x;
        vy = velocity.y;
        vz = velocity.z;
    }
    public void setPosition (float x, float y, float z) 
    {
        position.set(x, y, z);
        updatePosition();
    }
    public void setPosition (PVector p) 
    {
        position = p;
        updatePosition();
    }
    public Particle setVelocity (float vx, float vy, float vz) 
    {
        velocity.set(vx, vy, vz);
        updateVelocity();
        return this;
    }
    public void setSize (float s) 
    {
        this.size = s;
    }
    public Particle setLifeSpan (float s) 
    {
        this.span = s;
        return this;
    }
    // Behaviors
    public Particle addBehavior (Behavior b) {
        this.behaviors.add(b);
        return this;
    }
    public Particle removeBehavior (Behavior b) {
        this.behaviors.remove(b);
        return this;
    }
    // ForceFields
    public Particle addForceField (ForceField f) {
        this.forces.add(f);
        return this;
    }
    public Particle removeForceField (ForceField f) {
        this.forces.remove(f);
        return this;
    }
    public void enableForces () {
        this.useForces = true;
    }
    public void disableForces () {
        this.useForces = false;
    }

    
    
}



class ParticleSystem 
{
    int maxParticles;
    ArrayList<Particle> particles;
    ArrayList<ForceField> forces;
    float gravity;
    PVector globalVelocity; 
    Method particleDrawEvent;
    PApplet p5;

    ParticleSystem(PApplet p5) 
    {
        this(p5, -1); // -1 = unlimited particles
    }
    ParticleSystem (PApplet p5, int max) 
    {
        this.maxParticles = max;
        this.p5 = p5;
        particles = new ArrayList<Particle>();
        forces = new ArrayList<ForceField>();
        this.globalVelocity = new PVector();
        
        // check if there is a custom draw function
        try {
			this.particleDrawEvent = p5.getClass().getMethod("drawParticle", Particle.class);
		} catch (SecurityException e) {
			System.out.println("security error: ");
			e.printStackTrace();
		} catch (NoSuchMethodException e) {
			System.out.println("Info: Use drawParticle(Particle p) instead of looping through getParticles() on your own.");
		} catch (IllegalArgumentException e) {
			System.out.println("illegal args: ");
			e.printStackTrace();
		}
    }

    public void update () {
        for (int i = 0; i < particles.size(); i++) {
            Particle p = particles.get(i);
            updateParticle(p);
        }
        // apply forces
        for (int i = 0; i < forces.size(); i++) {
            forces.get(i).apply();
        }
    }
    public void updateAndDraw() 
    {
        for (int i = 0; i < particles.size(); i++) {
            Particle p = particles.get(i);
            updateAndDrawParticle(p);
        }
        for (int i = 0; i < forces.size(); i++) {
            ForceField f = forces.get(i);
            if (f.visible) f.draw();
            f.apply();
        }
    }
    public void updateAndDraw(GLGraphicsOffScreen canvas) 
    {
        for (int i = 0; i < particles.size(); i++) {
            Particle p = particles.get(i);
            updateAndDrawParticle(p);
        }
        for (int i = 0; i < forces.size(); i++) {
            ForceField f = forces.get(i);
            if (f.visible) f.draw(canvas);
            f.apply();
        }
    }
    public void drawParticle(Particle p) 
    {   
        // uses the drawParticle method in the main program
        if (this.particleDrawEvent != null) {
            try {
                this.particleDrawEvent.invoke(p5, p);
            } catch (IllegalArgumentException e) {
    			// TODO Auto-generated catch block
    			e.printStackTrace();
    		} catch (IllegalAccessException e) {
    			// TODO Auto-generated catch block
    			e.printStackTrace();
    		} catch (InvocationTargetException e) {
                // TODO Auto-generated catch block
    			e.printStackTrace();
            }
        }
    }
    public void updateParticle (Particle p) {
        // apply global velocities
        if (globalVelocity.mag() != 0) p.addVelocity(globalVelocity);
        // apply gravitation
        p.addVelocity(0, gravity * p.age, 0);
        // update particle
        p.update();
    }
    public void updateAndDrawParticle (Particle p) {
        if (p.alive) {
            updateParticle(p);
            drawParticle(p);
        } else {
            removeParticle(p);
        }
    }
    public void addParticles(float x, float y, float z, int count)
    {
        for(int i = 0; i < count; i++) addParticle(x + random(-15, 15), y + random(-15, 15), z + random(-15, 15));
    }
    public Particle addParticle (float x, float y, float z, float vx, float vy, float vz) 
    {
        Particle particle = new Particle();
        return this.addParticle(particle, x, y, z, vx, vy, vz);
    }
    public Particle addParticle (Particle p, float x, float y, float z) 
    {
        return this.addParticle(p, x, y, z, 0, 0, 0);
    }
    public Particle addParticle (float x, float y, float z) 
    {
        return this.addParticle(x, y, z, 0, 0, 0);
    }
    public Particle addParticle () 
    {
        return this.addParticle(random(width), random(height), 0);
    }
    public Particle addParticle (Particle particle, float x, float y, float z, float vx, float vy, float vz) 
    {
        particle.init(x, y, z, vx, vy, vz);
        if (maxParticles == -1 || particles.size() < maxParticles) {
            particles.add(particle);
            for (int i = 0; i < forces.size(); i++) {
                forces.get(i).influence(particle);
            }
            return particle;
        } else {
            // todo: kill old particle or wait?
            particles.add(particle);
            for (int i = 0; i < forces.size(); i++) {
                forces.get(i).influence(particle);
            }
            return particle;
        }
    }
    public void removeParticle (Particle p) 
    {
        particles.remove(p);
        for (int i = 0; i < forces.size(); i++) {
            ForceField f = forces.get(i);
            if (f.particles.contains(p)) {
                f.particles.remove(f.particles.indexOf(p));
            }
        }   
    }
    public void removeParticle (int index) 
    {
        Particle p = particles.get(index);
        for (int i = 0; i < forces.size(); i++) {
            ForceField f = forces.get(i);
            if (f.particles.contains(p)) {
                f.particles.remove(f.particles.indexOf(p));
            }
        }   
        particles.remove(index);
    }
    
    // Forces
    public ForceField addForceField (PVector pos, PVector vel, float radius) 
    {
        ForceField f = new ForceField (pos, vel, radius);
        return this.addForceField(f);
    }
    public ForceField addForceField(PVector pos) 
    {
        ForceField f = new ForceField (pos);
        return this.addForceField(f);
    }
    public ForceField addForceField (ForceField f) 
    {
        this.forces.add(f);
        for (int i = 0; i < particles.size(); i++) {
            f.influence(particles.get(i));
        }
        return f;
    }
    public void clearForces (Particle p) {
        for (int i = 0; i < forces.size(); i++) {
            forces.get(i).remove(p);
        }
    }
    
    // Global Velocity
    public void addGlobalVelocity (PVector vel) 
    {
        globalVelocity.add(vel);
    }
    public void addGlobalVelocity (float vx, float vy, float vz) 
    {
        this.addGlobalVelocity(new PVector(vx, vy, vz));
    }
    public void setGlobalVelocity (PVector vel) 
    {
        globalVelocity.set(vel);
    }
    public void setGlobalVelocity (float vx, float vy, float vz) 
    {
        this.setGlobalVelocity(new PVector(vx, vy, vz));
    }
    public void resetGlobalVelocity () 
    {
        globalVelocity.set(0, 0, 0);
    }
    
    // gravity
    public void enableGravity (float g) 
    {
        this.gravity = g;
    }
    public void disableGravity () 
    {   
        this.gravity = 0;
    }
    
    // access to particles
    public ArrayList<Particle> getParticles() 
    {
        return particles;
    }
    public ArrayList<Particle> setSize(float s) 
    {
        for (int i = 0; i < particles.size(); i++) {
            particles.get(i).setSize(s);
        }
        return particles;
    }
    public int getParticleCount ()
    {
        return particles.size();
    }
    public int getMaxParticles () 
    {
        return maxParticles;
    }
}
public class Slider 
{
    PApplet p;
    int swidth, sheight;
    int xpos, ypos;
    float spos, newspos;
    int sposMin, sposMax;
    int loose;
    boolean over;
    boolean locked;
    float ratio;
    public boolean moved;
    float sLength, vLength, vMin, vMax;
    String id;
    Method sliderEvent;

    public Slider(PApplet _PApplet, String id, int xp, int yp, int sw, int sh, float mn, float mx, int l) {

	    this.p = _PApplet;
        this.id = id;
	    this.swidth = sw;
	    this.sheight = sh;
	    int widthtoheight = sw - sh;
	    this.ratio = (float) sw / (float) widthtoheight;
	    this.xpos = xp;
	    this.ypos = yp - sheight / 2;
	    this.spos = xpos + swidth / 2 - sheight / 2;
	    this.newspos = spos;
	    this.sposMin = xpos;
	    this.sposMax = xpos + swidth - sheight;
	    this.loose = l;
	    this.vMin = mn;
	    this.vMax = mx;
	    this.vLength = vMax - vMin;
	    this.sLength = swidth - sheight;
	    
        try {
	    	this.sliderEvent = p.getClass().getMethod("sliderEvent", Slider.class);
	    } catch (SecurityException e) {
	    	System.out.println("security error: ");
	    	e.printStackTrace();
	    } catch (NoSuchMethodException e) {
	    	System.out.println("Info: Use sliderEvent(Slider) to automatically get updates from the slider.");
	    } catch (IllegalArgumentException e) {
	    	System.out.println("illegal args: ");
	    	e.printStackTrace();
	    }
	    p.registerDraw(this);
    }

    public void update() 
    {
	    if (over()) {
	        over = true;
	    } 
	    else {
	        over = false;
	    }
	    if (p.mousePressed && over) {
	        locked = true;
	    }
	    if (!p.mousePressed) {
	        locked = false;
	    }
	    if (locked) {
	        newspos = constrain(p.mouseX - sheight / 2, sposMin, sposMax);
	    }
	    if (p.abs(newspos - spos) > 1) {
	        spos = spos + (newspos - spos) / loose;
	        moved = true;
	    } 
	    else {
	        moved = false;
	    }
    }
    public void draw() {
        update();
        noStroke();
	    p.fill(255, 50);
	    p.rect(xpos, ypos, swidth, sheight);
	    
	    if (over || locked) {
	        p.fill(240, 200, 0);
	    } 
	    else {
	        p.fill(255, 0, 0);
	    }
	    p.rect(spos, ypos, sheight, sheight);
	    p.fill(255);
	    p.text(id, xpos, ypos + sheight + textAscent() + 5);
	    
	    if (moved) fireEvent();
    }
    public void fireEvent () 
    {
        // uses the drawParticle method in the main program
        if (this.sliderEvent != null) {
            try {
                this.sliderEvent.invoke(p, this);
            } catch (IllegalArgumentException e) {
    			// TODO Auto-generated catch block
    			e.printStackTrace();
    		} catch (IllegalAccessException e) {
    			// TODO Auto-generated catch block
    			e.printStackTrace();
    		} catch (InvocationTargetException e) {
                // TODO Auto-generated catch block
    			e.printStackTrace();
            }
        }    
    }
    public int constrain (int val, int minv, int maxv) 
    {
	    return p.min(p.max(val, minv), maxv);
    }
    public boolean over() 
    {
	    if (p.mouseX > xpos && p.mouseX < xpos + swidth && p.mouseY > ypos && p.mouseY < ypos + sheight) {
	        return true;
	    } 
	    else {
	        return false;
	    }
    }
    public float getValue() {
	return p.max(p.min((vMin + ((spos - xpos) * vLength) / sLength), vMax),
		vMin);
    }
}
public class Timeline {
    
    float[] values;
    float w = 5;
    float d = 10;
    float h = 5;
    float ax, ay, az, bx, by, bz, cx, cy, cz, dx, dy, dz;
    int bla = 0;

    public Timeline () {
        init();
    }
    public void init () {
        values = new float[100];
        float value = 0;

        for (int i = 0; i < values.length; i++) {
            value = noise(value) * 100;
            values[i] = value;
        }
    }
    public void draw (GLGraphicsOffScreen canvas) {
        if (bla < values.length - 1 && frameCount % 10 == 0) bla++;
        canvas.noStroke();
        canvas.fill(255);
        canvas.pushMatrix();
            canvas.beginShape(QUADS);
            for (int i = 0; i < bla; i++) {
                // A
                ax = 0;
                ay = values[i];
                az = d * i;
                // B
                bx = w;
                by = values[i];
                bz = d * i;
                // C
                cx = w;
                cy = values[i+1];
                cz = d * (i + 1);
                // D
                dx = 0;
                dy = values[i+1];
                dz = d * (i + 1);

                // Top
                canvas.vertex(ax, ay, az);
                canvas.vertex(bx, by, bz);
                canvas.vertex(cx, cy, cz);
                canvas.vertex(dx, dy, dz);            
                // Bottom
                canvas.vertex(ax, ay - h, az);
                canvas.vertex(bx, by - h, bz);
                canvas.vertex(cx, cy - h, cz);
                canvas.vertex(dx, dy - h, dz);
                // Left
                canvas.vertex(ax, ay, az);
                canvas.vertex(ax, ay - h, az);
                canvas.vertex(dx, dy - h, dz);
                canvas.vertex(dx, dy, dz);          
                // Right
                canvas.vertex(bx, by, bz);
                canvas.vertex(bx, by - h, bz);
                canvas.vertex(cx, cy - h, cz);
                canvas.vertex(cx, cy, cz);  
                // Front
                canvas.vertex(dx, dy, dz);
                canvas.vertex(cx, cy, cz);
                canvas.vertex(cx, cy - h, cz);
                canvas.vertex(dx, dy - h, dz);
                // Back, we will never see?
            }
            canvas.endShape();
        canvas.popMatrix();
    }   
}
public class Word extends Particle 
{
    String word;
    CharParticle[] characters;
    
    public Word (String word, CharParticle[] characters, PVector pos, PVector vel) {
        super(pos, vel);
        this.word = word;
        this.characters = characters;
        this.position = pos;
        this.velocity = vel;
    }
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "ParticleTest" });
  }
}
