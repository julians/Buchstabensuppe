class Scoreboard
{
    HashMap<String, NGram> ngrams;
    HashMap<String, Float> ngramColours;
    float max_value ;
    float w;
    float h;
    Tween t;
    float tweenDuration = 50;
    
    Scoreboard (float w, float h)
    {
        this.w = w;
        this.h = h;
        this.max_value = 0;
        this.t = new Tween(max_value, max_value, 1f);
        this.t.play();
        
        this.ngrams = new HashMap();
        this.ngramColours = new HashMap();
    }
    public void add (NGram ngram)
    {
        this.ngrams.put(ngram.word, ngram);
        // Um die Farbe zu bestimmen, fürs erste
        // das Jahr des ersten Auftretens des Wortes
        this.ngramColours.put(ngram.word, map(ngram.getFirstOccurance(), 1500, 2008, 0, 360));
        println("Added: " + ngram.word);
        println("max value: " + ngram.decade_max_value);
        this.calculateMaxValue();
    }
    public void remove (NGram ngram)
    {
        this.ngrams.remove(ngram.word);
        this.ngramColours.remove(ngram.word);
        this.calculateMaxValue();
    }
    private void calculateMaxValue ()
    {
        Iterator i = this.ngrams.values().iterator();
        float old_max_value = this.max_value;
        this.max_value = 0;
        
        while (i.hasNext()) {
            NGram ngram = (NGram) i.next();
            if (ngram.decade_max_value > this.max_value) {
                this.max_value = ngram.decade_max_value;
                println("New max value: " + this.max_value);
            }
        }
        
        if (this.max_value != old_max_value) {
            this.t.pause();
            this.t = new Tween(this.t.getPosition(), this.max_value, this.tweenDuration);
            this.t.play();
        }
    }
    public void draw ()
    {
        noFill();
        stroke(0, 0, 100);
        strokeWeight(2);
        strokeJoin(MITER);
        strokeCap(SQUARE);
        beginShape();
        vertex(0, 0);
        vertex(0, this.h);
        vertex(this.w, this.h);
        endShape();
        
        strokeWeight(2);
        strokeJoin(ROUND);
        strokeCap(ROUND);
        Iterator i = this.ngrams.values().iterator();
        while (i.hasNext()) {
            NGram ngram = (NGram) i.next();
            stroke((Float) this.ngramColours.get(ngram.word), 100, 50);
            beginShape();
            for (int j = 0; j < ngram.decades.length; j++) {
                vertex(map(j, 0, ngram.decades.length, 0, this.w), map(ngram.decades[j], 0, this.t.getPosition(), this.h, 0));
            }
            endShape();
        }
        println(this.t.getPosition());
    }
}