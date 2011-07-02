import processing.opengl.*;
import codeanticode.glgraphics.*;
import processing.opengl.*;
import javax.media.opengl.*;

import saito.objloader.*;

OBJModel model;
GLModel glmodel;

float[][] originalCoords;

boolean displace = true;
  
PVector axis, pos, vel;

void setup() {
  size(800, 800, GLConstants.GLGRAPHICS);

  model = new OBJModel(this, "Model.obj", "relative", TRIANGLES);
  model.enableDebug();
  
  glmodel = new GLModel(this, model.getFaceCount() * 3, POINTS, GLModel.DYNAMIC);
  originalCoords = new float[model.getFaceCount() * 3][3];
  
  glmodel.beginUpdateVertices();   
  int i = 0;
    for (int f = 0; f < model.getFaceCount(); f++) {
      PVector[] fverts = model.getFaceVertices(f);
      for (int v = 0; v < fverts.length; v++) {
        originalCoords[i] = new float[]{fverts[v].x, fverts[v].y, fverts[v].z};
        glmodel.updateVertex(i++, fverts[v].x, fverts[v].y, fverts[v].z);
      }
    }
  glmodel.endUpdateVertices();
  
  
  println("index: " + i);
  println("vertex count " + model.getVertexCount());
  println("face count " + model.getFaceCount());
  
  glmodel.initColors();
  glmodel.setColors(255);
  
  noStroke();

 
}

void draw() {    

  // OpenGL Motion Blur
  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;
  GL gl = pgl.beginGL();
  gl.glEnable( GL.GL_BLEND );
  
  fadeToColor(gl, 0, 0, 0, 0.05);
  
  gl.glBlendFunc(GL.GL_ONE, GL.GL_ONE);
  gl.glDisable(GL.GL_BLEND);
  pgl.endGL();

  
  ambient(250, 250, 250);
  pointLight(255, 255, 255, 500, height/2, 400);
  
  model.draw();
  
  translate(width / 2, height / 2, 0);
  
  
  if (displace) {
      glmodel.beginUpdateVertices();
      for (int i = 0; i < glmodel.getSize(); i++) glmodel.updateVertex(i, originalCoords[i][0] + random(-mouseX, mouseX), originalCoords[i][1] + random(-mouseY, mouseY), originalCoords[i][2]
     );
      glmodel.endUpdateVertices();
  }
  
  GLGraphics renderer = (GLGraphics)g;
  renderer.beginGL();
    for (int i = 0; i < 1; i++) renderer.model(glmodel);
  
  renderer.endGL();
  
  println(300 * glmodel.getSize());

}

void keyPressed () {
    println(frameRate);
    displace = !displace;
}

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