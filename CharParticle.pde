class CharParticle 
{
    RShape shp;
    RPoint[][] pnts;
    RMesh m1;
    int w;
    boolean used = false;
    char character;
    float spin = random(0, 1);
    int rx, ry;

    CharParticle (char c) {
      this.character = c;
      init();
    }     

    void init() { 
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
      spin -= 0.025;

      if (!used) {
          rx += PI/9;
          ry += PI/5 + spin;
  
          rotateX(PI/9);
          rotateY(PI/5 + spin);
      }

      for (int i = 0; i < pnts.length; i++) {
           beginShape(QUAD_STRIP);
           for (int ii = 0; ii < pnts[i].length; ii++)
           {
               vertex(pnts[i][ii].x, pnts[i][ii].y, 0);
               vertex(pnts[i][ii].x, pnts[i][ii].y, 5);
           }
           endShape(CLOSE);

      }
      m1.draw();
      translate(0, 0, 5);
      m1.draw();
      popMatrix();
  }
      
    void resetRotation() 
    {
        rotateX(-rx);
        rotateY(-ry);
    }
}

