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
    float width;
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
      super();
      this.character = c;
      this.p = p;
      this.mode = mode;
      setup();
    }     
    CharParticle (PApplet p, char c, GLModel model) {
      super();
      this.character = c;
      this.p = p;
      this.mode = 2;
      this.glmodel = model; 
      this.setup();
    }

    void setup() 
    { 
        shp = font.toShape(this.character);
        // RCommand.setSegmentator(RCommand.UNIFORMSTEP);
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
            
            // model = new OBJModel(p, ("" + character).toUpperCase() + ".obj", "relative", TRIANGLES);
            // model.enableDebug();
            // 
            // glmodel = new GLModel(p, model.getFaceCount() * 3, TRIANGLES, GLModel.DYNAMIC);
            // originalCoords = new float[model.getFaceCount() * 3][3];
            // 
            // glmodel.beginUpdateVertices();   
            // int i = 0;
            //   for (int f = 0; f < model.getFaceCount(); f++) {
            //     PVector[] fverts = model.getFaceVertices(f);
            //     for (int v = 0; v < fverts.length; v++) {
            //       originalCoords[i] = new float[]{fverts[v].x, fverts[v].y, fverts[v].z};
            //       glmodel.updateVertex(i++, fverts[v].x, fverts[v].y, fverts[v].z);
            //     }
            //   }
            // glmodel.endUpdateVertices();
            // glmodel.initColors();
            // glmodel.setColors(255);
            // break;
            
            this.width = this.glmodel.width * this.scale;
            // this.glmodel.centerVertices();
            
            slowSpin = new Ani(this, random(5, 10), "ry", ry + 0.5);

            // FORWARD, BACKWARD, YOYO
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
        
        // flat = (z < 0) ? true : false;

        if (flat) {
          text(character, 0, 0);
        } 
        else { 
            switch (mode) {
                
                case GEOMERATIVE:
                
                if(ry > 0) rotateY(ry);
                else ry = 0;
                
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
                renderer.translate(width / 2, 0, 0);
                renderer.fill(0);
                renderer.rotateY(ry);             
                renderer.scale(scale);
                renderer.translate(-width / 2, 0, 0);
                renderer.model(glmodel);
                renderer.endGL();
                break;
            }

        }
        popMatrix();
    }
    void draw (GLGraphicsOffScreen canvas) {
        int v;
        canvas.pushMatrix(); 
        // flat = (z < 0) ? true : false;
        
        if (flat) {
            canvas.text(character, 0, 0);
        } 
        else 
        { 
            // stupid
            if (fxSpin && Math.abs(spin) < maxSpin) {
                spin += spinAccel;
            } else if (!fxSpin && spin != 0){
                spin -= spinAccel;
            } else {

            }
            ry += spin;
            if(ry > 0) canvas.rotateY(ry);
            else ry = 0;
            
            for (int i = 0; i < pnts.length; i++) {
                 canvas.beginShape(QUAD_STRIP);
                 for (int ii = 0; ii < pnts[i].length; ii++)
                 {
                     canvas.vertex(pnts[i][ii].x, pnts[i][ii].y, 0);
                     canvas.vertex(pnts[i][ii].x, pnts[i][ii].y, extrusion);
                 }
                 canvas.endShape(CLOSE);
           
            }
           
            drawFace(canvas);
            canvas.translate(0, 0, extrusion);
            drawFace(canvas);
            
            // 
            // canvas.beginGL();
            // canvas.fill(255);
            // canvas.model(vertices);
            // canvas.endGL();   
        }
        canvas.popMatrix();
    }
    void drawFace(GLGraphicsOffScreen canvas) {
        for (int i = 0; i < m1.countStrips(); i++){
          canvas.beginShape(PConstants.TRIANGLE_STRIP);
          for(int j=0;j<m1.strips[i].vertices.length;j++){
            canvas.vertex(m1.strips[i].vertices[j].x,m1.strips[i].vertices[j].y);
          }
          canvas.endShape(PConstants.CLOSE);
        }  
    }
    void draw (GLGraphics renderer) {
        renderer.beginGL();
        renderer.model(glmodel);
        renderer.endGL();
    }
    void geomerativeToGLModel () {
        
        int v = 0;
        glmodel.beginUpdateVertices();
        for (int i = 0; i < m1.countStrips(); i++) {
            RPoint[] pts = m1.strips[i].getPoints();
            for(int j=0;j<pts.length;j++){
                    glmodel.updateVertex(v++, -width / 2 + pts[j].x, pts[j].y, 0);
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
                 if (pnts[i][ii].x > this.width) this.width = pnts[i][ii].x;
             }        
        }
    }
    public float getWidth () {
        return this.width;
    }
    public void startFXSpin() {
        fxSpin = true;
        spinAccel = spinAccelStart;
    }
    public void stopFXSpin () {
        fxSpin = false;
        spinAccel = spinAccelStart;
    }
      
    void resetRotation() 
    {
        canvas.rotateX(-rx);
        canvas.rotateY(-ry);
    }
}

