public class PFrame extends Frame 
{
    public PFrame(PApplet p) 
    {
        setBounds(100, 100, 200, 600);
        controlWindow = new ControlWindow(p);
        add(controlWindow);
        controlWindow.init();
        show();
    }
}
