import codeanticode.glgraphics.*;
import processing.opengl.*;
import javax.media.opengl.*;

GL gl;
GLSLShader shader;
PGraphicsOpenGL pgl;
float[] values;
float w = 10;
float d = 10;
float h = 10;
float ax, ay, az, bx, by, bz, cx, cy, cz, dx, dy, dz;
int bla = 0;

void setup () {
    size(800, 800, GLConstants.GLGRAPHICS);
    hint(ENABLE_OPENGL_4X_SMOOTH);
    // shader = new GLSLShader(this, ".vert", ".frag");
    
    pgl = (PGraphicsOpenGL) g;
    gl = pgl.gl;
    
    values = new float[100];
    float value = 0;
    
    for (int i = 0; i < values.length; i++) {
        value = noise(value) * 100;
        values[i] = value;
        println(value);
    }
}

void draw () {
    if (bla < values.length - 1 && frameCount % 10 == 0) bla++;
    background(0);
    noStroke();
    fill(255);
    lights();
    pushMatrix();
        translate(mouseX, mouseY, 0);
        beginShape(QUADS);
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
            vertex(ax, ay, az);
            vertex(bx, by, bz);
            vertex(cx, cy, cz);
            vertex(dx, dy, dz);            
            // Bottom
            vertex(ax, ay - h, az);
            vertex(bx, by - h, bz);
            vertex(cx, cy - h, cz);
            vertex(dx, dy - h, dz);
            // Left
            vertex(ax, ay, az);
            vertex(ax, ay - h, az);
            vertex(dx, dy - h, dz);
            vertex(dx, dy, dz);          
            // Right
            vertex(bx, by, bz);
            vertex(bx, by - h, bz);
            vertex(cx, cy - h, cz);
            vertex(cx, cy, cz);  
            // Front
            vertex(dx, dy, dz);
            vertex(cx, cy, cz);
            vertex(cx, cy - h, cz);
            vertex(dx, dy - h, dz);
            // Back, we will never see?
        }
        endShape();
    popMatrix();
}