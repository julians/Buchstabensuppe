import processing.opengl.*;
import geomerative.*;
import com.getflourish.stt.*;
import traer.physics.*;
import codeanticode.glgraphics.*;

import java.util.Map;

ParticleSystem emitter;
int numParticles = 300;

ArrayList particles;
String chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
int ts = 24;
RFont font;
STT stt;
String result;

boolean dome = false;

boolean dd = true;

ThreadedNGramGetter nGramGetter;

void setup ()
{
    if (dome) {
       size(1920, 1920, GLConstants.GLGRAPHICS);   
    } else {
       size(800, 800, GLConstants.GLGRAPHICS);
    }

    RG.init(this);
    font = new RFont("lucon.ttf", 32, RFont.CENTER);
    
    fill(255);
    noStroke();
    
    initParticles();
    
    stt = new STT(this, true);
    // stt.enableDebug();
    stt.setLanguage("de");
    stt.setThreshold(8.0);
    
    nGramGetter = new ThreadedNGramGetter(this);
    nGramGetter.getNGram("waschmittelwerbung");
}

void nGramFound (NGram ngram)
{
    println("huhu, ngram!");
    println(ngram.values);
    println(ngram.word);
    println(ngram.getValueForYear(2008));
}

void draw ()
{
      
    // GLGraphics renderer = (GLGraphics)g;
    // renderer.beginGL();
    
    background(0);
    lights();
    displayParticles();
    // println(frameRate);
    
    // renderer.endGL();
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
            a = emitter.makeParticle(1, random(width), random(height), random(-1000, 1000));
        } else {
            a = emitter.makeParticle(1, random(width), random(height), 0);
        }
        particles.add(new CharParticle(chars.charAt((int)random(chars.length()))));
        a.velocity().set(random(-0.5, 0.3), random(-0.5, 0.3), random(-0.3, 0.3));
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
        cp.draw();
        popMatrix();
        // cp.update();
    }
}

void formWord(String s) {
    for (int b = 0; b < emitter.numberOfSprings(); b++) {
        emitter.removeSpring(b);
    }
    char [] a = s.toCharArray();
    Particle prev = null;
    for (int i = 0; i < a.length; i++) {
        int index = getIndexForChar(a[i]);
        Particle p = emitter.getParticle(index);
        p.velocity().add(0, 0, 0.0001);
        if (prev != null) {
            emitter.makeSpring(p, prev, 0.2, 0.1, 20);
        }
        prev = p;
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
    CharParticle p = new CharParticle(c);
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
void transcribe (String utterance, float confidence) 
{
  println(utterance);
  result = utterance;
  formWord(utterance);
}