public class NGram
{
    public String word;
    public Boolean success;
    public int[] raw_values;
    public float[] values;
    
    public NGram (String word, Boolean success, float[] values, int[] raw_values)
    {
        this.word = word;
        this.success = success;
        this.raw_values = raw_values;
        this.values = values;
    }
    public float getValueForYear(int year)
    {
        return this.values[year-1500];
    }
    public int getRawValueForYear(int year)
    {
        return this.raw_values[year-1500];
    }
}