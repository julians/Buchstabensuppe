import processing.opengl.*;
import javax.media.opengl.*;
import geomerative.*;

Emitter emitter;
RFont font;

void setup()
{
    size(600, 600, OPENGL);
    hint(ENABLE_OPENGL_4X_SMOOTH);
    
    RG.init(this);
    font = new RFont("lucon.ttf", 32, RFont.CENTER);
    
    emitter = new Emitter(this);
    emitter.enableGravity(0.01);
    emitter.addGlobalVelocity(0, 0, 10);
    emitter.addParticle(new CharParticle('c'), mouseX, mouseY, 0).randomizeVelocity(1);
}

void draw()
{
    PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;
    GL gl = pgl.beginGL();
    gl.glEnable( GL.GL_BLEND );

    // Motion Blur!
    // fadeToColor(gl, 0, 0, 0, 0.05);
    background(0);
    
    gl.glBlendFunc(GL.GL_ONE, GL.GL_ONE);
    gl.glDisable(GL.GL_BLEND);
    pgl.endGL();
    
    // Ein Partikel an der Mausposition hinzufügen und zufällige Richtung geben
    byte surprise = (byte) random(97, 122);
    emitter.addParticle(new CharParticle(char(surprise)), mouseX, mouseY, 0).randomizeVelocity(1);
    emitter.updateAndDraw();
    
    // Man kann auch selbst auf die Partikel zugreifen
    
    // emitter.update();
    // ArrayList<Particle> particles = emitter.getParticles();
    // for (int i = 0; i < particles.size(); i++) {
    //     drawParticle(particles.get(i));
    // }
}

// Wird automatisch vom Partikelsystem aufgerufen
void drawParticle (Particle p) {
    fill(255 - p.progress * 255);
    noStroke();
    if (p instanceof CharParticle) {
        ((CharParticle) p).draw();      
    } else {
        stroke(255 - p.progress * 255);
        point(p.x, p.y);
    }
}

// OpenGL alternative zu backround(c, c, c, alpha);
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