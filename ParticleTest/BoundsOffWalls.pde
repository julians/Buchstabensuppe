class BoundsOffWalls extends Behavior 
{
    float bz;
    
    BoundsOffWalls (float bz)
    {
        super();
        this.bz = bz;
    }
    void apply (Particle p) {
        // bounce of edges left and right
        if (p.position.x < 0 + p.size) {
            p.position.x = 0 + p.size;
            p.velocity.x *= -1;
        }
        else if (p.position.x > width - p.size) {
            p.position.x = width - p.size;
            p.velocity.x *= -1;
        }
        // top and bottom
        if (p.position.y < 0 + p.size) {
            p.position.y = 0 + p.size;
            p.velocity.y *= -1;
        }
        else if (p.position.y > height - p.size) {
            p.position.y = height - p.size;
            p.velocity.y *= -1;
        }
        // front and back
        if (p.position.z < -bz) {
            p.position.z = -bz;
            p.velocity.z *= -1;
        }
        else if (p.position.z > bz) {
            p.position.z = bz;
            p.velocity.z *= -1;
        }
    }
}