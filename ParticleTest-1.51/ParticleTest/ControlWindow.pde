public class ControlWindow extends PApplet 
{
    
    ControlP5 controlP5;
    PApplet p;
    Slider2D s;
    
    ControlWindow(PApplet p) 
    {
        this.p = p;
        this.controlP5 = new ControlP5(p);
    }
    
    public void setup() {
        size(200, 600);
        controlP5 = new ControlP5(this);
        //// Slider für das ForceField
        controlP5 = new ControlP5(this);
        controlP5.addSlider("radius", 0, 5000, 100, 10, 40, 100, 20).setId(1);
        controlP5.addSlider("strength", -50, 50, 10, 10, 65, 100, 20).setId(2);
        controlP5.addSlider("ramp", 0, 2, 1, 10, 90, 100, 20).setId(3);
        controlP5.addSlider("fade speed", 0, 0.1, 0.05, 10, 115, 100, 20).setId(4);
        controlP5.addSlider("delta time", 0, 1, 0.06, 10, 140, 100, 20).setId(5);
        controlP5.addSlider("viscosity", 0, 0.001, 0.00004, 10, 165, 100, 20).setId(6);
        controlP5.addSlider("fluid size", 1, 4, 2, 10, 190, 100, 20).setId(7);
        controlP5.addSlider("force z", -100, 100, 0, 10, 215, 100, 20).setId(8);
        
        controlP5.addSlider("exposure", 0, 1, 1.0, 10, 240, 100, 20).setId(9);
        controlP5.addSlider("decay", 0, 1, 0.7, 10, 265, 100, 20).setId(10);
        controlP5.addSlider("density", 0, 1, 0.7, 10, 290, 100, 20).setId(11);
        controlP5.addSlider("weight", 0, 1, 0.9, 10, 315, 100, 20).setId(12);

        s = controlP5.addSlider2D("light position",10,340,100,100);
        s.setMaxX(1.0);
        s.setMaxY(1.0);
        s.setId(13);
        
        controlP5.addSlider("dolly step", -50, 50, 5, 10, 465, 100, 20).setId(14);
    
    }

    public void draw() {
        background(0);
    }
    
    public void controlEvent(ControlEvent theEvent) 
    {
        float v = theEvent.controller().value();

        switch(theEvent.controller().id()) {
            case(1):
                force.setRadius(v);
                break;
            case(2):
                force.setStrength(v);
                break;
            case(3):
                force.setRamp(v);
                break;  
            case(4):
                fluid.fluidSolver.setFadeSpeed(v);
                break;
            case(5):
                fluid.fluidSolver.setDeltaT(v);
                break;
            case(6):
                fluid.fluidSolver.setVisc(v);
                break;
            case(7):
                fluidSize = v;
                break;
            case(8):
                force.setPosition(force.x, force.y, v);
                break;
            case(9):
                exposure = v;
                break;
            case(10):
                decay = v;
                break;
            case(11):
                density = v;
                break;  
            case(12):
                weight = v;
                break;
            case(13):
                light.x = s.arrayValue()[0];
                light.y = s.arrayValue()[1];
                break;
            case(14):
                dollyStep = v;
                break;
        }
    }
}