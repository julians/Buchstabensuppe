class OutOfBounds extends Behavior 
{
    float bz;
    
    OutOfBounds (float bz)
    {
        super();
        this.bz = bz;
    }
    void apply (Particle p) {
        // remove particle if they are out of screen bounds
        if (p.x < 0 + p.size || p.x > width - p.size || p.y < 0 + p.size || p.y > height - p.size) {
            p.die();
        }
    }
}
