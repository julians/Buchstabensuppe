public class NGramDisplay
{
    private Scoreboard sb;
    public NGram ngram;
    private float colour;
    private float opacity = 0;
    public boolean alive = true;
    public float thickness = 5;
    private float scoreboardMaxValue = 0;
    private QVector2D[] pTop;
    private QVector2D[] pBottom;
    private float z;
    
    public NGramDisplay (Scoreboard scoreboard, NGram ngram, float z)
    {
        this.sb = scoreboard;
        this.ngram = ngram;
        // Um die Farbe zu bestimmen, fürs erste
        // das Jahr des ersten Auftretens des Wortes
        this.colour = map(this.ngram.getFirstOccurance(), 1500, 2008, 0, 360);
        this.calculatePoints();
        this.z = z;
        Ani.to(this, 3, "opacity", 255);
    }
    public void kill()
    {
        Ani.to(this, 1.5, "opacity", 0, Ani.getDefaultEasing(), "onEnd:onFadeOut");
        this.alive = false;
    }
    public void draw()
    {
        pushMatrix();
        translate(0, 0, -this.z*this.thickness);
        float m = this.sb.getMaxValue();
        if (m != this.scoreboardMaxValue) {
            this.scoreboardMaxValue = m;
            this.calculatePoints();
        }
        noStroke();
        fill(this.colour, 100, 50, this.opacity);
        // Vorderseite
        beginShape();
        for (int i = 0; i < this.pBottom.length; i++) {
            vertex(this.pBottom[i].x, this.pBottom[i].y, 0);
        }
        for (int i = this.pTop.length-1; i >= 0; i--) {
            vertex(this.pTop[i].x, this.pTop[i].y, 0);
        }
        endShape(CLOSE);
        // Rückseite
        beginShape();
        for (int i = 0; i < this.pBottom.length; i++) {
            vertex(this.pBottom[i].x, this.pBottom[i].y, this.thickness);
        }
        for (int i = this.pTop.length-1; i >= 0; i--) {
            vertex(this.pTop[i].x, this.pTop[i].y, this.thickness);
        }
        endShape(CLOSE);
        
        // Oben und unten
        beginShape(QUAD_STRIP);
        for (int i = 0; i < this.pBottom.length; i++) {
            vertex(this.pBottom[i].x, this.pBottom[i].y, 0);
            vertex(this.pBottom[i].x, this.pBottom[i].y, this.thickness);
        }
        for (int i = this.pTop.length-1; i >= 0; i--) {
            vertex(this.pTop[i].x, this.pTop[i].y, 0);
            vertex(this.pTop[i].x, this.pTop[i].y, this.thickness);
        }
        vertex(this.pBottom[0].x, this.pBottom[0].y, 0);
        vertex(this.pBottom[0].x, this.pBottom[0].y, this.thickness);
        endShape(CLOSE);
        popMatrix();
    }
    public void onFadeOut(Ani ani) {
        if (!this.alive) {
            this.sb.remove(this);
        }
    }
    public void setZ(float z)
    {
        Ani.to(this, 3, "z", z);
    }
    public void setZ(float z, float _delay)
    {
        Ani.to(this, 3, _delay, "z", z);
    }
    public void changeZ(float z)
    {
        Ani.to(this, 3, "z", this.z+z);
    }
    public void changeZ(float z, float _delay)
    {
        Ani.to(this, 3, _delay, "z", this.z+z);
    }
    private void calculatePoints()
    {
        float m = this.scoreboardMaxValue;
        float l = map(1, 0, this.ngram.decades.length, 0, this.sb.w);
        
        this.pTop = new QVector2D[this.ngram.decades.length];
        this.pBottom = new QVector2D[this.ngram.decades.length];
        for (int i = 0; i < this.ngram.decades.length; i++) {
            this.pBottom[i] = new QVector2D(i*l, map(this.ngram.decades[i], 0, m, this.sb.h, 0));
        }
        for (int i = 0; i < pBottom.length; i++) {
            float beforeAngle;
            if (i == 0) {
                beforeAngle = new QVector2D(l, 0).angleBetween(new QVector2D(0,l));
            } else {
                beforeAngle = new QVector2D(l, pBottom[i-1].y-pBottom[i].y).angleBetween(new QVector2D(0,l));
            }
            float afterAngle;
            if (i == pBottom.length-1) {
                afterAngle = new QVector2D(l, 0).angleBetween(new QVector2D(0,-l));
            } else {
                afterAngle = new QVector2D(l, pBottom[i+1].y-pBottom[i].y).angleBetween(new QVector2D(0,-l));
            }
            
            QVector2D before1;
            QVector2D before2 = pBottom[i].get();
            QVector2D after1 = pBottom[i].get();
            QVector2D after2;
            if (i == 0) {
                before1 = pBottom[i].get();
                before1.x -= l;
            } else {
                before1 = pBottom[i-1].get();
            }
            
            if (i == pBottom.length-1) {
                after2 = pBottom[i].get();
                after2.x += l;
            } else {
                after2 = pBottom[i+1].get();
            }

            before1.add(new QVector2D(-thickness, 0).rotateChain(degrees(beforeAngle)));
            before2.add(new QVector2D(-thickness, 0).rotateChain(degrees(beforeAngle)));
            after1.add(new QVector2D(-thickness, 0).rotateChain(degrees(afterAngle)));
            after2.add(new QVector2D(-thickness, 0).rotateChain(degrees(afterAngle)));

            this.pTop[i] = this.lineIntersection(before1.x, before1.y, before2.x, before2.y, after1.x, after1.y, after2.x, after2.y);
            if (this.pTop[i] == null) {
                this.pTop[i] = new QVector2D(i*l, this.pBottom[i].y-5);
            }
        }
    }
    QVector2D lineIntersection(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4)
    {
        float bx = x2 - x1;
        float by = y2 - y1;
        float dx = x4 - x3;
        float dy = y4 - y3; 
        float b_dot_d_perp = bx*dy - by*dx;
        if(b_dot_d_perp == 0) {
            return null;
        }
        float cx = x3-x1; 
        float cy = y3-y1;
        float t = (cx*dy - cy*dx) / b_dot_d_perp; 

        return new QVector2D(x1+t*bx, y1+t*by); 
    }
}