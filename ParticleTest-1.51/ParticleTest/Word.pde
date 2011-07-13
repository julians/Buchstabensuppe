public class Word extends Particle 
{
    String word;
    CharParticle[] characters;
    int letterspacing = 0;
        
    public Word (String word, CharParticle[] characters, PVector pos) {
        super(pos, new PVector(0, 0, 0));
        this.word = word;
        this.characters = characters;
        init();
    }
    public Word (String word, CharParticle[] characters, PVector pos, PVector vel) {
        super(pos, vel);
        this.word = word;
        this.characters = characters;
        init();
    }
    public void init () {
        // Kräfte und so erzeugen
        println(this.velocity);
        PVector offset = new PVector(x, y, z);
        for (int i = 0; i < characters.length; i++) {
            CharParticle p = characters[i];
            offset.add(p.w, 0, 0);
            ForceField attractor = new ForceField(offset, this.velocity, 1000, 100);
            attractor.show();
            addForceField(attractor);
            attractor.influence(p);
        }
    }
}
