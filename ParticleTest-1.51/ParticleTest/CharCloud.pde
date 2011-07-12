public class CharCloud extends ParticleSystem
{
    HashMap<String, Word> words;
    PVector target;
    int letterspacing = 0;
    HashMap<String, GLModel> modelCache;
    int mode = CharParticle.OBJMODEL;
    
    OBJModel model;
    GLModel glmodel;
    
    public CharCloud (PApplet p5) {
        this(p5, -1);
    }
    
    public CharCloud (PApplet p5, int max) {
        super(p5, max);
        words = new HashMap<String, Word>();
        modelCache = new HashMap<String, GLModel>(26);
        init();
    }
    
    public void addWord (String s) {}
    public void removeWord (String s) {} // auflösen oder so
    
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
            char c;
            for (int i = 0; i < 1 + (Float) pairs.getValue() * onePercent; i++) {
                if ((int) random(2) == 0) {
                    c = ((String) pairs.getKey()).charAt(0);
                } else {
                    c = (((String) pairs.getKey()).toLowerCase()).charAt(0); 
                }
                GLModel m = getModelForChar(c);
                CharParticle p = new CharParticle(p5, c, m);

                addParticle(p, random(width), random(height), random(-500, 1000)).randomizeVelocity(0.1).setLifeSpan(-1);
                ForceField attraction = new ForceField(new PVector (0, 0, 0)).setRadius(p.width).setStrength(-10);            
                p.addForceField(attraction);
                attraction.influence(this.getParticles());
                p.addBehavior(new BounceOffWalls(1000));
            } 
        }
    }
    
    public void formWord (String word, PVector pos) {
        println(word);
        target = pos;
        PVector displace = new PVector(0, 0, 0);
        for (int i = 0; i < word.length(); i++) {
            char c = word.charAt(i);
            CharParticle p = getParticleForChar(c);
            p.tweenTo(PVector.add(pos, displace));
            displace.add(new PVector(p.width + letterspacing, 0, 0));
            p.disableForces();
            p.resetRotation();
            p.slowSpin.seek(0);
            
        }
        stopFXSpin();
    }
    public void reactOnRecord () {
        for (int i = 0; i < particles.size(); i++) {
            if (particles.get(i) instanceof CharParticle) {
                CharParticle p = (CharParticle) particles.get(i);
                if (!p.used) {
                    p.startFXSpin(); 
                }
            }
        }
    }
    public void reactOnError () {
        stopFXSpin();
    }
    public void stopFXSpin () {
        for (int i = 0; i < particles.size(); i++) {
            if (particles.get(i) instanceof CharParticle) {
                CharParticle p = (CharParticle) particles.get(i);
                if (!p.used) {
                    p.stopFXSpin(); 
                }
            }
        }
    }

    CharParticle getParticleForChar(char c) {
        for (int i = 0; i < particles.size(); i++) {
            if (particles.get(i) instanceof CharParticle) {
                CharParticle p = (CharParticle) particles.get(i);
                if (p.character == c && !p.used) {
                    p.used = true;
                    return p;   
                }
            }
        }
        GLModel m = getModelForChar(c);
        CharParticle p = new CharParticle(p5, c, m);
        addParticle(p, random(width), random(height), target.z + random(100)).randomizeVelocity(1).setLifeSpan(-1);
        p.used = true;
        return p;
    }
    // returns the cached model for reuse with a new CharParticle
    GLModel getModelForChar(char c) {
        if (modelCache.containsKey("" + c)) {
            return modelCache.get("" + c);
        } else {
            // creates a new model
            model = new OBJModel(p5, ("" + c).toUpperCase() + ".obj", "relative", TRIANGLES);
            model.enableDebug();

            glmodel = new GLModel(p5, model.getFaceCount() * 3, TRIANGLES, GLModel.DYNAMIC);

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
            
            // glmodel.beginUpdateNormals();   
            // index = 0;
            // for (int f = 0; f < model.getFaceCount(); f++) {
            //   for (int v = 0; v < model.getIndexCountInSegment(f); v++) {
            //     PVector[] normal = model.getNormalIndicesInSegment(f, v);  
            //     glmodel.updateNormal(index++, normal.x, normal.y, normal.z);
            //   }
            // }
            // glmodel.endUpdateNormals();
            
            
            glmodel.initColors();
            glmodel.setColors(255);
            modelCache.put("" + c, glmodel);
            return glmodel; 
        }

    }
}