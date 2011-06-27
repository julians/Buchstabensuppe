import processing.opengl.*;
import javax.media.opengl.*;

Emitter emitter;

void setup()
{
    size(600, 600, OPENGL);
    hint(ENABLE_OPENGL_4X_SMOOTH);
    emitter = new Emitter();
    emitter.enableGravity(0.01);
    emitter.addParticle(mouseX, mouseY, 0).randomizeVelocity(1);
}

void draw()
{
    PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;
    GL gl = pgl.beginGL();
    gl.glEnable( GL.GL_BLEND );

    // Motion Blur!
    fadeToColor(gl, 0, 0, 0, 0.05);
    
    gl.glBlendFunc(GL.GL_ONE, GL.GL_ONE);
    gl.glDisable(GL.GL_BLEND);
    pgl.endGL();
    
    // Particles
    emitter.addParticle(mouseX, mouseY, 0).randomizeVelocity(1);
    emitter.updateAndDraw();
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