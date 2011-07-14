import java.util.HashMap;

public static class Distribution 
{
    final static float E = 17.40;
    final static float N = 9.78;
    final static float I = 7.55;
    final static float S = 7.27;
    final static float R = 7.00;
    final static float A = 6.51;
    final static float T = 6.15;
    final static float D = 5.08;
    final static float H = 4.76;
    final static float U = 4.35;
    final static float L = 3.44;
    final static float C = 3.06;
    final static float G = 3.01;
    final static float M = 2.53;
    final static float O = 2.51;
    final static float B = 1.89;
    final static float W = 1.89;
    final static float F = 1.66;
    final static float K = 1.21;
    final static float Z = 1.13;
    final static float P = 0.79;
    final static float V = 0.67;
    final static float J = 0.27;
    final static float Y = 0.04;
    final static float X = 0.03;
    final static float Q = 0.02;
    
    static HashMap<String, Float> distribution;
    static boolean ready = false;

    public Distribution () 
    {

    }
    
    final static HashMap<String, Float> getDistribution () {
        if (!ready) {
            distribution = new HashMap<String, Float>();
            distribution.put("E", 17.40);
            distribution.put("N", 9.78);
            //distribution.put("I", 7.55);
            distribution.put("S", 7.27);
            //distribution.put("R", 7.00);
            //distribution.put("A", 6.51);
            //distribution.put("T", 6.15);
            //distribution.put("D", 5.08);
            //distribution.put("H", 4.76);
            //distribution.put("U", 4.35);
            //distribution.put("L", 3.44);
            //distribution.put("C", 3.06);
            //distribution.put("G", 3.01);
            //distribution.put("M", 2.53);
            //distribution.put("O", 2.51);
            //distribution.put("B", 1.89);
            //distribution.put("W", 1.89);
            //distribution.put("F", 1.66);
            //distribution.put("K", 1.21);
            //distribution.put("Z", 1.13);
            //distribution.put("P", 0.79);
            //distribution.put("V", 0.67);
            //distribution.put("J", 0.27);
            //distribution.put("Y", 0.04);
            //distribution.put("X", 0.03);
            //distribution.put("Q", 0.02);
        }
        ready = true;
        return distribution;
    }
    static float getChar (String c) {
        return distribution.get(c);
    }
    static int getCount() {
        return distribution.size();
    }

}