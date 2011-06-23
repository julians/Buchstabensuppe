import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

class ThreadedNGramGetter extends Thread
{
    PApplet p;
    String word;
    Method nGramFoundEvent;
    
    ThreadedNGramGetter (PApplet p, String word)
    {
        this.p = p;
        this.word = word;
        
        try {
			this.nGramFoundEvent = p.getClass().getMethod("nGramFound", String.class);
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
        try {
            sleep(1000);
        }
        catch(InterruptedException e) {
        }
        if (this.nGramFoundEvent != null) {
            try {
                this.nGramFoundEvent.invoke(this.p, this.word);
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