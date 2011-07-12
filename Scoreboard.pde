class Scoreboard
{
    ArrayList<NGramDisplay> ngrams;
    private float max_value;
    public float w;
    public float h;
    private float currentScale;
    private float tweenDuration = 50f;
    private String tweenEasing = Tween.QUAD_EASE_BOTH;
    
    Scoreboard (float w, float h)
    {
        this.w = w;
        this.h = h;
        this.max_value = 0;
        this.currentScale = 0;
        
        this.ngrams = new ArrayList();
    }
    public void add (NGram ngram)
    {
        this.ngrams.add(new NGramDisplay(this, ngram, this.ngrams.size()));
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
        this.calculateMaxValue();
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
    private void calculateMaxValue ()
    {
        float old_max_value = this.max_value;
        this.max_value = 0;
        
        for (int i = 0; i < this.ngrams.size(); i++) {
            NGramDisplay ngramDisplay = (NGramDisplay) this.ngrams.get(i);
            if (!ngramDisplay.alive) continue;
            if (ngramDisplay.ngram.decade_max_value > this.max_value) {
                this.max_value = ngramDisplay.ngram.decade_max_value;
            }
        }
        if (this.max_value != old_max_value) {
            Ani.to(this, 1.5, "currentScale", this.max_value);
        }
    }
    public float getMaxValue ()
    {
        return this.currentScale;
    }
    public void draw ()
    {
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
        
        for (int i = 0; i < this.ngrams.size(); i++) {
            NGramDisplay ngramDisplay = (NGramDisplay) this.ngrams.get(i);
            ngramDisplay.draw();
        }
    }
}