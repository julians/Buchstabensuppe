import java.net.URL;
import java.util.Scanner;

class NGramGetter
{
    String baseURL = "http://julianstahnke.com/fhp/ngram/?word=";
    
    NGramGetter ()
    {
    }
    public NGram getNGram(String word)
    {
        try {
            URL url = new URL(baseURL + word);
            Scanner scanner = new Scanner(url.openStream()).useDelimiter(";");
            String success = scanner.next();
            String return_word = scanner.next();
            Scanner valueScanner = new Scanner(scanner.next()).useDelimiter(",");
            int[] raw_values = new int[509];
            float[] values = new float[509];
            int i = 0;
            while (valueScanner.hasNext()) {
                String j = valueScanner.next();
                println(j);
                String[] v = j.split(":");
                println(v);
                raw_values[i] = Integer.parseInt(v[0]);
                values[i] = Float.valueOf(v[1]).floatValue();
                i++;
            }
            return new NGram(word, success == "1", values, raw_values);
        } catch (MalformedURLException e) {
            return null;
        } catch (IOException e) {
            return null;
        }
    }
}