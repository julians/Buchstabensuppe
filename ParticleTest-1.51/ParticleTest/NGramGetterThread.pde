import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.URL;
import java.util.Scanner;
import com.google.gson.*;

class NGramGetterThread extends Thread
{
    PApplet p;
    String word;
    Method nGramFoundEvent;
    // String baseURL = "http://misc.local/kuppel/?format=json&word=";
    String baseURL = "http://julianstahnke.com/fhp/ngram/?format=json&word=";
    
    NGramGetterThread (PApplet p, String word)
    {
        this.p = p;
        this.word = word;
        
        try {
			this.nGramFoundEvent = p.getClass().getMethod("nGramFound", NGram.class);
		} catch (SecurityException e) {
			System.out.println("security error: ");
			e.printStackTrace();
		} catch (NoSuchMethodException e) {
			System.out.println("no such method: ");
			e.printStackTrace();
		} catch (IllegalArgumentException e) {
			System.out.println("illegal args: ");
			e.printStackTrace();
		}
    }
    public void run()
    {
        if (this.nGramFoundEvent != null) {
            NGram ngram = null;
            try {
                URL url = new URL(baseURL + this.word);
                String r = new Scanner(url.openStream()).useDelimiter(";").next();
                ngram = new Gson().fromJson(r, NGram.class);
                ngram.init();
            } catch (MalformedURLException e) {

            } catch (IOException e) {

            }
            try {
                this.nGramFoundEvent.invoke(this.p, ngram);
            } catch (IllegalArgumentException e) {
    			// TODO Auto-generated catch block
    			e.printStackTrace();
    		} catch (IllegalAccessException e) {
    			// TODO Auto-generated catch block
    			e.printStackTrace();
    		} catch (InvocationTargetException e) {
                // TODO Auto-generated catch block
    			e.printStackTrace();
            }
        }
    }
}