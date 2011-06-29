class ModelParticle extends Particle
{
    PShape3D model;
    float scale;

    ModelParticle (PShape3D model) {
      super();
      this.model = model;
      setup();
    }     
    void setup () {
        this.scale = random(10);
    }
    void draw() 
    {   
        pushMatrix(); 
            // todo: scaling shifts origin
            // scale(scale);
            translate(x, y, z);
            shape(model);
        popMatrix();
    }
}

