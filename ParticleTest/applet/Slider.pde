public class Slider 
{
    PApplet p;
    int swidth, sheight;
    int xpos, ypos;
    float spos, newspos;
    int sposMin, sposMax;
    int loose;
    boolean over;
    boolean locked;
    float ratio;
    public boolean moved;
    float sLength, vLength, vMin, vMax;
    String id;
    Method sliderEvent;

    public Slider(PApplet _PApplet, String id, int xp, int yp, int sw, int sh, float mn, float mx, int l) {

	    this.p = _PApplet;
        this.id = id;
	    this.swidth = sw;
	    this.sheight = sh;
	    int widthtoheight = sw - sh;
	    this.ratio = (float) sw / (float) widthtoheight;
	    this.xpos = xp;
	    this.ypos = yp - sheight / 2;
	    this.spos = xpos + swidth / 2 - sheight / 2;
	    this.newspos = spos;
	    this.sposMin = xpos;
	    this.sposMax = xpos + swidth - sheight;
	    this.loose = l;
	    this.vMin = mn;
	    this.vMax = mx;
	    this.vLength = vMax - vMin;
	    this.sLength = swidth - sheight;
	    
        try {
	    	this.sliderEvent = p.getClass().getMethod("sliderEvent", Slider.class);
	    } catch (SecurityException e) {
	    	System.out.println("security error: ");
	    	e.printStackTrace();
	    } catch (NoSuchMethodException e) {
	    	System.out.println("Info: Use sliderEvent(Slider) to automatically get updates from the slider.");
	    } catch (IllegalArgumentException e) {
	    	System.out.println("illegal args: ");
	    	e.printStackTrace();
	    }
	    p.registerDraw(this);
    }

    public void update() 
    {
	    if (over()) {
	        over = true;
	    } 
	    else {
	        over = false;
	    }
	    if (p.mousePressed && over) {
	        locked = true;
	    }
	    if (!p.mousePressed) {
	        locked = false;
	    }
	    if (locked) {
	        newspos = constrain(p.mouseX - sheight / 2, sposMin, sposMax);
	    }
	    if (p.abs(newspos - spos) > 1) {
	        spos = spos + (newspos - spos) / loose;
	        moved = true;
	    } 
	    else {
	        moved = false;
	    }
    }
    public void draw() {
        update();
        noStroke();
	    p.fill(255, 50);
	    p.rect(xpos, ypos, swidth, sheight);
	    
	    if (over || locked) {
	        p.fill(240, 200, 0);
	    } 
	    else {
	        p.fill(255, 0, 0);
	    }
	    p.rect(spos, ypos, sheight, sheight);
	    p.fill(255);
	    p.text(id, xpos, ypos + sheight + textAscent() + 5);
	    
	    if (moved) fireEvent();
    }
    public void fireEvent () 
    {
        // uses the drawParticle method in the main program
        if (this.sliderEvent != null) {
            try {
                this.sliderEvent.invoke(p, this);
            } catch (IllegalArgumentException e) {
    			// TODO Auto-generated catch block
    			e.printStackTrace();
    		} catch (IllegalAccessException e) {
    			// TODO Auto-generated catch block
    			e.printStackTrace();
    		} catch (InvocationTargetException e) {
                // TODO Auto-generated catch block
    			e.printStackTrace();
            }
        }    
    }
    int constrain (int val, int minv, int maxv) 
    {
	    return p.min(p.max(val, minv), maxv);
    }
    boolean over() 
    {
	    if (p.mouseX > xpos && p.mouseX < xpos + swidth && p.mouseY > ypos && p.mouseY < ypos + sheight) {
	        return true;
	    } 
	    else {
	        return false;
	    }
    }
    public float getValue() {
	return p.max(p.min((vMin + ((spos - xpos) * vLength) / sLength), vMax),
		vMin);
    }
}
