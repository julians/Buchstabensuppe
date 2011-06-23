import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.URL;
import java.util.Scanner;

class NGramGetterThread extends Thread
{
    PApplet p;
    String word;
    Method nGramFoundEvent;
    String baseURL = "http://julianstahnke.com/fhp/ngram/?word=";
    
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
                Scanner scanner = new Scanner(url.openStream()).useDelimiter(";");
                String success = scanner.next();
                String return_word = scanner.next();
                Scanner valueScanner = new Scanner(scanner.next()).useDelimiter(",");
                int[] values = new int[509];
                int i = 0;
                while (valueScanner.hasNext()) {
                    values[i] = valueScanner.nextInt();
                    i++;
                }
                ngram = new NGram(this.word, success == "1", values);       
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