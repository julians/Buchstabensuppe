class Friction extends Behavior 
{
    float friction;
    
    Friction (float friction)
    {
        super();
        this.friction = friction;
    }
    void apply (Particle p) {
        if (friction > 1) friction = 1;
        p.velocity.mult(1-friction);
    }
}
