public class Word extends Particle 
{
    String word;
    CharParticle[] characters;
    
    public Word (String word, CharParticle[] characters, PVector pos, PVector vel) {
        super(pos, vel);
        this.word = word;
        this.characters = characters;
        this.position = pos;
        this.velocity = vel;
    }
}
