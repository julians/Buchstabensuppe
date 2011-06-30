class Behavior 
{   
    Behavior () 
    {
    }
    public void apply (Particle p, Object data) 
    {

    }
    public void apply (Particle p) 
    {
        this.apply(p, null);
    }
}
