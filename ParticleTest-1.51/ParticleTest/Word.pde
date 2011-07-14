public class Word extends Particle 
{
    String word;
    CharParticle[] characters;
    int letterspacing = 0;
    PVector center = new PVector(width / 2, height / 2, 0);
    float rotation;
    float z;
        
    public Word (String word, CharParticle[] characters, PVector pos) {
        super(pos, new PVector(0, 0, 0));
        this.word = word;
        this.z = pos.z;
        this.rotation = random(-25, 25);
        this.characters = characters;
        init();
    }
    public Word (String word, CharParticle[] characters, PVector pos, PVector vel) {
        super(pos, vel);
        this.word = word;
        this.characters = characters;
        this.z = 600;
        this.rotation = random(-25, 25);
        init();
    }
    public void init () {
        // Kräfte und so erzeugen
        PVector offset = new PVector(x, y, z);
        for (int i = 0; i < characters.length; i++) {
            CharParticle p = characters[i];
            offset.add(p.w, 0, 0);
            ForceField attractor = new ForceField(offset, this.velocity, 10, 100);
            // attractor.show();
            addForceField(attractor);
            attractor.influence(p);
        }
    }
    public void update () 
    {
        age++;
        progress = age / span;
        if (age > span && span != -1) die();
        
        if (!ani) {
            // update position
            position.add(velocity);
    
            // update x, y, z to fit vectors
            updatePosition();
            updateVelocity();
            
            // apply behaviors
            for (int i = 0; i < behaviors.size(); i++) behaviors.get(i).apply(this);
    
            if (useForces) {
                for (int i = 0; i < forces.size(); i++) {
                    ForceField f = forces.get(i);
                    QVector2D v = new QVector2D(0, -1);
                    v.mult(width/2*0.5);
                    v.rotate(i*-5+this.rotation);
                    f.update();
                    //float angle = atan2(this.y - center.y, this.x - center.x);
                    //float radius = PVector.sub(this.position, center).mag();
                    //float x = center.x + sin(radians(angle)) * radius;
                    //float y = center.y + cos(radians(angle)) * radius;
                    f.setPosition(new PVector(v.x+width/2, v.y+height/2, this.z));
                    // f.setVelocity(this.velocity);
                    f.apply();
                }   
            }
        }
        this.rotation += 0.1;
        this.z -= 0.1;
    }
}
