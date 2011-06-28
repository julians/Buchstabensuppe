class Particle
{
    float x, y, z;
    float vx, vy, vz;
    PVector position;
    PVector velocity;
    float size;
    float alpha;
    float mass;
    boolean alive;
    float age;
    float span;
    float progress;
    ArrayList<Behavior> behaviors;
    
    Particle () 
    {
    }
    
    void init(float x, float y, float z, float vx, float vy, float vz) 
    {
        this.position = new PVector(x, y, z);
        this.updatePosition();
        this.velocity = new PVector(vx, vy, vz);
        this.updateVelocity();
        this.size = 5;
        this.mass = random(0.1, 1);
        this.alive = true;
        this.age = 0;
        this.span = 1 + (int) random(100);
        this.behaviors = new ArrayList<Behavior>();
        this.progress = 0;
    }
    void init (PVector pos, PVector vel) 
    {
        this.init(pos.x, pos.y, pos.z, vel.x, vel.y, vel.z);
    }
    void update () 
    {
        age++;
        progress = age / span;
        if (age > span) die();
        
        // update position
        position.add(velocity);
        
        // apply behaviors
        for (int i = 0; i < behaviors.size(); i++) behaviors.get(i).apply(this);
        
        // update x, y, z to fit vectors
        updatePosition();
        updateVelocity();
    }
    void die () 
    {
        alive = false;
    }
    void randomizeVelocity (float range) {
        setVelocity(random(-range, range), random(-range, range), random(-range, range));
    }
    void addVelocity (float vx, float vy, float vz) {
        this.addVelocity(new PVector(vx, vy, vz));
    }
    void addVelocity (PVector v) {
        velocity.add(v);
        updateVelocity();
    }
    void updatePosition () {
        x = position.x;
        y = position.y;
        z = position.z;
    }
    void updateVelocity () {
        vx = velocity.x;
        vy = velocity.y;
        vz = velocity.z;
    }
    void setPosition (float x, float y, float z) 
    {
        position.set(x, y, z);
        updatePosition();
    }
    void setVelocity (float vx, float vy, float vz) 
    {
        velocity.set(vx, vy, vz);
        updateVelocity();
    }
    void setSize (float s) 
    {
        this.size = s;
    }
    // Behaviors
    void addBehavior (Behavior b) {
        this.behaviors.add(b);
    }

    
    
}