public class Word extends Particle 
{
    String word;
    CharParticle[] characters;
    int letterspacing = 0;
    float angle = 0;
    float radius = width / 4;
    Ani animateAngle;
    Ani animateRadius;
    PVector center = new PVector(width / 2, height / 2, 0);
    boolean dropping = false;
    float foo;
    
    public Word (String word, CharParticle[] characters, PVector pos) {
        super(pos, new PVector(0, 0, 0));
        this.word = word;
        this.characters = characters;
        setup();
    }
    
    public void setup() {        
        dropping = true;
        
        target = this.position;
        PVector displace = new PVector(0, 0, 0);
        for (int i = 0; i < word.length(); i++) {
            char c = word.charAt(i);
            CharParticle p = characters[i];
            // p.tweenTo(PVector.add(this.position, displace));
            // displace.add(new PVector(p.width + letterspacing, 0, 0));
            p.disableForces();
            p.resetRotation();
            p.slowSpin.seek(0);
            p.removeAllBehaviors();
            p.setVelocity(0, 0, 0);
            // p.tweenTo(new PVector(random(-1000, 1000), random(-1000, 1000), 0));
            p.ani = true;
            displace.add(new PVector(p.width + letterspacing, 0, 0));
            
            float targetX = width / 2 + displace.x;
            float targetY = height;
            float targetZ = z;
            println(this.z);
            
            // Ani.to(p, 4, "x:" + targetX + ", y: " + targetY + ", z:" + targetZ, Ani.BOUNCE_IN_OUT, "onEnd: setUsed");
            
            Ani.to(p, 4, "x:" + targetX + ", y: " + targetY + ", z:" + targetZ, Ani.BOUNCE_OUT);
            Ani.to(this, 4, "foo",  4, Ani.ELASTIC_IN_OUT, "onEnd:onFinishBounce");
        }
    }
    public void update () {
        if (!dropping) {
            float x = center.x + sin(radians(angle)) * radius;
            float y = center.y + cos(radians(angle)) * radius;
            this.setPosition(x, y, z);
        
            PVector displace = new PVector(0, 0, 0);
        
            float rotation = atan2(this.y - center.y, this.x - center.x);
            pushMatrix();
            translate(x, y, z);
            rotate(rotation - HALF_PI);
        
            // update each character to follow the word (uff)
            for (int i = 0; i < characters.length; i++) {
                CharParticle p = characters[i];
                // p.position.set(x + displace.x, y, 0);
                // displace.add(new PVector(p.width + letterspacing, 0, 0));
                translate(p.width, 0, 0);
                p.draw();
            }
            popMatrix();    
        } else {
            for (int i = 0; i < characters.length; i++) {
                CharParticle p = characters[i];
                p.setPosition(p.x, p.y, p.z);
                pushMatrix();
                // todo fix rotation
                    translate(p.x, p.y, p.z);
                    float rotation = atan2(p.y - center.y, p.x - center.x);
                    rotate(rotation - HALF_PI);
                    p.draw();
                popMatrix();
            }
        }        
    }
    public void onFinishDrop (Ani theAni) {

        // Ani.to(p, 4, "x:" + p.x + ", y: " + p.y + ", z:" + p.z, Ani.BOUNCE_IN_OUT);
        // // Oh wie doof, dass die callbacks sich auf das Ziel beziehen
        // Ani.to(this, 4, "foo",  0, Ani.ELASTIC_IN_OUT, "onEnd:onFinishBounce");
    }
    public void onFinishBounce (Ani theAni) {
        float rndm = random(30, 60);
        animateAngle = new Ani(this, rndm, "angle", 360, Ani.SINE_IN, "onEnd:onFinishFirstRound");
        animateAngle.start();
        
        animateRadius = new Ani(this, rndm * 4, "radius", 0);
        animateRadius.setEasing(Ani.LINEAR);
        animateRadius.start();

        dropping = false; 
    }
    public void onFinishFirstRound (Ani theAni) {
        this.angle = 0;
        println(theAni.getDuration());
        animateAngle = new Ani(this, theAni.getDuration(), "angle", 360);
        animateAngle.repeat();
        animateAngle.setEasing(Ani.LINEAR);
        animateAngle.start();
    }
}
