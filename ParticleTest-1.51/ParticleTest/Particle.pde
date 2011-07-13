class Particle
{
    ArrayList<Behavior> behaviors;
    ArrayList<ForceField> forces;
    boolean alive;
    boolean ani;
    boolean useForces;
    boolean useTarget;
    float age;
    float alpha;
    float mass;
    float progress;
    float size;
    float span;
    float vx, vy, vz;
    public float x, y, z;
    PVector target;
    PVector position;
    PVector velocity;
    float foo;

    
    public Particle () 
    {
        this.forces = new ArrayList<ForceField>();
    }
    
    public Particle (PVector pos, PVector vel) {
        this.init(pos, vel);
    }
    
    public void init(float x, float y, float z, float vx, float vy, float vz) 
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
        this.useForces = true;
        this.useTarget = false;
        this.target = new PVector();
    }
    public void init (PVector pos, PVector vel) 
    {
        this.init(pos.x, pos.y, pos.z, vel.x, vel.y, vel.z);
    }
    public void update () 
    {
        age++;
        progress = age / span;
        if (age > span && span != -1) die();
        
        if (useTarget) {
            PVector dir = PVector.sub(target, position);
            dir.mult(0.05);
            velocity.set(dir);
        }
        if (!ani) {
            // update position
            position.add(velocity);

            // apply behaviors
            for (int i = 0; i < behaviors.size(); i++) behaviors.get(i).apply(this);

            // update x, y, z to fit vectors
            updatePosition();
            updateVelocity();

            if (useForces) {
                for (int i = 0; i < forces.size(); i++) {
                    ForceField f = forces.get(i);
                    f.setPosition(this.position);
                    f.apply();
                }   
            }
        }
    }
    public void die () 
    {
        alive = false;
        forces.clear();
    }
    Particle randomizeVelocity (float range) {
        return setVelocity(random(-range, range), random(-range, range), random(-range, range));
    }
    public void addVelocity (float vx, float vy, float vz) {
        this.addVelocity(new PVector(vx, vy, vz));
    }
    public void addVelocity (PVector v) {
        velocity.add(v);
        updateVelocity();
    }
    public void tweenTo (PVector target) {
        this.target = target;
        this.useTarget = true;
    }
    public void updatePosition () {
        x = position.x;
        y = position.y;
        z = position.z;
    }
    public void updateVelocity () {
        vx = velocity.x;
        vy = velocity.y;
        vz = velocity.z;
    }
    public void setPosition (float x, float y, float z) 
    {
        position.set(x, y, z);
        updatePosition();
    }
    public void setPosition (PVector p) 
    {
        position = p;
        updatePosition();
    }
    Particle setVelocity (float vx, float vy, float vz) 
    {
        velocity.set(vx, vy, vz);
        updateVelocity();
        return this;
    }
    public void setSize (float s) 
    {
        this.size = s;
    }
    Particle setLifeSpan (float s) 
    {
        this.span = s;
        return this;
    }
    // Behaviors
    Particle addBehavior (Behavior b) {
        this.behaviors.add(b);
        return this;
    }
    Particle removeBehavior (Behavior b) {
        this.behaviors.remove(b);
        return this;
    }
    Particle removeAllBehaviors () {
        this.behaviors.clear();
        return this;
    }
    // ForceFields
    Particle addForceField (ForceField f) {
        this.forces.add(f);
        return this;
    }
    Particle removeForceField (ForceField f) {
        this.forces.remove(f);
        return this;
    }
    void enableForces () {
        this.useForces = true;
    }
    void disableForces () {
        this.useForces = false;
    }

    
    
}