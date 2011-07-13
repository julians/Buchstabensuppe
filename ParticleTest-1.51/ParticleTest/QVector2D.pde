// PVector doesn’t have a rotate method, so I’m subclassing it
// and because I suck at math, I also make it two-dimensional only so
// I won’t have to implement rotation on a z-axis
class QVector2D extends PVector
{
  QVector2D (float x, float y)
  {
    super(x, y, 0);
  }
  
  QVector2D ()
  {
    super();
  }
  
  QVector2D (QVector2D _vector)
  {
    super(_vector.x, _vector.y, 0);
  }
  
  void rotate (float _angle)
  {
    float angle = (float) Math.toRadians(_angle);

    float xNew = cos(angle) * this.x - sin(angle) * this.y;
    float yNew = cos(angle) * this.y + sin(angle) * this.x;

    this.set(xNew, yNew, 0);
  }
  QVector2D rotateChain (float _angle)
    {
      float angle = (float) Math.toRadians(_angle);

      float xNew = cos(angle) * this.x - sin(angle) * this.y;
      float yNew = cos(angle) * this.y + sin(angle) * this.x;

      this.set(xNew, yNew, 0);
      return this;
    }
  
  void set (float x, float y)
  {
    this.set(x, y, 0);
  }
  
  void add (QVector2D v)
  {
      this.x += v.x;
      this.y += v.y;
  }
  
  QVector2D get ()
  {
    return new QVector2D(this.x, this.y);
  }
  
  float angleBetween (QVector2D v)
  {
    return PVector.angleBetween(new PVector(this.x, this.y, 0), new PVector(v.x, v.y, 0));
  }
  
  QVector2D normalVector()
  {
      return new QVector2D(-this.y, this.x);
  }
}