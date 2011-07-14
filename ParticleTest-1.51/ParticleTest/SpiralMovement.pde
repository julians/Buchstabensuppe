public class SpiralMovement extends Behavior 
{
    float angle = random(360);
    float startAngle = angle;
    float radius;
    Ani animateAngle;
    Ani animateRadius;
    PVector center = new PVector(width / 2, height / 2, 0);
    Particle p;
    
    public SpiralMovement (Particle p) 
    {
        super(); 
        this.p = p;
        this.radius = p.y;
        start();  
    }
    public void apply (Particle p) {
        float x = center.x + sin(radians(angle)) * radius;
        float y = center.y + cos(radians(angle)) * radius;
        float vx = x - p.x;
        float vy = y - p.y;
        p.setVelocity(vx, vy, p.vz);
    }
    public void start () {
        float rndm = random(30, 60);
        animateAngle = new Ani(this, rndm, "angle", 360-startAngle, Ani.SINE_IN, "onEnd:onFinishFirstRound");
        animateAngle.start();
        animateRadius = new Ani(this, rndm * 4, "radius", 0);
        animateRadius.setEasing(Ani.LINEAR);
        animateRadius.start();
    }
    public void onFinishFirstRound (Ani theAni) {
        this.angle = 0;
        animateAngle = new Ani(this, theAni.getDuration(), "angle", 360-startAngle);
        animateAngle.repeat();
        animateAngle.setEasing(Ani.LINEAR);
        animateAngle.start();
    }
}
