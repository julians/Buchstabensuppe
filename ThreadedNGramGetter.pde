class ThreadedNGramGetter
{
    PApplet p;
    
    ThreadedNGramGetter (PApplet p)
    {
        this.p = p;
    }
    public void getNGram(String word)
    {
        NGramGetterThread thread = new NGramGetterThread(this.p, word);
        thread.start();
    }
}