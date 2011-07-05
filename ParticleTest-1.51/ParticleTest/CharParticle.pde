class CharParticle extends Particle
{
    boolean fxSpin = false;
    boolean flat = false;
    boolean used = false;
    char character;
    float extrusion = 3;
    float spin = random(0.2);
    float spinAccel;
    float spinAccelStart;
    float maxSpin = 1;
    float width;
    GLModel vertices;
    float rx, ry;
    PApplet p;
    RMesh m1;
    RPoint[][] pnts;
    RShape shp;


    CharParticle (PApplet p, char c) {
      super();
      this.character = c;
      this.p = p;
      setup();
    }     

    void setup() 
    { 
        shp = font.toShape(this.character);
        RCommand.setSegmentator(RCommand.UNIFORMSTEP);
        RCommand.setSegmentStep(1);
        RCommand.setSegmentAngle(HALF_PI);
        pnts = shp.getPointsInPaths();
        m1 = shp.toMesh();
        
        int verticeCount = 0;
        // for (int i = 0; i < m1.countStrips(); i++){
        //   for(int j=0;j<m1.strips[i].vertices.length;j++){
        //     verticeCount++;
        //   }
        // }
        
        for (int i = 0; i < m1.countStrips(); i++) {
            RPoint[] pts = m1.strips[i].getPoints();
            for(int j=0;j<pts.length;j++){
                    verticeCount++;
            }
        }
        
        // for (int i = 0; i < pnts.length; i++) {
        //      for (int ii = 0; ii < pnts[i].length; ii++)
        //      {
        //          verticeCount++;
        //      }
        // }
        
        // vertices = new GLModel(p, verticeCount, TRIANGLE_STRIP, GLModel.DYNAMIC);
        // generateModel();
        calcWidth();
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
            
            if (fxSpin && spin < 3) {
                spin *= spinAccel;
            } else if (!fxSpin && spin != 0){
                spin /= spinAccel;
            }
            
            ry += spin;
            rotateY(spin);
            
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
                println("decrease speed");
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
    void generateModel () {
        
        int v = 0;
        vertices.beginUpdateVertices();
        for (int i = 0; i < m1.countStrips(); i++) {
            RPoint[] pts = m1.strips[i].getPoints();
            for(int j=0;j<pts.length;j++){
                    vertices.updateVertex(v++, pts[j].x, pts[j].y, 0);
            }
        }
        // for (int i = 0; i < pnts.length; i++) {
        //      for (int ii = 0; ii < pnts[i].length; ii++)
        //      {
        //          vertices.updateVertex(v++, pnts[i][ii].x, pnts[i][ii].y, 0);
        //          vertices.updateVertex(v++, pnts[i][ii].x, pnts[i][ii].y, 3);
        //      }
        // }
        vertices.endUpdateVertices(); 
        vertices.initColors();
        vertices.setColors(255);
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

