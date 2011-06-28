class ForceField extends Particle
{
    float radius;
    float strength;
    float ramp;
    boolean visible;
    ArrayList<Particle> particles;
    
    ForceField () 
    {
        super();
    }
    
    ForceField (PVector pos) 
    {
        this(pos, new PVector(0, 0, 0), 0, 0, 2);
    }
    ForceField (PVector pos, PVector vel, float radius) 
    {
        this(pos, vel, radius, 0, 2);
    }
    ForceField (PVector pos, PVector vel, float radius, float strength) 
    {
        this(pos, vel, radius, strength, 2);
        this.radius = radius;
        this.strength = strength;
    }
    ForceField (PVector pos, PVector vel, float radius, float strength, float ramp) 
    {
        this.init(pos, vel);
        this.radius = radius;
        this.strength = strength;
        this.ramp = ramp;
    }
    void attract (Particle p) 
    {
        PVector delta = this.position.get();
        delta.sub(p.position.get());
        float d = delta.mag();
        if (d > 0 && d < radius) {
            // calculate force
            float s = pow(d / radius, 1 / ramp);
            float f = s *  strength * (1 / (s + 1) + ((s - 3) / 4)) / d;
            delta.mult(f);
            p.velocity.add(delta);
        }
    }
    void draw () 
    {
        noFill();
        stroke(255, 50);
        sphereDetail(10);
        pushMatrix();
        translate(position.x, position.y, position.z);
        sphere(radius);
        popMatrix();
    }
    ForceField setRadius (float r) 
    {   
        this.radius = r;
        return this;
    }
    ForceField setStrength (float s) 
    {   
        this.strength = s;
        return this;
    }
    ForceField setRamp (float r) 
    {   
        this.ramp = r;
        return this;
    }
    ForceField show () {
        this.visible = true;
        return this;
    } 
    ForceField hide () {
        this.visible = false;
        return this;
    }
    void die () 
    {
        println("Force can’t die!");
    }
    
}