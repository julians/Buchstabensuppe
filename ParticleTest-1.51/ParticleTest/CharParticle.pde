class CharParticle extends Particle
{
    RShape shp;
    RPoint[][] pnts;
    RMesh m1;
    float w;
    boolean used = false;
    char character;
    float spin = random(-1, 1);
    int rx, ry;
    boolean flat = false;
    float extrusion = 3;

    CharParticle (char c) {
      super();
      this.character = c;
      setup();
    }     

    void setup() 
    { 
        shp = font.toShape(this.character);
        RCommand.setSegmentator(RCommand.UNIFORMSTEP);
        RCommand.setSegmentStep(0.5);
        RCommand.setSegmentAngle(HALF_PI);
        pnts = shp.getPointsInPaths();
        m1 = shp.toMesh();
    }

    void draw() 
    {
        pushMatrix();   
        
        // flat = (z < 0) ? true : false;

        if (flat) {
          text(character, 0, 0);
        } 
        else { 
            spin -= 0.01;
            
            if (!used) {
                rx += PI/9;
                ry += PI/5 + spin;
            
                rotateY(sin(spin));
                rotateY(PI/5 + spin);
            }
            
            for (int i = 0; i < pnts.length; i++) {
                 beginShape(QUAD_STRIP);
                 for (int ii = 0; ii < pnts[i].length; ii++)
                 {
                     vertex(pnts[i][ii].x, pnts[i][ii].y, 0);
                     vertex(pnts[i][ii].x, pnts[i][ii].y, extrusion);
                     if (pnts[i][ii].x > w) w = pnts[i][ii].x;
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
        canvas.pushMatrix();   
        
        // flat = (z < 0) ? true : false;

        if (flat) {
          canvas.text(character, 0, 0);
        } 
        else { 
            spin -= 0.01;
            
            if (!used) {
                rx += PI/9;
                ry += PI/5 + spin;
            
                canvas.rotateY(sin(spin));
                canvas.rotateY(PI/5 + spin);
            }
            
            for (int i = 0; i < pnts.length; i++) {
                 canvas.beginShape(POINTS);
                 for (int ii = 0; ii < pnts[i].length; ii++)
                 {
                     canvas.vertex(pnts[i][ii].x, pnts[i][ii].y, 0);
                     canvas.vertex(pnts[i][ii].x, pnts[i][ii].y, extrusion);
                     if (pnts[i][ii].x > w) w = pnts[i][ii].x;
                 }
                 canvas.endShape(CLOSE);
            
            }
            drawFace(canvas);
            canvas.translate(0, 0, extrusion);
            drawFace(canvas);
        }
        canvas.popMatrix();
    }
    void drawFace(GLGraphicsOffScreen canvas) {
        for (int i = 0; i < m1.countStrips(); i++){
          canvas.beginShape(PConstants.POINTS);
          for(int j=0;j<m1.strips[i].vertices.length;j++){
            canvas.vertex(m1.strips[i].vertices[j].x,m1.strips[i].vertices[j].y);
          }
          canvas.endShape(PConstants.CLOSE);
        }
        
    }
      
    void resetRotation() 
    {
        rotateX(-rx);
        rotateY(-ry);
    }
}

