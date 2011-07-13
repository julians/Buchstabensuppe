import saito.objloader.*;

class CharParticle extends Particle
{
    boolean displace = false;
    boolean flat = false;
    boolean fxSpin = false;
    public boolean used = false;
    boolean use3DModel = true;
    char character;
    float extrusion = 3;
    float maxSpin = 0.2;
    float rx, ry = 0;
    float spin = random(0.025);
    float spinAccel;
    float spinAccelStart;
    float w;
    int mode = 0;
    GLModel vertices;
    PApplet p;
    RMesh m1;
    RPoint[][] pnts;
    RShape shp;
    float scale = 0.25;
    
    Ani slowSpin;
    
    OBJModel model;
    GLModel glmodel;
    
    float[][] originalCoords;
    
    final static int GEOMERATIVE = 0;
    final static int HYBRID = 1;    
    final static int OBJMODEL = 2;

    CharParticle (PApplet p, char c, int mode) {
      super(new PVector(0, 0, 0));
      this.character = c;
      this.p = p;
      this.mode = mode;
      setup();
    }     
    CharParticle (PApplet p, char c, GLModel model) {
      super(new PVector(0, 0, 0));
      this.character = c;
      this.p = p;
      this.mode = 2;
      this.glmodel = model; 
      this.setup();
    }

    void setup() 
    { 
        shp = font.toShape(this.character);
        RCommand.setSegmentator(RCommand.UNIFORMSTEP);
        // RCommand.setSegmentStep(1);
        // RCommand.setSegmentAngle(HALF_PI);
        pnts = shp.getPointsInPaths();
        m1 = shp.toMesh();
        calcWidth();
        
        switch (mode) {
            case GEOMERATIVE:
                break;
            case HYBRID:
                int verticeCount = 0;
                float maxX = 0; 
                for (int i = 0; i < m1.countStrips(); i++) {
                    RPoint[] pts = m1.strips[i].getPoints();
                    for(int j=0;j<pts.length;j++){
                            if (pts[j].x > maxX) maxX = pts[j].x;
                            verticeCount++;
                    }
                }
                glmodel = new GLModel(p, verticeCount, TRIANGLE_STRIP, GLModel.DYNAMIC);
                geomerativeToGLModel();
                break;   
            case OBJMODEL:
                this.w = this.glmodel.width * this.scale;
                slowSpin = new Ani(this, random(5, 10), "ry", ry + 0.5);
                slowSpin.setPlayMode(Ani.YOYO);
                slowSpin.repeat();
                slowSpin.setEasing(Ani.CUBIC_IN_OUT);
                slowSpin.start();
                break;
            
        }
        spinAccel = random(0.005);
        spinAccelStart = spinAccel;
        
    }

    void draw() 
    {
        pushMatrix();   
        
        switch (mode) {
            case GEOMERATIVE:
                if (ry > 0) rotateY(ry); else ry = 0;
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
                break;
            case HYBRID: 
                GLGraphics renderer = (GLGraphics)g;
                renderer.beginGL();
                renderer.model(glmodel);
                renderer.endGL();
                break;
            case OBJMODEL:    
                if (displace) {
                    glmodel.beginUpdateVertices();
                    for (int i = 0; i < glmodel.getSize(); i++) glmodel.updateVertex(i, originalCoords[i][0] + random(-mouseX, mouseX), originalCoords[i][1] + random(-mouseY, mouseY), originalCoords[i][2]);
                    glmodel.endUpdateVertices();
                }
                renderer = (GLGraphics)g;
                renderer.beginGL();
                renderer.translate(x, y, z);
                if (!used) {
                    float angle = atan2(y - height / 2, x - width / 2);
                    renderer.rotate(angle);
                    renderer.rotate(-HALF_PI);
                    float a = radians(map(dist(x, y, width / 2, height / 2), 0, width, 90, 0));
                    // Geiler Strudel-Effekt
                    // rotateZ(a);
                    renderer.rotateX(a);
                }
                renderer.translate(w / 2, 0, 0);
                renderer.fill(0);
                renderer.rotateY(ry);             
                renderer.scale(scale);
                renderer.translate(-w / 2, 0, 0);
                renderer.model(glmodel);
                renderer.endGL();
                break;
        }
        popMatrix();
    }
    void geomerativeToGLModel () {
        
        int v = 0;
        glmodel.beginUpdateVertices();
        for (int i = 0; i < m1.countStrips(); i++) {
            RPoint[] pts = m1.strips[i].getPoints();
            for(int j=0;j<pts.length;j++){
                    glmodel.updateVertex(v++, -w / 2 + pts[j].x, pts[j].y, 0);
            }
        }
        // for (int i = 0; i < pnts.length; i++) {
        //      for (int ii = 0; ii < pnts[i].length; ii++)
        //      {
        //          vertices.updateVertex(v++, pnts[i][ii].x, pnts[i][ii].y, 0);
        //          vertices.updateVertex(v++, pnts[i][ii].x, pnts[i][ii].y, 3);
        //      }
        // }
        glmodel.endUpdateVertices(); 
        glmodel.initColors();
        glmodel.setColors(255);
    }
    private void calcWidth () {
        for (int i = 0; i < pnts.length; i++) {
             for (int ii = 0; ii < pnts[i].length; ii++)
             {
                 if (pnts[i][ii].x > this.w) this.w = pnts[i][ii].x;
             }        
        }
    }
    public float getWidth () {
        return this.w;
    }      
    void resetRotation() 
    {
        canvas.rotateX(-rx);
        canvas.rotateY(-ry);
    }
    void setUsed() {
        this.used = true;
    }
}

