import java.util.Map;
import java.util.HashMap;

class NGramGetter
{
    Jedis r;
    
    NGramGetter ()
    {
        this.r = new Jedis("localhost");
    }
    public Map getNGram(String word)
    {
        // Don’t you just loooooove Java?
        Map mp = r.hgetAll("word:"+word);
        Map hm = new HashMap();
        
        Iterator it = mp.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry pairs = (Map.Entry) it.next();
            // TODO: Mix in totals for the years
            hm.put(Integer.parseInt((String) pairs.getKey()), Integer.parseInt((String) pairs.getValue()));
        }
        return hm;
    }
}