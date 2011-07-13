// Kommentar!

import processing.opengl.*;
import de.looksgood.ani.*;
import peasy.*;

Scoreboard scoreboard;
ThreadedNGramGetter nGramGetter;
ArrayList words;
ArrayList words2;
PeasyCam cam;

void setup ()
{
    size(800, 800, OPENGL);
    colorMode(HSB, 360, 100, 100);
    smooth();
    Ani.init(this);
    cam = new PeasyCam(this, 1000);
    
    scoreboard = new Scoreboard(500, 200);
    words = new ArrayList();
    words.add("waschmittelwerbung");
    words.add("zahnarzt");
    words.add("essen");
    words.add("raumstation");
    
    words2 = new ArrayList();
    words2.add("essen");
    words2.add("zahnarzt");
    words2.add("raumstation");
    words2.add("waschmittelwerbung");
    
    nGramGetter = new ThreadedNGramGetter(this);
}

void nGramFound (NGram ngram)
{
    scoreboard.add(ngram); 
}

void draw ()
{
    background(360, 0, 50);
    lights();
    rotateY(-PI/4);
    rotateX(-PI/8);
    rotateZ(PI/12);
    scoreboard.draw();
}

void keyPressed() {
    if (key == ' ') {
        if (words.size() > 0) {
            nGramGetter.getNGram((String) words.remove(0));
        } else if (words2.size() > 0) {
            scoreboard.remove((String) words2.remove(0));
        }
    }
}