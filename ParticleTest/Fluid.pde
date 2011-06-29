import msafluid.*;
 
import processing.opengl.*;
import javax.media.opengl.*;

public class Fluid 
{
    // PApplet
    PApplet p;

    // Fluid 
    public MSAFluidSolver2D fluidSolver;
    PImage imgFluid;
    boolean drawFluid = true;
    float FLUID_WIDTH = 120; 
    public float invWidth, invHeight;    // inverse of screen dimensions
    public float aspectRatio, aspectRatio2;

    PVector center;
    
    public Fluid (PApplet p) 
    {
        this.p = p;
        init();
    }
    
    void init () {
        invWidth = 1.0f / p.width;
        invHeight = 1.0f / p.height;
        aspectRatio = p.width * invHeight;
        aspectRatio2 = aspectRatio * aspectRatio;

        // create fluid and set options
        fluidSolver = new MSAFluidSolver2D((int)(FLUID_WIDTH), (int)(FLUID_WIDTH * p.height / p.width));
        fluidSolver.enableRGB(true).setFadeSpeed(0.003).setDeltaT(0.5).setVisc(0.0001);

        // create image to hold fluid picture
        imgFluid = createImage(fluidSolver.getWidth(), fluidSolver.getHeight(), RGB);

        center = new PVector(p.width / 2, p.height / 2);
    }

    void draw () {
        fluidSolver.update();

        if(drawFluid) {
            for(int i=0; i<fluidSolver.getNumCells(); i++) {
                int d = 2;
                imgFluid.pixels[i] = color(fluidSolver.r[i] * d, fluidSolver.g[i] * d, fluidSolver.b[i] * d);
            }  
            imgFluid.updatePixels();  
            p.image(imgFluid, 0, 0, width, height);
        } 
    }

    // add force and dye to fluid, and create particles
    void addForce(float x, float y, float dx, float dy) {
        float speed = dx * dx  + dy * dy * aspectRatio2;    // balance the x and y components of speed with the screen aspect ratio

        if (speed > 0) {
            if(x<0) x = 0; 
            else if(x>1) x = 1;
            if(y<0) y = 0; 
            else if(y>1) y = 1;

            float colorMult = 2;
            float velocityMult = 30.0f;

            int index = fluidSolver.getIndexForNormalizedPosition(x, y);

            color drawColor;

            colorMode(HSB, 360, 1, 1);
            // float hue = ((x + y) * 180 + frameCount) % 360;
            float hue = p.map(mouseX, 0, width, 0, 360);
            drawColor = color(hue, 0.5, 0.1);
            colorMode(RGB, 1);  

            fluidSolver.rOld[index]  += red(drawColor) * colorMult;
            fluidSolver.gOld[index]  += green(drawColor);
            fluidSolver.bOld[index]  += blue(drawColor);

            fluidSolver.uOld[index] += dx * velocityMult;
            fluidSolver.vOld[index] += dy * velocityMult;
        }
    }

    void addNebula() {
        for (int x = 0; x < width; x += 100) {
            for (int y = 0; y < height; y += 100) {
    	        addForce(x * invWidth, y * invHeight, p.random(-10, 10), 
    		    p.random(-10, 10));
            }
        }
    }
}
 
