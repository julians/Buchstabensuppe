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
    int age;
    int span;
    
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
        this.span = (int) random(100);
    }
    void init (PVector pos, PVector vel) 
    {
        this.init(pos.x, pos.y, pos.z, vel.x, vel.y, vel.z);
    }
    void update () 
    {
        age++;
        if (age > span) die();
        
        // update position
        position.add(velocity);

        // bounce of edges
        if (position.x < 0) {
            position.x = 0;
            velocity.x *= -1;
        }
        else if (position.x > width) {
            position.x = width;
            velocity.x *= -1;
        }

        if (position.y < 0) {
            position.y = 0;
            velocity.y *= -1;
        }
        else if (position.y > height) {
            position.y = height;
            velocity.y *= -1;
        }
        // todo: z-space handling
        
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
}