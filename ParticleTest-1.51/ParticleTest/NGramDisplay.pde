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
    CharCloud cc = null;
    Word word;
    
    public NGramDisplay (Scoreboard scoreboard, NGram ngram, float z, CharCloud cc)
    {
        this.sb = scoreboard;
        this.ngram = ngram;
        // Um die Farbe zu bestimmen, fürs erste
        // das Jahr des ersten Auftretens des Wortes
        this.colour = map(this.ngram.getFirstOccurance(), 1500, 2008, 0, 360);
        this.calculatePoints();
        this.z = z;
        this.cc = cc;
        if (this.cc != null) this.word = cc.getLabel(this.sb, this);
        Ani.to(this, 4.5, 2.5, "opacity", 255, Ani.EXPO_IN);
    }
    public void kill()
    {
        Ani.to(this, 1.5, "opacity", 0, Ani.EXPO_OUT, "onEnd:onFadeOut");
        if (this.word != null) this.word.dissolve();
        this.alive = false;
    }
    public void draw()
    {
        
        pushMatrix();
        translate(0, 0, -this.z*this.thickness);
        if (this.sb.getMaxValue() != this.scoreboardMaxValue) {
            this.scoreboardMaxValue = this.sb.getMaxValue();
            this.calculatePoints();
        }
        noStroke();
        fill(this.colour, 25, 50, this.opacity);
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
        this.calculatePolarPath();
        
        this.pTop = new QVector2D[this.pBottom.length];
        for (int i = 0; i < this.pBottom.length; i++) {
            if (i == 0 || i == pBottom.length-1) {
                // Das hier sollte man auch niemanden zeigen.
                QVector2D v;
                QVector2D v2;
                if (i == 0) {
                    v = this.pBottom[i+1].get();
                } else {
                    v = this.pBottom[i-1].get();
                }
                v.sub(this.pBottom[i]);
                v.normalize();
                v.mult(this.thickness);
                v.rotate(90);
                v2 = v.get();
                v2.rotate(180);
                v.add(this.pBottom[i]);
                v2.add(this.pBottom[i]);
                if (v.mag() < v2.mag()) {
                    pTop[i] = v;
                } else {
                    pTop[i] = v2;                    
                }
            } else {
                // Über die folgenden Variablennamen könnte man bei Gelegenheit noch mal nachdenken.
                QVector2D hui = displace(pBottom[i], pBottom[i+1]);
                float p = (hui.mag() - this.thickness) / hui.mag();
                QVector2D v1 = pBottom[i].get();
                QVector2D v2 = pBottom[i+1].get();
                v1.mult(p);
                v2.mult(p);

                QVector2D hui2 = displace(pBottom[i], pBottom[i-1]);
                float p2 = (hui2.mag() - this.thickness) / hui2.mag();
                QVector2D v12 = pBottom[i].get();
                QVector2D v22 = pBottom[i-1].get();
                v12.mult(p2);
                v22.mult(p2);

                pTop[i] = lineIntersection(v1.x, v1.y, v2.x, v2.y, v12.x, v12.y, v22.x, v22.y);
            }
        }
    }
    private void calculatePolarPath ()
    {
        this.pBottom = new QVector2D[this.ngram.decades.length];
        for (int i = 0; i < this.ngram.decades.length; i++) {
            float angle = map(i, 0, this.ngram.decades.length-1, this.sb.degreeSpan, 0);
            float radius = map(this.ngram.decades[i], 0, this.scoreboardMaxValue, width/2*this.sb.radiusBottom, width/2*this.sb.radiusTop);
            this.pBottom[i] = new QVector2D(1, 0);
            this.pBottom[i].rotate(angle);
            this.pBottom[i].mult(radius);
        }
    }
    public float getLastMagnitude()
    {
        return map(this.ngram.decades[this.ngram.decades.length-1], 0, this.scoreboardMaxValue, width/2*this.sb.radiusBottom, width/2*this.sb.radiusTop); 
    }
    QVector2D displace (QVector2D a, QVector2D b)
    {
        QVector2D aToB = b.get();
        aToB.sub(a);
        QVector2D normalVector = aToB.normalVector();
        return lineIntersection(0, 0, normalVector.x, normalVector.y, a.x, a.y, b.x, b.y);
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