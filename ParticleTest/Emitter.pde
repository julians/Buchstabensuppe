class Emitter 
{
    int maxParticles = 5000;
    ArrayList<Particle> particles;
    ArrayList<Force> forces;
    float gravity;
    PVector globalVelocity;

    Emitter() 
    {
        particles = new ArrayList<Particle>(maxParticles);
        forces = new ArrayList<Force>();
        this.globalVelocity = new PVector();
    }
    void updateAndDraw() 
    {
        stroke(255);
        fill(255);

        for (int i = 0; i < particles.size(); i++) {
            Particle p = particles.get(i);
            if (p.alive) {
                if (globalVelocity.mag() != 0) p.addVelocity(globalVelocity);
                p.addVelocity(0, gravity * p.age, 0);
                p.update();
                drawParticle(p);   
            } else {
                removeParticle(p);
            }
        }
    }
    void drawParticle(Particle p) 
    {
        point(p.x, p.y);
    }
    void addParticles(float x, float y, float z, int count)
    {
        for(int i = 0; i < count; i++) addParticle(x + random(-15, 15), y + random(-15, 15), z + random(-15, 15));
    }
    Particle addParticle (float x, float y, float z, float vx, float vy, float vz) 
    {
        Particle p = new Particle();
        if (particles.size() < maxParticles) {
            p.init(x, y, z, vx, vy, vz);
            particles.add(p);
            return p;
        } else {
            // todo: kill old particle or wait?
        }
        return null;
    }
    Particle addParticle (float x, float y, float z) 
    {
        return this.addParticle(x, y, z, 0, 0, 0);
    }
    Particle addParticle () 
    {
        return this.addParticle(random(width), random(height), 0);
    }
    void removeParticle (Particle p) 
    {
        particles.remove(p);
    }
    
    // Forces
    void addForce (PVector pos, PVector vel, float radius) 
    {
        Force f = new Force (pos, vel, radius);
        this.addForce(f);
    }
    void addForce(PVector pos) 
    {
        Force f = new Force (pos);
        this.addForce(f);
    }
    void addForce (Force f) 
    {
        this.forces.add(f);
    }
    
    // Global Velocity (Gravity, Wind, ...)
    void addGlobalVelocity (PVector vel) 
    {
        globalVelocity.add(vel);
    }
    void addGlobalVelocity (float vx, float vy, float vz) 
    {
        this.addGlobalVelocity(new PVector(vx, vy, vz));
    }
    void setGlobalVelocity (PVector vel) 
    {
        globalVelocity.set(vel);
    }
    void setGlobalVelocity (float vx, float vy, float vz) 
    {
        this.setGlobalVelocity(new PVector(vx, vy, vz));
    }
    void resetGlobalVelocity () 
    {
        globalVelocity.set(0, 0, 0);
    }
    
    // Gravity
    void enableGravity (float g) 
    {
        this.gravity = g;
    }
    void disableGravity () 
    {   
        this.gravity = 0;
    }
}