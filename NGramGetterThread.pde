import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.URL;
import java.util.Scanner;

class NGramGetterThread extends Thread
{
    PApplet p;
    String word;
    Method nGramFoundEvent;
    Gson gson;
    //String baseURL = "http://misc.local/kuppel/?word=";
    String baseURL = "http://julianstahnke.com/fhp/ngram/?word=";
    
    NGramGetterThread (PApplet p, String word)
    {
        this.p = p;
        this.word = word;
        this.gson = new Gson();
        
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
                // Gson
                String r = new Scanner(url.openStream()).useDelimiter(";").next();
                Response response = new Gson().fromJson(r, Response.class);
                // println("response");
                // oldschool
                Scanner scanner = new Scanner(url.openStream()).useDelimiter(";");
                String success = scanner.next();
                String return_word = scanner.next();
                Scanner valueScanner = new Scanner(scanner.next()).useDelimiter(",");
                int[] raw_values = new int[509];
                float[] values = new float[509];
                int i = 0;
                while (valueScanner.hasNext()) {
                    String j = valueScanner.next();
                    String[] v = j.split(":");
                    raw_values[i] = Integer.parseInt(v[0]);
                    values[i] = Float.valueOf(v[1]).floatValue();
                    i++;
                }
                ngram = new NGram(this.word, success == "1", values, raw_values);       
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