public class CharCloud extends ParticleSystem
{
    HashMap<String, Word> words;
    PVector target;
    int letterspacing = 10;
    
    public CharCloud (PApplet p5) {
        this(p5, -1);
    }
    
    public CharCloud (PApplet p5, int max) {
        super(p5, max);
        words = new HashMap<String, Word>();
        init();
    }
    
    public void addWord (String s) {}
    public void removeWord (String s) {} // auflösen oder so
    
    public void formWord () {}
    
    // public ArrayList<String> getKeys () {}
    // public ArrayList<String> getValues () {}
    
    public void init () 
    {
        // create characters based on their distribution in German language
        int onePercent = getMaxParticles() / 100;
        HashMap<String, Float> d = Distribution.getDistribution();
        Iterator it = d.entrySet().iterator();
        while (it.hasNext()) 
        {
            Map.Entry pairs = (Map.Entry) it.next();

            // todo: Find a better solution for lower and upper case distribution
            char c;
            for (int i = 0; i < 1 + (Float) pairs.getValue() * onePercent; i++) {
                if ((int) random(1) == 0) {
                    c = ((String) pairs.getKey()).charAt(0);
                } else {
                    c = (((String) pairs.getKey()).toLowerCase()).charAt(0); 
                }
                // ForceField attraction = new ForceField(new PVector (random(width), random(height), 0)).setRadius(30).setStrength(-50);            
                CharParticle p = new CharParticle(p5, c);
                // p.addForceField(attraction);
                // attraction.influence(emitter.getParticles());

                addParticle(p, random(width), random(height), random(1000, 10000)).randomizeVelocity(1).setLifeSpan(-1);
                p.addBehavior(new Friction(0.01));
            } 
        }
    }
    
    public void formWord (String word, PVector pos) {
        target = pos;
        PVector displace = new PVector(0, 0, 0);
        for (int i = 0; i < word.length(); i++) {
            char c = word.charAt(i);
            CharParticle p = getParticleForChar(c);
            p.tweenTo(PVector.add(pos, displace));
            displace.add(new PVector(p.width + letterspacing, 0, 0));
            p.disableForces();
            // p.resetRotation();
        }
    }

    CharParticle getParticleForChar(char c) {
        for (int i = 0; i < particles.size(); i++) {
            if (particles.get(i) instanceof CharParticle) {
                CharParticle p = (CharParticle) particles.get(i);
                if (p.character == c && !p.used) {
                    p.used = true;
                    return p;   
                }
            }
        }
        CharParticle p = new CharParticle(p5, c);
        addParticle(p, random(width), random(height), target.z + random(100)).randomizeVelocity(1).setLifeSpan(-1);
        p.used = true;
        return p;
    }
}