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
            int[] values = new int[509];
            int i = 0;
            while (valueScanner.hasNext()) {
                values[i] = valueScanner.nextInt();
                i++;
            }
            return new NGram(return_word, success == "1", values);
        } catch (MalformedURLException e) {
            return null;
        } catch (IOException e) {
            return null;
        }
    }
}