import java.lang.Math.*;
import java.util.Arrays.*;

public class NGram
{
    public String word;
    public Boolean success;
    public int[] raw_values;
    public float[] values;
    public float[] raw_decades;
    public float[] decades;
    public int[] years_in_decade;
    public float decade_max_value;
    public float decade_max_raw_value;
    public float max_value;
    public int max_raw_value;
    public int peak_year;
    public int raw_peak_year;
    public int peak_decade;
    public int raw_peak_decade;
    public int first_occurance = -1;
    
    public NGram (String word, Boolean success, float[] values, int[] raw_values)
    {
        this.word = word;
        this.success = success;
        this.raw_values = raw_values;
        this.values = values;
        this.init();
    }
    public NGram()
    {
        // Konstruktor für GSON.
        // Nachträglich muss noch die init()-Funktion aufgerufen werden.
    }
    public void init()
    {
        // Arrays für Dekaden und wie viele Jahre es in der
        // (möglicherweise unkompletten) Dekade gibt
        // beispielsweise 2001–2008 = 9 Jahre
        this.decades = new float[(int) Math.ceil((float) this.raw_values.length/10f)];
        this.raw_decades = new float[this.decades.length];
        this.years_in_decade = new int[this.decades.length];
        // Alles auf 0 setzen
        java.util.Arrays.fill(this.years_in_decade, 0);
        java.util.Arrays.fill(this.decades, 0);
        java.util.Arrays.fill(this.raw_decades, 0);
        this.max_value = 0;
        this.max_raw_value = 0;
        // Über alle Jahre loopen
        for (int i = 0; i < this.raw_values.length; i++) {
            int decade = (int) Math.ceil((float) (i+1)/10f)-1;
            // +1 Jahr in dieser Dekade
            this.years_in_decade[decade] += 1;
            // Werte zu Dekade hinzuaddieren
            this.decades[decade] += this.values[i];
            this.raw_decades[decade] += this.raw_values[i];
            // Spitzenjahre bestimmen
            if (this.values[i] > this.max_value) {
                this.max_value = this.values[i];
                this.peak_year = i;
            }
            if (this.raw_values[i] > this.max_raw_value) {
                this.max_raw_value = this.raw_values[i];
                this.raw_peak_year = i;
            }
            if (this.first_occurance < 0 && this.raw_values[i] > 0) {
                this.first_occurance = i;
            }
        }
        // Über alle Dekaden loopen
        for (int i = 0; i < this.decades.length; i++) {
            // Wert in der Dekade durch Anzahl der Jahre in der Dekade teilen
            // (Durchschnitt errechnen)
            this.decades[i] /= this.years_in_decade[i];
            this.raw_decades[i] /= this.years_in_decade[i];
            // Spitzendekaden herausfinden
            if (this.decades[i] > this.decade_max_value) {
                this.decade_max_value = this.decades[i];
                this.peak_decade = i;
            }
            if (this.raw_decades[i] > this.decade_max_raw_value) {
                this.decade_max_raw_value = this.raw_decades[i];
                this.raw_peak_decade = i;
            }
        }
    }
    public int getPeakYear()
    {
        return 1500+this.peak_year;
    }
    public int getRawPeakYear()
    {
        return 1500+this.raw_peak_year;
    }
    public int getPeakDecade()
    {
        return 1500+this.peak_decade*10;
    }
    public int getRawPeakDecade()
    {
        return 1500+this.raw_peak_decade*10;
    }
    public float getMaxDecadeValue()
    {
        return this.decade_max_value;
    }
    public float getMaxDecadeRawValue()
    {
        return this.decade_max_raw_value;
    }
    public float getMaxValue()
    {
        return this.max_value;
    }
    public int getMaxRawValue()
    {
        return this.max_raw_value;
    }
    public float getValueForDecade(int decade)
    {
        if (decade < 1500 || (decade-1500)/10 >= this.decades.length) return -1;
        return this.decades[(decade-1500)/10];
    }
    public float getRawValueForDecade(int decade)
    {
        if (decade < 1500 || (decade-1500)/10 >= this.raw_decades.length) return -1;
        return this.raw_decades[(decade-1500)/10];
    }
    public float getValueForYear(int year)
    {
        if (year < 1500 || year-1500 >= this.values.length) return -1;
        return this.values[year-1500];
    }
    public int getRawValueForYear(int year)
    {
        if (year < 1500 || year-1500 >= this.raw_values.length) return -1;
        return this.raw_values[year-1500];
    }
    public int getFirstOccurance() {
        return this.first_occurance+1500;
    }
}