class Scoreboard
{
    ArrayList<NGramDisplay> ngrams;
    private float maxValue;
    public float radiusTop;
    public float radiusBottom;
    private float currentScale;
    private float tweenDuration = 50f;
    public float rotation = 0;
    public float degreeSpan;
    CharCloud cc = null;
    
    Scoreboard (float degreeSpan, float radiusTop, float radiusBottom)
    {
        this.radiusTop = radiusTop;
        this.radiusBottom = radiusBottom;
        this.degreeSpan = degreeSpan;
        this.maxValue = 0;
        this.currentScale = 0;
        
        this.ngrams = new ArrayList();
    }
    public void add (NGram ngram)
    {
        this.ngrams.add(new NGramDisplay(this, ngram, this.ngrams.size(), this.cc));
        this.calculateMaxValue();
    }
    public void remove (String word)
    {
        boolean killed = false;
        for (int i = 0; i < this.ngrams.size(); i++) {
            NGramDisplay ngramDisplay = (NGramDisplay) this.ngrams.get(i);
            if (killed) ngramDisplay.changeZ(-1, 1);
            if (ngramDisplay.ngram.word.equals(word)) {
                ngramDisplay.kill();
                killed = true;
            }
        }
        this.calculateMaxValue(true);
    }
    public void remove (NGramDisplay _ngramDisplay)
    {
        for (int i = 0; i < this.ngrams.size(); i++) {
            NGramDisplay ngramDisplay = (NGramDisplay) this.ngrams.get(i);
            if (ngramDisplay == _ngramDisplay) {
                this.ngrams.remove(i);
            }
        }
    }
    public float getColour (String word)
    {
        for (int i = 0; i < this.ngrams.size(); i++) {
            NGramDisplay ngramDisplay = (NGramDisplay) this.ngrams.get(i);
            if (ngramDisplay.ngram.word.equals(word)) {
                return ngramDisplay.colour;
            }
        }
        return -1;
    }
    private void calculateMaxValue ()
    {
        this.calculateMaxValue(false);
    }
    private void calculateMaxValue (boolean removed)
    {
        float old_maxValue = this.maxValue;
        this.maxValue = 0;
        
        for (int i = 0; i < this.ngrams.size(); i++) {
            NGramDisplay ngramDisplay = (NGramDisplay) this.ngrams.get(i);
            if (!ngramDisplay.alive) continue;
            if (ngramDisplay.ngram.decade_max_value > this.maxValue) {
                this.maxValue = ngramDisplay.ngram.decade_max_value;
            }
        }
        if (this.maxValue != old_maxValue) {
            String animation = Ani.SINE_OUT;
            float d = 15f;
            if (removed) {
                animation = Ani.CUBIC_OUT;
                d = 10f;
            }
            Ani.to(this, d, "currentScale", this.maxValue, animation);
        }
    }
    public float getMaxValue ()
    {
        return this.currentScale > 0 ? this.currentScale : 1;
    }
    public void draw ()
    {
        /*
        noStroke();
        fill(360, 0, 75);
        beginShape(QUAD_STRIP);
        vertex(0, 0, 0);
        vertex(0, 0, 10);
        vertex(0, this.h, 0);
        vertex(0, this.h, 10);
        vertex(this.w, this.h, 0);
        vertex(this.w, this.h, 10);
        vertex(this.w, this.h+10, 0);
        vertex(this.w, this.h+10, 10);
        vertex(-10, this.h+10, 0);
        vertex(-10, this.h+10, 10);
        vertex(-10, 0, 0);
        vertex(-10, 0, 10);
        endShape(CLOSE);
        */
        pushMatrix();
        translate(width/2, height/2);
        rotate(radians(this.rotation));
        for (int i = 0; i < this.ngrams.size(); i++) {
            NGramDisplay ngramDisplay = (NGramDisplay) this.ngrams.get(i);
            ngramDisplay.draw();
        }
        popMatrix();
        this.rotation += 0.025;
    }
    public void registerCharCloud (CharCloud cc)
    {
        this.cc = cc;
    }
}