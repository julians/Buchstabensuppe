class CharParticle 
{
    RShape shp;
    RPoint[][] pnts;
    RMesh m1;
    int w;
    boolean used = false;
    char character;
    float spin = random(-1, 1);
    int rx, ry;
    boolean flat = false;
    int extrusion = 3;
    RStrip[] strips;
    GLModel model;
    PApplet p5;
    
    CharParticle (PApplet p, char c) {
      this.character = c;
      this.p5 = p;
      init();
    }     

    void init() { 
      shp = font.toShape(this.character);
      RCommand.setSegmentator(RCommand.UNIFORMSTEP);
      RCommand.setSegmentStep(0.5);
      RCommand.setSegmentAngle(HALF_PI);
      pnts = shp.getPointsInPaths();
      m1 = shp.toMesh();
      strips = m1.strips;
      
      int count = 0;
      for (int i = 0; i < strips.length; i++) {
          count += strips[i].vertices.length;
      }
      model = new GLModel(p5, count, TRIANGLE_STRIP, GLModel.STATIC);
      updateVertices();
        
    }

    void draw() 
    {   
      if (flat) {
        text(character, 0, 0);
      } else {
        
        pushMatrix();
      spin -= 0.001;

      if (!used) {
          rx += PI/9;
          ry += PI/5 + spin;
  
          rotateY(sin(spin));
          //rotateY(PI/5 + spin);
      }
      
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
      
      // GLGraphics renderer = (GLGraphics)g;
      // renderer.beginGL();
      //   renderer.model(model);    
      // renderer.endGL();
        
      // drawSide();
      // 
      // drawFace();
      // translate(0, 0, extrusion);
      // drawFace();
      
      popMatrix();
      }
  }
      
    void resetRotation() 
    {
        rotateX(-rx);
        rotateY(-ry);
    }
    
    void drawFace () {
        for (int i = 0; i < strips.length; i++) {
             beginShape(QUAD_STRIP);
             for (int ii = 0; ii < strips[i].vertices.length; ii++)
             {
                 float x = strips[i].vertices[ii].x;
                 float y = strips[i].vertices[ii].y;
                 vertex(x, y, 0);
             }
             endShape(CLOSE);
        }
    }
    
    void drawSide () {
        for (int i = 0; i < pnts.length; i++) {
             beginShape(QUAD_STRIP);
             for (int ii = 0; ii < pnts[i].length; ii++)
             {
                 vertex(pnts[i][ii].x, pnts[i][ii].y, 0);
                 vertex(pnts[i][ii].x, pnts[i][ii].y, extrusion);
             }
             endShape(CLOSE);
        }
    }
    
    void updateVertices () {
        int index = 0;
        for (int i = 0; i < strips.length; i++) {
            model.beginUpdateVertices();
            for (int ii = 0; ii < strips[i].vertices.length; ii++)
            {
                float x = strips[i].vertices[ii].x;
                float y = strips[i].vertices[ii].y;
                model.updateVertex(index, x, y, 0);
                index++;
            }
            model.endUpdateVertices();
        }
        
        // for (int i = 0; i < strips.length; i++) {
        //      for (int ii = 0; ii < strips[i].vertices.length; ii++)
        //      {
        //          model.updateVertex(index, strips[i].vertices[ii].x, strips[i].vertices[ii].y, 0);
        //          index++;
        //          model.updateVertex(index, strips[i].vertices[ii].x, strips[i].vertices[ii].y, extrusion);
        //          index++;
        //      }
        // }
        
        // for (int i = 0; i < strips.length; i++) {
        //      for (int ii = 0; ii < strips[i].vertices.length; ii++)
        //      {
        //          float x = strips[i].vertices[ii].x;
        //          float y = strips[i].vertices[ii].y;
        //          model.updateVertex(index, x, y, extrusion);
        //          index++;
        //      }
        // }
    }
}

