class ModelParticle extends Particle
{
    PShape3D model;
    float scale;
    color col;
    char character;

    ModelParticle (PShape3D model, char character) {
      super();
      this.model = model;
      this.col = 100;
      this.character = character;
      setup();
    }     
    void setup () {
        this.scale = random(3,5);
    }
    void draw() 
    {   
        pushMatrix(); 
            // todo: scaling shifts origin
            model.disableStyle();
            float alpha = map(z, 0, 100, 0, 1);
            colorMode(HSB, 360, 1, 1);
            tint(Colors.FLUID_H, 1, alpha);
            fill(Colors.FLUID_H, 1, alpha);
            scale(scale);
            // translate(x, y, z);
            shape(model);
            colorMode(RGB, 255);
        popMatrix();
    }
}

