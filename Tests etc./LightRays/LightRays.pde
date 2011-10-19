import processing.opengl.*;
import codeanticode.glgraphics.*;
import controlP5.*;
import saito.objloader.*;

OBJModel model;
GLModel glmodel;

GLSLShader vertexShader;
GLGraphicsOffScreen tex;
float exposure, decay, density, weight;
PVector light;
ControlP5 controlP5;
Slider2D s;

float y = 0;

void setup() {
    size(800, 600, GLConstants.GLGRAPHICS);

    vertexShader = new GLSLShader(this, "ls.vert", "ls.frag");
    tex = new GLGraphicsOffScreen(this, width / 4, height / 4);
    noStroke();
    textFont(createFont("Courier", 100));
    frameRate(60);
    
    controlP5 = new ControlP5(this);
    controlP5.addSlider("exposure", 0, 1, 1, 10, 40, 100, 20).setId(1);
    controlP5.addSlider("decay", 0, 1, 1, 10, 65, 100, 20).setId(2);
    controlP5.addSlider("density", 0, 1, 1, 10, 90, 100, 20).setId(3);
    controlP5.addSlider("weight", 0, 1, 0.5, 10, 115, 100, 20).setId(4);
    // controlP5.addSlider2D("light", 0, 2, 1, 10, 130, 100, 20).setId(5);
    s = controlP5.addSlider2D("wave",10,140,100,100);
    s.setMaxX(1.0);
    s.setMaxY(1.0);
    s.setId(5);
    light = new PVector(0, 0);
    
    model = new OBJModel(this, "Model.obj", "relative", QUADS);
    
    glmodel = new GLModel(this, model.getVertexCount(), QUADS, GLModel.STATIC);


    glmodel.beginUpdateVertices();

    for(int i = 0; i < model.getVertexCount(); i++){
      PVector v = model.getVertex(i);
          glmodel.updateVertex(i, v.x, v.y, v.z);
    }

    glmodel.endUpdateVertices();

    glmodel.initColors();
    glmodel.setColors(255, 100);
}

void draw() {
    background(0);

    ambient(250, 250, 250);
    pointLight(255, 255, 255, 500, height/2, 400);

    fill(255);
    GLGraphics renderer = (GLGraphics)g;

    tex.beginDraw();
    tex.fill(255, 0, 0);
    pushMatrix();
        translate(width/2, height/2, 0);
        renderer.model(glmodel);
        textSize(30);
        text("Hallo", 0, 0);
    popMatrix();
    tex.endDraw();
    
    renderer.model(glmodel);


    vertexShader.start();
        vertexShader.setFloatUniform("exposure", exposure);
        vertexShader.setFloatUniform("decay", decay);
        vertexShader.setFloatUniform("density", density);
        vertexShader.setFloatUniform("weight", weight);
        vertexShader.setVecUniform("lightPositionOnScreen", light.x, light.y);
        image(tex.getTexture(), 0, 0, width, height);
    vertexShader.stop();
    fill(255);
    text(frameRate, 10, 10);
    
}

void controlEvent(ControlEvent theEvent) 
{
    float v = 0;
    if (theEvent.controller().id() != 5) v = theEvent.controller().value();

    switch(theEvent.controller().id()) {
        case(1):
            exposure = v;
            break;
        case(2):
            decay = v;
            break;
        case(3):
            density = v;
            break;  
        case(4):
            weight = v;
            break;
        case(5):
            light.x = s.arrayValue()[0];
            light.y = s.arrayValue()[1];
            break;
    }
}