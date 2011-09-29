public class CharCloud extends ParticleSystem
{
    HashMap<String, Word> words;
    PVector target;
    int letterspacing = 0;
    HashMap<String, GLModel> modelCache;
    int mode = CharParticle.OBJMODEL;
    int maxWords = 5;
    Scoreboard scoreboard;
    ArrayList wordsToAdd;
    ArrayList wordsToRemove;
    
    OBJModel model;
    GLModel glmodel;
    
    public CharCloud (PApplet p5, Scoreboard scoreboard, int max) {
        super(p5, max);
        this.scoreboard = scoreboard;
        // this.scoreboard.registerCharCloud(this);
        this.wordsToAdd = new ArrayList();
        this.wordsToRemove = new ArrayList();
        words = new HashMap<String, Word>();
        modelCache = new HashMap<String, GLModel>(26);
        init();
    }
    
    public void addWord (String s) {
        this.wordsToAdd.add(s);
    }
    
    public void _addWord (String s) {
        println(s);
        println(words.size());
        if (words.containsKey(s)) {
            Word word = words.get(s);
            println(s + " exists, bring to front!");
            word.toFront();
            return;
        }
        if (words.size() >= maxWords) {
            Iterator it = words.entrySet().iterator();
            String oldestWord = "";
            float maxZ = 0;
            while (it.hasNext()) 
            {
                Map.Entry pairs = (Map.Entry) it.next();
                Word v = (Word) pairs.getValue();
                String k = (String) pairs.getKey();
                if (v.z > maxZ) {
                    maxZ = v.z;
                    oldestWord = k;
                }
            }
            removeWord(oldestWord);
        }
        CharParticle[] characters = new CharParticle[s.length()];
        for (int i = 0; i < characters.length; i++) {
            characters[i] = getParticleForChar("" + s.charAt(i));
        }

        PVector pos = new PVector(random(width), random(height), random(400, 500));
        PVector vel = new PVector(0, 0, 0);
        Word word = new Word(s, characters, pos, vel);
        word.registerScoreboard(this.scoreboard);
        words.put(s, word);
        addParticle(word).setLifeSpan(-1);
        nGramGetter.getNGram(s);
    }
    public Word getLabel(Scoreboard scoreboard, NGramDisplay ngramDisplay)
    {
        CharParticle[] characters = new CharParticle[ngramDisplay.ngram.word.length()];
        for (int i = 0; i < characters.length; i++) {
            characters[i] = getParticleForChar("" + ngramDisplay.ngram.word.charAt(i));
        }
        Word word = new Word(ngramDisplay.ngram.word, characters, new PVector(0, 0, 0), new PVector(0, 0, 0));
        word.makeLabel(scoreboard, ngramDisplay);
        addParticle(word).setLifeSpan(-1);
        return word;
    }
    public void removeWord (String s) {
        this.wordsToRemove.add(s);
    }
    public void _removeWord (String s) {
        Word word = words.get(s);
        word.dissolve();
        words.remove(s);
        scoreboard.remove(s);
    }
    void updateAndDraw() 
    {
        for (int i = 0; i < particles.size(); i++) {
            Particle p = particles.get(i);
            updateAndDrawParticle(p);
        }
        for (int i = 0; i < forces.size(); i++) {
            ForceField f = forces.get(i);
            if (f.visible) f.draw();
            f.apply();
        }
        
        Iterator it = words.entrySet().iterator();
        while (it.hasNext()) 
        {
            Map.Entry pairs = (Map.Entry) it.next();
            //println(((Word) pairs.getValue()).z);
            if (((Word) pairs.getValue()).z < 100) removeWord((String) pairs.getKey());
        }
        this.cleanUpWords();
    }
    
    void cleanUpWords() {
        if (this.wordsToRemove.size() > 0) {
            for (int i = 0; i < this.wordsToRemove.size(); i++) {
                String s = (String) this.wordsToRemove.get(i);
                this._removeWord(s);
            }
            this.wordsToRemove.clear();
        }
        if (this.wordsToAdd.size() > 0) {
            for (int i = 0; i < this.wordsToAdd.size(); i++) {
                String s = (String) this.wordsToAdd.get(i);
                this._addWord(s);
            }
            this.wordsToAdd.clear();
        }
    }
    
    // public ArrayList<String> getKeys () {}
    // public ArrayList<String> getValues () {}
    
    public void init () 
    {
        // create characters based on their distribution in German language
        int onePercent = getMaxParticles() / 100;
        HashMap<String, Float> d = Distribution.getDistribution();
        Iterator it = d.entrySet().iterator();
        while (it.hasNext()) 
        {
            Map.Entry pairs = (Map.Entry) it.next();

            // todo: Find a better solution for lower and upper case distribution
            String c;
            for (int i = 0; i < 1 + (Float) pairs.getValue() * onePercent; i++) {
                if ((int) random(2) == 0) {
                    c = ((String) pairs.getKey());
                } else {
                    c = (((String) pairs.getKey()).toLowerCase()); 
                }
                CharParticle p;
                switch (mode) {
                    case CharParticle.GEOMERATIVE:
                    p = new CharParticle(p5, c, CharParticle.GEOMERATIVE);   
                    break;
                    case CharParticle.OBJMODEL:
                    GLModel m = getModelForChar(c);
                    p = new CharParticle(p5, c, m);
                    break;    
                    default:
                    p = new CharParticle(p5, c, CharParticle.GEOMERATIVE); 
                    break;
                }
                addParticle(p, random(width), random(height), random(-500, 500)).randomizeVelocity(0.1).setLifeSpan(-1);
                // ForceField attraction = new ForceField(new PVector (0, 0, 0)).setRadius(p.getWidth()).setStrength(-1000);            
                // p.addForceField(attraction);
                // attraction.influence(this.getParticles());
                // p.addBehavior(new BounceOffWalls(1000));
            } 
        }
    }
    public void reactOnRecord () {
    }
    public void reactOnError () { 
    }
    CharParticle getParticleForChar(String c) {
        for (int i = 0; i < particles.size(); i++) {
            if (particles.get(i) instanceof CharParticle) {
                CharParticle p = (CharParticle) particles.get(i);
                if (p.character == c && !p.used) {
                    p.used = true;
                    println("using cached particle");
                    return p;   
                }
            }
        }
        GLModel m = getModelForChar(c);
        CharParticle p = new CharParticle(p5, c, m);
        addParticle(p, random(width), random(height), random(100)).randomizeVelocity(1).setLifeSpan(-1);
        p.used = true;
        return p;
    }
    // returns the cached model for reuse with a new CharParticle
    GLModel getModelForChar(String c) {
        if (c.equals("Ä") || c.equals("ä")) c = "AE";
        if (c.equals("Ü") || c.equals("ü")) c = "UE";
        if (c.equals("Ö") || c.equals("ö")) c = "OE";
        if (c.equals("ß")) c = "SS";
        // I don’t know how to use char as key in a HashMap so I use fake Strings
        if (modelCache.containsKey(c)) {
            return modelCache.get(c);
        } else {
            // creates a new model
            model = new OBJModel(p5, (c).toUpperCase() + ".obj", "relative", TRIANGLES);
            model.enableDebug();

            glmodel = new GLModel(p5, model.getFaceCount() * 3, TRIANGLES, GLModel.DYNAMIC);

            // copy vertices from OBJModel to GLModel
            glmodel.beginUpdateVertices();   
            int index = 0;
            float maxX = 0;
            for (int f = 0; f < model.getFaceCount(); f++) {
              PVector[] fverts = model.getFaceVertices(f);
              for (int v = 0; v < fverts.length; v++) {
                glmodel.updateVertex(index++, fverts[v].x, fverts[v].y, fverts[v].z);
                if (fverts[v].x > maxX) maxX = fverts[v].x;
              }
            }
            glmodel.width = maxX;
            glmodel.endUpdateVertices();
            
            // copy normals from OBJModel to GLModel
            glmodel.initNormals();
            glmodel.beginUpdateNormals();   
            index = 0;
            for (int s = 0; s < model.getSegmentCount(); s++) {
                Segment segment = model.getSegment(s);
                Face[] faces = segment.getFaces();

                for (int i = 0; i < faces.length; i++) {
                    PVector[] vs = faces[i].getVertices();
                    PVector[] ns = faces[i].getNormals();
                
                    for (int k = 0; k < vs.length; k++) {
                        glmodel.updateNormal(index++, ns[k].x, ns[k].y, ns[k].z);
                    }
                }
              
            }
            glmodel.endUpdateNormals();
             
            glmodel.initColors();
            glmodel.setColors(255, 0, 0);
            modelCache.put(c, glmodel);
            return glmodel; 
        }

    }
}