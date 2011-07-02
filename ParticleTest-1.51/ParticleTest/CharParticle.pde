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
                     vertex(pnts[i][ii].x, pnts[i][ii].y, 3);
                     if (pnts[i][ii].x > w) w = pnts[i][ii].x;
                 }
                 endShape(CLOSE);
            
            }
            m1.draw();
            translate(0, 0, 3);
            m1.draw();
        }
        popMatrix();
    }
      
    void resetRotation() 
    {
        rotateX(-rx);
        rotateY(-ry);
    }
}

