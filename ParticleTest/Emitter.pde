import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

class Emitter 
{
    int maxParticles = 5000;
    ArrayList<Particle> particles;
    ArrayList<Force> forces;
    float gravity;
    PVector globalVelocity; 
    Method particleDrawEvent;
    PApplet p5;

    Emitter(PApplet p5) 
    {
        this.p5 = p5;
        particles = new ArrayList<Particle>(maxParticles);
        forces = new ArrayList<Force>();
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
    void update() 
    {
        for (int i = 0; i < particles.size(); i++) {
            Particle p = particles.get(i);
            if (p.alive) {
                if (globalVelocity.mag() != 0) p.addVelocity(globalVelocity);
                p.addVelocity(0, gravity * p.age, 0);
                p.update(); 
            } else {
                removeParticle(p);
            }
        }
    }
    void updateAndDraw() 
    {
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
        if (particles.size() < maxParticles) {
            particle.init(x, y, z, vx, vy, vz);
            
            particle.addBehavior(new BoundsOffWalls(100));
            
            // We can add Behaviors without making class files
            
            // particle.addBehavior(new Behavior() {
            //    public void apply (Particle p) {
            //        // bounce of edges left and right
            //        if (p.position.x < 0) {
            //            p.position.x = 0;
            //            p.velocity.x *= -1;
            //        }
            //        else if (p.position.x > width) {
            //            p.position.x = width;
            //            p.velocity.x *= -1;
            //        }
            //        // top and bottom
            //        if (p.position.y < 0) {
            //            p.position.y = 0;
            //            p.velocity.y *= -1;
            //        }
            //        else if (p.position.y > height) {
            //            p.position.y = height;
            //            p.velocity.y *= -1;
            //        }
            //    } 
            // });
            particles.add(particle);
            return particle;
        } else {
            // todo: kill old particle or wait?
        }
        return null;   
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
    
    // Access to particles
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
}