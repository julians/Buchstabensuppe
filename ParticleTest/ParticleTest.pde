import geomerative.*;
import controlP5.*;

ParticleSystem emitter;
RFont font;
// ControlP5 doesn’t work with 1.99
// ControlP5 controlP5;
ForceField force;
ArrayList<Slider> sliders;
PShape3D model;
PFrame controlFrame;
ControlWindow controlWindow;

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
    
    // sliders = new ArrayList<Slider>();
    // sliders.add(new Slider(this, "radius", 10, 10, 100, 10, 0, 1000, 1));
    // sliders.add(new Slider(this, "strength", 10, 40, 100, 10, -50, 50, 1));
    // sliders.add(new Slider(this, "ramp", 10, 70, 100, 10, 0, 2, 1));
    
    model = (PShape3D)loadShape("a.obj");
    model.scaleVertices(0.2);
    model.rotateVerticesX(-PI);

}

void draw()
{
    background(0);
    ambient(250, 250, 250);
    pointLight(255, 255, 255, 500, height/2, 400);
        
    PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;
    GL gl = pgl.beginGL();
    gl.glEnable( GL.GL_BLEND );
   
   // Motion Blur!
   // fadeToColor(gl, 0, 0, 0, 0.05);
   
   gl.glBlendFunc(GL.GL_ONE, GL.GL_ONE);
   gl.glDisable(GL.GL_BLEND);
   pgl.endGL();
    
    // Ein Partikel an der Mausposition hinzufügen und zufällige Richtung geben
    char surprise = char((byte) random(97, 122));
    // emitter.addParticle(new CharParticle(surprise), mouseX, mouseY, 0).randomizeVelocity(1).addBehavior(new BoundsOffWalls(0));
    
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
    
    // Man kann auch selbst auf die Partikel zugreifen
    
    // emitter.update();
    // ArrayList<Particle> particles = emitter.getParticles();
    // for (int i = 0; i < particles.size(); i++) {
    //     drawParticle(particles.get(i));
    // }
    debug();   
    
    // Zweites Fenster zeichnen
    controlWindow.background(0);
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
        size(400, 300);
        noLoop();
        controlP5 = new ControlP5(this);
        //// Slider für das ForceField
        controlP5 = new ControlP5(this);
        controlP5.addSlider("radius", 0, 1000, 100, 10, 40, 100, 20).setId(1);
        controlP5.addSlider("strength", -50, 50, 10, 10, 60, 100, 20).setId(2);
        controlP5.addSlider("ramp", 0, 2, 1, 10, 20, 80, 20).setId(3);
    }

    public void draw() 
    {
        
    }
    
    void controlEvent(ControlEvent theEvent) {
      switch(theEvent.controller().id()) {
        case(1):
        force.setRadius((int)(theEvent.controller().value()));
        break;
        case(2):
        force.setStrength((int)(theEvent.controller().value()));
        break;
        case(3):
        force.setRamp((int)(theEvent.controller().value()));
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