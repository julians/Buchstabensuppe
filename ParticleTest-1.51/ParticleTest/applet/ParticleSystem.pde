import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

class ParticleSystem 
{
    int maxParticles;
    ArrayList<Particle> particles;
    ArrayList<ForceField> forces;
    float gravity;
    PVector globalVelocity; 
    Method particleDrawEvent;
    PApplet p5;

    ParticleSystem(PApplet p5) 
    {
        this(p5, -1); // -1 = unlimited particles
    }
    ParticleSystem (PApplet p5, int max) 
    {
        this.maxParticles = max;
        this.p5 = p5;
        particles = new ArrayList<Particle>();
        forces = new ArrayList<ForceField>();
        this.globalVelocity = new PVector();
        
        // check if there is a custom draw function
        try {
			this.particleDrawEvent = p5.getClass().getMethod("drawParticle", Particle.class);
		} catch (SecurityException e) {
			System.out.println("security error: ");
			e.printStackTrace();
		} catch (NoSuchMethodException e) {
			System.out.println("Info: Use drawParticle(Particle p) instead of looping through getParticles() on your own.");
		} catch (IllegalArgumentException e) {
			System.out.println("illegal args: ");
			e.printStackTrace();
		}
    }

    void update () {
        for (int i = 0; i < particles.size(); i++) {
            Particle p = particles.get(i);
            updateParticle(p);
        }
        // apply forces
        for (int i = 0; i < forces.size(); i++) {
            forces.get(i).apply();
        }
    }
    void updateAndDraw() 
    {
        for (int i = 0; i < particles.size(); i++) {
            Particle p = particles.get(i);
            updateAndDrawParticle(p);
        }
        for (int i = 0; i < forces.size(); i++) {
            ForceField f = forces.get(i);
            if (f.visible) f.draw();
            f.apply();
        }
    }
    void updateAndDraw(GLGraphicsOffScreen canvas) 
    {
        for (int i = 0; i < particles.size(); i++) {
            Particle p = particles.get(i);
            updateAndDrawParticle(p);
        }
        for (int i = 0; i < forces.size(); i++) {
            ForceField f = forces.get(i);
            if (f.visible) f.draw(canvas);
            f.apply();
        }
    }
    public void drawParticle(Particle p) 
    {   
        // uses the drawParticle method in the main program
        if (this.particleDrawEvent != null) {
            try {
                this.particleDrawEvent.invoke(p5, p);
            } catch (IllegalArgumentException e) {
    			// TODO Auto-generated catch block
    			e.printStackTrace();
    		} catch (IllegalAccessException e) {
    			// TODO Auto-generated catch block
    			e.printStackTrace();
    		} catch (InvocationTargetException e) {
                // TODO Auto-generated catch block
    			e.printStackTrace();
            }
        }
    }
    void updateParticle (Particle p) {
        // apply global velocities
        if (globalVelocity.mag() != 0) p.addVelocity(globalVelocity);
        // apply gravitation
        p.addVelocity(0, gravity * p.age, 0);
        // update particle
        p.update();
    }
    void updateAndDrawParticle (Particle p) {
        if (p.alive) {
            updateParticle(p);
            drawParticle(p);
        } else {
            removeParticle(p);
        }
    }
    void addParticles(float x, float y, float z, int count)
    {
        for(int i = 0; i < count; i++) addParticle(x + random(-15, 15), y + random(-15, 15), z + random(-15, 15));
    }
    Particle addParticle (float x, float y, float z, float vx, float vy, float vz) 
    {
        Particle particle = new Particle();
        return this.addParticle(particle, x, y, z, vx, vy, vz);
    }
    Particle addParticle (Particle p, float x, float y, float z) 
    {
        return this.addParticle(p, x, y, z, 0, 0, 0);
    }
    Particle addParticle (float x, float y, float z) 
    {
        return this.addParticle(x, y, z, 0, 0, 0);
    }
    Particle addParticle () 
    {
        return this.addParticle(random(width), random(height), 0);
    }
    Particle addParticle (Particle particle, float x, float y, float z, float vx, float vy, float vz) 
    {
        particle.init(x, y, z, vx, vy, vz);
        if (maxParticles == -1 || particles.size() < maxParticles) {
            particles.add(particle);
            for (int i = 0; i < forces.size(); i++) {
                forces.get(i).influence(particle);
            }
            return particle;
        } else {
            // todo: kill old particle or wait?
            particles.add(particle);
            for (int i = 0; i < forces.size(); i++) {
                forces.get(i).influence(particle);
            }
            return particle;
        }
    }
    void removeParticle (Particle p) 
    {
        particles.remove(p);
        for (int i = 0; i < forces.size(); i++) {
            ForceField f = forces.get(i);
            if (f.particles.contains(p)) {
                f.particles.remove(f.particles.indexOf(p));
            }
        }   
    }
    void removeParticle (int index) 
    {
        Particle p = particles.get(index);
        for (int i = 0; i < forces.size(); i++) {
            ForceField f = forces.get(i);
            if (f.particles.contains(p)) {
                f.particles.remove(f.particles.indexOf(p));
            }
        }   
        particles.remove(index);
    }
    
    // Forces
    ForceField addForceField (PVector pos, PVector vel, float radius) 
    {
        ForceField f = new ForceField (pos, vel, radius);
        return this.addForceField(f);
    }
    ForceField addForceField(PVector pos) 
    {
        ForceField f = new ForceField (pos);
        return this.addForceField(f);
    }
    ForceField addForceField (ForceField f) 
    {
        this.forces.add(f);
        for (int i = 0; i < particles.size(); i++) {
            f.influence(particles.get(i));
        }
        return f;
    }
    void clearForces (Particle p) {
        for (int i = 0; i < forces.size(); i++) {
            forces.get(i).remove(p);
        }
    }
    
    // Global Velocity
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
    
    // gravity
    void enableGravity (float g) 
    {
        this.gravity = g;
    }
    void disableGravity () 
    {   
        this.gravity = 0;
    }
    
    // access to particles
    ArrayList<Particle> getParticles() 
    {
        return particles;
    }
    ArrayList<Particle> setSize(float s) 
    {
        for (int i = 0; i < particles.size(); i++) {
            particles.get(i).setSize(s);
        }
        return particles;
    }
    int getParticleCount ()
    {
        return particles.size();
    }
    int getMaxParticles () 
    {
        return maxParticles;
    }
}
