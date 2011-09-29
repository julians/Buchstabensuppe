public class Word extends Particle 
{
    String word;
    CharParticle[] characters;
    int letterspacing = 0;
    PVector center = new PVector(width / 2, height / 2, 0);
    float rotation;
    public float z;
    boolean zAnimating = false;
    boolean label = false;
    Scoreboard scoreboard;
    NGramDisplay ngramDisplay;
    float circleSpeed;
    float zSpeed;
        
    public Word (String word, CharParticle[] characters, PVector pos) {
        super(pos, new PVector(0, 0, 0));
        this.word = word;
        this.z = 600;
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
    public void registerScoreboard (Scoreboard scoreboard)
    {
        this.scoreboard = scoreboard;
    }
    public void makeLabel(Scoreboard scoreboard, NGramDisplay ngramDisplay)
    {
        this.label = true;
        this.scoreboard = scoreboard;
        this.ngramDisplay = ngramDisplay;
        this.z = 100;
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
        this.circleSpeed = random(15, 20);
        this.zSpeed = random(1, 30);
        Ani.to(this, 5, "circleSpeed", 0.1, Ani.EXPO_OUT);
        Ani.to(this, 3, "zSpeed", 0.1, Ani.EXPO_OUT);
    }
    public void toFront ()
    {
        this.zAnimating = true;
        Ani.to(this, 3, "z", 600, Ani.ELASTIC_OUT, "onEnd:broughtToFront");
    }
    public void broughtToFront (Ani ani)
    {
        this.zAnimating = false;
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
                    QVector2D v = new QVector2D(0, 1);
                    if (label) {
                        v.mult(this.ngramDisplay.getLastMagnitude());
                    } else {
                        v.mult(width/2*0.5);
                    }
                    v.rotate(i*-5+this.rotation);
                    f.update();
                    f.setPosition(new PVector(v.x+width/2, v.y+height/2, this.z));
                    f.apply();
                    //float colour = this.scoreboard.getColour(this.word);
                }   
            }
        }
        if (this.label) {
            this.rotation = this.scoreboard.rotation+this.scoreboard.degreeSpan;
        } else {
            this.rotation += this.circleSpeed;
            if (!this.zAnimating) this.z -= this.zSpeed;
        }
    }
    public void dissolve () {
        forces.clear();
        for (int i = 0; i < characters.length; i++) {
            CharParticle character = characters[i];
            character.velocity.sub(random(-0.05, 0.05), random(-0.05, 0.05), random(0.05, 0.05));
            character.updateVelocity();
        }
    }
}
