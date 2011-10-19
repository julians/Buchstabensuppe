public class Timeline {
    
    float[] values;
    float w = 5;
    float d = 10;
    float h = 5;
    float ax, ay, az, bx, by, bz, cx, cy, cz, dx, dy, dz;
    int bla = 0;

    public Timeline () {
        init();
    }
    void init () {
        values = new float[100];
        float value = 0;

        for (int i = 0; i < values.length; i++) {
            value = noise(value) * 100;
            values[i] = value;
        }
    }
    void draw (GLGraphicsOffScreen canvas) {
        if (bla < values.length - 1 && frameCount % 10 == 0) bla++;
        canvas.noStroke();
        canvas.fill(255);
        canvas.pushMatrix();
            canvas.beginShape(QUADS);
            for (int i = 0; i < bla; i++) {
                // A
                ax = 0;
                ay = values[i];
                az = d * i;
                // B
                bx = w;
                by = values[i];
                bz = d * i;
                // C
                cx = w;
                cy = values[i+1];
                cz = d * (i + 1);
                // D
                dx = 0;
                dy = values[i+1];
                dz = d * (i + 1);

                // Top
                canvas.vertex(ax, ay, az);
                canvas.vertex(bx, by, bz);
                canvas.vertex(cx, cy, cz);
                canvas.vertex(dx, dy, dz);            
                // Bottom
                canvas.vertex(ax, ay - h, az);
                canvas.vertex(bx, by - h, bz);
                canvas.vertex(cx, cy - h, cz);
                canvas.vertex(dx, dy - h, dz);
                // Left
                canvas.vertex(ax, ay, az);
                canvas.vertex(ax, ay - h, az);
                canvas.vertex(dx, dy - h, dz);
                canvas.vertex(dx, dy, dz);          
                // Right
                canvas.vertex(bx, by, bz);
                canvas.vertex(bx, by - h, bz);
                canvas.vertex(cx, cy - h, cz);
                canvas.vertex(cx, cy, cz);  
                // Front
                canvas.vertex(dx, dy, dz);
                canvas.vertex(cx, cy, cz);
                canvas.vertex(cx, cy - h, cz);
                canvas.vertex(dx, dy - h, dz);
                // Back, we will never see?
            }
            canvas.endShape();
        canvas.popMatrix();
    }   
}