import processing.opengl.*;
import javax.media.opengl.*;
import geomerative.*;
import com.getflourish.stt.*;
import traer.physics.*;
import codeanticode.glgraphics.*;

import java.util.Map;

ParticleSystem emitter;
int numParticles = 100;

CharParticle a;
ArrayList particles;
String chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
int ts = 24;

RFont font;
STT stt;
String result;

boolean dome = false;

boolean dd = true;

PGraphicsOpenGL pgl;
GL gl;

ThreadedNGramGetter nGramGetter;

void setup ()
{
    if (dome) {
       size(1920, 1920, GLConstants.GLGRAPHICS);   
    } else {
       size(800, 800, GLConstants.GLGRAPHICS);
    }

    hint( ENABLE_OPENGL_4X_SMOOTH );
    pgl = (PGraphicsOpenGL) g;
    gl = pgl.gl;
    gl.setSwapInterval(1);
  
    RG.init(this);
    font = new RFont("lucon.ttf", 32, RFont.CENTER);
    
    fill(255);
    noStroke();
    
    textFont(createFont("Arial", 24));
    initParticles();
    
    stt = new STT(this, true);
    // stt.enableDebug();
    stt.setLanguage("de");
    stt.setThreshold(8.0);
    
    nGramGetter = new ThreadedNGramGetter(this);
    nGramGetter.getNGram("waschmittelwerbung");
    
    a = new CharParticle(this, 'H');
}

void nGramFound (NGram ngram)
{
    println("huhu, ngram!");
    println(ngram.word);
    println(ngram.getValueForYear(2008));
    println(ngram.getFirstOccurance());
}

void draw ()
{
    background(0);     
  pgl.beginGL();
  
  // This fixes the overlap issue
  gl.glDisable(GL.GL_DEPTH_TEST);
  
  // Turn on the blend mode
  gl.glEnable(GL.GL_BLEND);
  
  // Define the blend mode
  gl.glBlendFunc(GL.GL_SRC_ALPHA,GL.GL_ONE);
  
  // fadeToColor(gl, 0, 0, 0, 0.09);
  pgl.endGL();
  
  ambient(250, 250, 250);
  pointLight(255, 255, 255, 500, height/2, 400);
  
  displayParticles();
    
  translate(width / 2, height / 2, 500);
  a.draw();
}

void initParticles () 
{
    emitter = new ParticleSystem();
    particles = new ArrayList();
    createParticles();
}

void createParticles() {
    for (int i = 0; i < numParticles; i++) {
        Particle a;
        if (dd) {
            a = emitter.makeParticle(1, random(width), random(height), random(100, 200));
        } else {
            a = emitter.makeParticle(1, random(width), random(height), 0);
        }
        particles.add(new CharParticle(this, chars.charAt((int)random(chars.length()))));
        a.velocity().set(random(-0.5, 0.3), random(-0.5, 0.3), random(0, 1));
        for (int j = 0; j < emitter.numberOfParticles() - 1; j++) {
            Particle b = emitter.getParticle(j);
            // emitter.makeAttraction(a, b, -20, 10);
        }
    }
}

void handleBoundaryCollisions(Particle p)
{
  if ( p.position().x() < 0 || p.position().x() > width )
    p.velocity().set( -1 * p.velocity().x(), p.velocity().y(), 0 );
  if ( p.position().y() < 0 || p.position().y() > height )
    p.velocity().set(p.velocity().x(), -1 * p.velocity().y(), 0 );
  p.position().set(constrain( p.position().x(), 0, width ), constrain( p.position().y(), 0, height ), constrain( p.position().z(), -1000, 1000 ) ); 
}

void displayParticles () 
{
    emitter.tick();

    for (int i = 0; i < particles.size(); i++) {
        CharParticle cp = (CharParticle) particles.get(i);
        Particle p = emitter.getParticle(i);
        handleBoundaryCollisions(p);
        float angle = atan2(p.position().y() - height / 2, p.position().x() - width / 2);
        pushMatrix();
        translate(p.position().x(), p.position().y(), p.position().z());
        rotate(angle);
        rotate(-HALF_PI);
        float bla =  10 + map(p.position().z(), -1000, 1000, 0, 255);
        fill(bla, bla, bla);
        if (p.position().z() < 0) {
          // cp.flat = true;
        } else {
          cp.flat = false;
        }
        cp.draw(); 
        popMatrix();
        // cp.update();
    }
}

void formWord(String s) {
    char [] a = s.toCharArray();
    for (int i = 0; i < a.length; i++) {
        int index = getIndexForChar(a[i]);
        Particle p = emitter.getParticle(index);
        // Geiler Effekt, Rakete los!
        // p.velocity().add(0, 0, 10);
        
        p.position().set(i * 100, height / 2, 100);
    }
}

CharParticle getParticleForChar (char c) {
    for (int i = 0; i < particles.size(); i++) {
        CharParticle p = (CharParticle) particles.get(i);
        if (p.character == c && !p.used) {
            p.used = true;
            p.resetRotation();
            return p;
        }
    } 
    CharParticle p = new CharParticle(this, c);
    particles.add(p);
    p.used = true;
    p.resetRotation();
    return p;
}

int getIndexForChar (char c) {
    for (int i = 0; i < particles.size(); i++) {
        CharParticle p = (CharParticle) particles.get(i);
        if (p.character == c && !p.used) {
            p.used = true;
            p.resetRotation();
            return i;
        }
    } 
    // CharParticle p = new CharParticle(c);
    // particles.add(p);
    // p.used = true;
    // p.resetRotation();
    return 0;
}

// Method is called if transcription was successfull 
void transcribe (String utterance, float confidence, int status) 
{
  println(status);
  result = utterance;
  formWord(utterance);
}

void fadeToColor(GL gl, float r, float g, float b, float speed) {
    gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA);
    gl.glColor4f(r, g, b, speed);
    gl.glBegin(GL.GL_QUADS);
    gl.glVertex2f(0, 0);
    gl.glVertex2f(width, 0);
    gl.glVertex2f(width, height);
    gl.glVertex2f(0, height);
    gl.glEnd();
}

void keyPressed () {
    println(frameRate);
}
