public class NGram
{
    public String word;
    public Boolean success;
    public int[] values;
    
    public NGram (String word, Boolean success, int[] values)
    {
        this.word = word;
        this.success = success;
        this.values = values;
    }
    public int getValueForYear(int year)
    {
        return this.values[year-1500];
    }
}