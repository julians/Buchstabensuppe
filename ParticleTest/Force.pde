class Force extends Particle
{
    float radius;
    
    Force () 
    {
        super();
    }
    
    Force (PVector pos) 
    {
        this(pos, new PVector(0, 0, 0), 0);
    }
    Force (PVector pos, PVector vel, float radius) 
    {
        this.position = pos;
        this.velocity = vel;
        this.radius = radius;
    }
    
    void die () 
    {
        println("Force can’t die!");
    }
    
}