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
        this.ngrams.add(new NGramDisplay(this, ngram, this.ngrams.size()));
        this.calculateMaxValue();
        println("Ngram added: " + ngram.word);
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
            Ani.to(this, 5, "currentScale", this.maxValue);
        }
    }
    public float getMaxValue ()
    {
        return this.currentScale;
    }
    public void draw ()
    {
        pushMatrix();
        translate(width/2, height/2);
        fill(360, 100, 50, 255);
        rotate(radians(this.rotation));
        for (int i = 0; i < this.ngrams.size(); i++) {
            NGramDisplay ngramDisplay = (NGramDisplay) this.ngrams.get(i);
            ngramDisplay.draw();
        }
        popMatrix();
    }
}