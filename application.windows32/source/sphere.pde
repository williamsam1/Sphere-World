
ArrayList<Sphere> world = new ArrayList<Sphere>();

float xi;
float yi;
boolean mousePress;
OctTree q;
int lastMillis;
float currRotX = 0;
float currRotY = PI/2;
float currX = 0;
float currY = 0;
float currZ = 0;
final float rotateSpeed = 0.025*PI;
boolean keyW = false;
boolean keyS = false;
boolean keyA = false;
boolean keyD = false;
boolean keyUp = false;
boolean keyDown = false;
boolean keyLeft = false;
boolean keyRight = false;
boolean keyPgUp = false;
boolean keyPgDn = false;

final float minRadius = 10;
final float maxRadius = 50;
final float grav = 0;
final float maxVel = 0.25;
final float restitution = 0.85;
final float friction = .001;
final float timeStep = 1;
final float solveResolution = 50;
final int maxObjects = 1;
final int maxLevels = 5;
boolean viewLines = true;
boolean viewLights = true;

int frameCount = 0;
int fpsTot = 0;
int lastFps = 0;

final int frameAverage = 10;

int idCount = 0;


void setup()
{
  
  size(600, 400, P3D);
  surface.setResizable(true);
  lastMillis = millis();
  
 }

void draw()
{
  frameCount++;
  
  updateMatrix(); 
  background(0);
  
  fpsTot += 1000/(millis() - lastMillis);
  lastMillis = millis();
  
  if (frameCount >= frameAverage)
  {
    lastFps = (int)(fpsTot/frameCount);
    frameCount = 0;
    fpsTot = 0;
  }
  
  fill(255, 0, 0);
  textSize(20);
  text(lastFps, 20, 20);

  
   q = new OctTree((float)(width/2), (float)(height/2), (float)(width/2), (float)width, (float)height, (float)width, maxObjects, maxLevels); 
  for (Sphere b : world)
  {
   q.insert(b); 
  }
  if (viewLines)
  q.draw();
  
  for (Sphere b : world)
  {
   b.update();
  }
  
  for (Sphere b : world)
  {
   b.resolveCollisions();
   b.draw();
  }
  
  if (mousePress)
  {
    pushMatrix();
    translate(currX, currY, currZ);
    rotateX(currRotX);
    rotateY(currRotY);
    stroke(255, 0, 0);
    line(xi, yi, xi, mouseX, mouseY, mouseX);
    popMatrix();
  }
}

void updateMatrix()
{
  float moveSpeedX = width/10;
  float moveSpeedY = height/10;
  float moveSpeedZ = moveSpeedX;

  if (keyRight)
   currRotY += rotateSpeed;
  if (keyLeft)
   currRotY -= rotateSpeed;
  if (keyUp)
   currRotX += rotateSpeed;
  if (keyDown)
   currRotX -= rotateSpeed;
   if (keyW)
    currZ += moveSpeedZ;
    if (keyS)
    currZ -= moveSpeedZ;
    if (keyA)
    currX += moveSpeedX;
    if (keyD)
    currX -= moveSpeedX;
    if (keyPgUp)
     currY += moveSpeedY;
     if (keyPgDn)
      currY -= moveSpeedY; 
}

void mousePressed() 
{
  if (mouseButton == LEFT)
  {
 xi = mouseX;
 yi = mouseY;
 mousePress = true;
  }
}

void mouseReleased()
{
  if (mouseButton == LEFT)
  {
 mousePress = false;
 float r = (float)(minRadius + Math.random()*(maxRadius - minRadius));
 Sphere b = new Sphere(new MyVector3(xi, yi, xi), new MyVector3(maxVel*(xi-mouseX), maxVel*(yi-mouseY), maxVel*(xi-mouseX)), new MyVector3(0, grav, 0), r, color((int)(Math.random()*255+1), (int)(Math.random()*255+1), (int)(Math.random()*255+1)), (float)Math.pow(r, 3));
 q.insert(b);
 if (!b.isCollidingAtAll())
  world.add(b);
 else
  b.q.objects.remove(b.q.objects.size()-1);
  }
  else if (mouseButton == RIGHT)
{
  viewLines = !viewLines;
}
}

void keyPressed()
{
  if (key == CODED)
  {
  if (keyCode == RIGHT)
   keyRight = true;
  else if (keyCode == LEFT)
   keyLeft = true;
  else if (keyCode == UP)
  keyUp = true;
  else if (keyCode == DOWN)
   keyDown = true;
  else if (keyCode == 34)
   keyPgDn = true;
   else if (keyCode == 33)
   keyPgUp = true;
  }
  else 
  {
   if (key == 'w')
    keyW = true;
    else if (key == 's')
    keyS = true;
    else if (key == 'a')
    keyA = true;
    else if (key == 'd')
    keyD = true;
  }
}

void keyReleased()
{
  if (key == CODED)
  {
  if (keyCode == RIGHT)
   keyRight = false;
  else if (keyCode == LEFT)
   keyLeft = false;
  else if (keyCode == UP)
  keyUp = false;
  else if (keyCode == DOWN)
   keyDown = false;
  else if (keyCode == 34)
   keyPgDn = false;
   else if (keyCode == 33)
   keyPgUp = false;
  }
  else 
  {
   if (key == 'w')
    keyW = false;
    else if (key == 's')
    keyS = false;
    else if (key == 'a')
    keyA = false;
    else if (key == 'd')
    keyD = false;
  }
}
  
  


public interface Sizeable3
{
 public float width();
 public float height();
 public float depth();
 public float x();
 public float y();
 public float z();
}



public abstract class OctObject implements Sizeable3
{
  public OctTree q;
  
  public abstract void run();
  
  public void setOctTree(OctTree qn)
  {
    q = qn;
  } 

  public void removeFromOctTree()
  {
    if (q != null)
    {
      q.objects.remove(this);
    }
  }
}



public class Sphere extends OctObject
{
  MyVector3 pos;
  MyVector3 vel;
  MyVector3 a;
  color col;
  float r;
  float mass;
  int id;

  
 Sphere(MyVector3 pos0, MyVector3 vel0, MyVector3 a0, float rad, color c, float m)
 {
   pos = pos0;
   vel = vel0;
   a = a0;
   r = rad;
   col = c;
   mass = m;
   id = idCount;
   idCount++;
 }
 
 public void setPos(MyVector3 pos)
 {
  this.pos = pos; 
 }
 
 public void setVel(MyVector3 vel)
 {
  this.vel = vel; 
 }
 
 
 public void run()
 {
   update();
   synchronized(this)
   {
   notify();
   }
 }
 
 
 public boolean equals(Sphere s)
 {
   return (id == s.id);
 }
 
 public float width() {
    return r;
  }

  public float height() {
    return r;
  }
  
  public float depth() {
    return r;
  }

  public float x() 
  {
    return getPos().x;
  }

  public float y()
  {
    return getPos().y;
  }
  
  public float z()
  {
    return getPos().z;
  }
 
public synchronized MyVector3 getPos()
{
 return pos;
} 

public synchronized MyVector3 getVel()
{
 return vel; 
}
 
 void update()
 {
 setVel(getVel().mult(-1*friction).add(a).mult(timeStep).add(getVel()));
 setPos(getVel().mult(timeStep).add(getPos()));
 resolveWalls();  
 }
 
 private void resolveWalls()
 {
  if (getPos().x + r > width)
 {
   getPos().x = width - r;
   getVel().x *= (-1*restitution);
 }
 
 else if (getPos().x - r < 0)
 {
   getPos().x = r;
   getVel().x *= (-1*restitution);
 }
 
 if (getPos().y + r > height)
 {
   getPos().y = height - r;
   getVel().y *= (-1*restitution);
 }
 
 else if (getPos().y - r < 0)
 {
  getPos().y = r;
 getVel().y *= (-1*restitution); 
 } 
 
 if (getPos().z + r > width)
 {
   getPos().z = width - r;
   getVel().z *= (-1*restitution);
 }
 
 else if (getPos().z - r < 0)
 {
   getPos().z = r;
   getVel().z *= (-1*restitution); 
 }
 
 }
 
 void draw()
 {
   fill(col);
   noStroke();
   pushMatrix();
   translate(currX, currY, currZ);
   rotateX(currRotX);
   rotateY(currRotY);
   translate(getPos().x, getPos().y, getPos().z);
   if (viewLights)
   lights();
   sphere(r);
   popMatrix();
   if (viewLines)
   {
   pushMatrix();
   translate(currX, currY, currZ);
   rotateX(currRotX);
   rotateY(currRotY);
   stroke(0, 255, 0);
   line(getPos().x, getPos().y, getPos().z, q.x, q.y, q.z);
   popMatrix();
   }
   
 }
 
 
 boolean isColliding(Sphere ball)
 {
   return (getPos().dist(ball.getPos()) <= r + ball.r);
 }
 
 private void resolveCollision(Sphere ball)
 {
  resolvePosition(ball);
  resolveVelocity(ball);
 }
 
 private void resolvePosition(Sphere ball)
 {
    float a = getVel().dot(vel) + ball.getVel().dot(ball.getVel()) - 2*ball.getVel().dot(vel);
    float b = -2*getPos().dot(vel) - 2*ball.getPos().dot(ball.getVel()) + 2*getPos().dot(ball.getVel()) + 2*ball.getPos().dot(vel);
    float c = getPos().dot(pos) + ball.getPos().dot(ball.getPos()) - 2*ball.getPos().dot(pos) - (r + ball.r)*(r + ball.r);
    float t = (float)(-b+Math.sqrt(b*b-4*a*c))/(2*a);
    
    setPos(getPos().sub(getVel().mult(t)));
    ball.setPos(ball.getPos().sub(ball.getVel().mult(t)));
 }
 
  
  private void resolveVelocity(Sphere ball)
 {
   MyVector3 n = ball.getPos().sub(pos).norm();
   MyVector3 un = n.norm();
   MyVector3 t = new MyVector3(0, -1*un.z, un.y);
   MyVector3 ut = t.norm();
   
   float v1n = un.dot(vel);
   float v1tp = ut.dot(vel);
   float v2n = un.dot(ball.getVel());
   float v2tp = ut.dot(ball.getVel());
   
   float combMass = mass + ball.mass;
   float v1np = (v1n*(mass - ball.mass)+2*ball.mass*v2n)/(combMass);
   float v2np = (v2n*(ball.mass - mass)+2*mass*v1n)/(combMass);
   
   MyVector3 v1npvec = un.mult(v1np);
   MyVector3 v1tpvec = ut.mult(v1tp);
   MyVector3 v2npvec = un.mult(v2np);
   MyVector3 v2tpvec = ut.mult(v2tp);
   
   setVel(v1npvec.add(v1tpvec));
   ball.setVel(v2npvec.add(v2tpvec));
 }

 
 public void resolveCollisions()
 {
  for (OctObject b : q.retrieve())
   {
     Sphere c = (Sphere)b;
     if (!equals(c))
     {
    if (isColliding(c))
    {
    resolveCollision(c);
    }
     }
   } 
 }
 
 public boolean isCollidingAtAll()
 {
   for (OctObject b : q.retrieve())
   {
     Sphere c = (Sphere)b;
    if (isColliding(c) && !equals(c))
    {
     return true;
    }
   }
   return false;
 }
      
}

public class MyVector3
{
  float x;
  float y;
  float z;
  
  public MyVector3(float a, float b, float c)
  {
    x = a;
    y = b;
    z = c;
  }
 
  public MyVector3 add(float a, float b, float c)
  {
   return new MyVector3(x+a, y+b, z+c);
  }
  
  public MyVector3 add(float a)
  {
   return new MyVector3(x+a, y+a, z+a); 
  }
  
  public MyVector3 add(MyVector3 v)
  {
   return new MyVector3(x+v.x, y+v.y, z+v.z);
  }
  
  public MyVector3 sub(float a, float b, float c)
  {
   return new MyVector3(x-a, y-b, z-c);
  }
  
  public MyVector3 sub(float a)
  {
   return new MyVector3(x-a, y-a, z-a); 
  }
  
  public MyVector3 sub(MyVector3 v)
  {
   return new MyVector3(x-v.x, y-v.y, z-v.z);
  }
  
 
  public MyVector3 mult(float a)
  {
   return new MyVector3(a*x, a*y, a*z); 
  }
  
  public MyVector3 div(float a)
  {
   return new MyVector3(x/a, y/a, z/a); 
  }
  
  public float dot(float a, float b, float c)
  {
   return (x*a + y*b + z*c); 
  }
  
  public float dot(MyVector3 v)
  {
   return (x*v.x + y*v.y + z*v.z);
  }
  
  public MyVector3 cross(float a, float b, float c)
  {
    return new MyVector3(y*c - z*b, z*a - x*c, x*b - y*a);
  }
  
  public MyVector3 cross(MyVector3 v)
  {
   return new MyVector3(y*v.z - z*v.y, z*v.x - x*v.z, x*v.y - y*v.x); 
  }
  
  public float mag()
  {
   return (float)(Math.sqrt(x*x+y*y+z*z)); 
  }
  
  public float dist(MyVector3 v)
  {
    MyVector3 a = sub(v);
    return (float)(Math.sqrt(a.x*a.x+a.y*a.y+a.z*a.z));
  }
  
  public float dist(float a, float b, float c)
  {
   return dist(new MyVector3(a, b, c)); 
  }
  
  public MyVector3 norm()
  {
   return div(mag()); 
  }
  
  //Scalar projection of this onto vector v
  public float scalProj(MyVector3 v)
  {
   return  dot(v.norm());
  }
  
  //Vector projection of this onto vector v
  public MyVector3 vectProj(MyVector3 v)
  {
    return v.norm().mult(scalProj(v));
  }
}



public class OctTree
{
  public int maxObjects;
  public int maxLevels;
  public float x;
  public float y;
  public float z;
  public float w;
  public float h;
  public float d;
  public int level;
  public ArrayList<OctObject> objects;
  public OctTree[] child;
  public OctTree parent;
  
  public OctTree (float nx, float ny, float nz, float nw, float nh, float nd, int maxo, int maxl)
  {
  x = nx;
  y = ny;
  z = nz;
  w = nw;
  h = nh;
  d = nd;
  maxObjects = maxo;
  maxLevels = maxl;
  level = 0;
  objects = new ArrayList<OctObject>();
  child = new OctTree[8];
  }
  
  public OctTree (OctTree par, int octant)
  {
    w = par.w/2;
    h = par.h/2;
    d = par.d/2;
    float mx = w/2;
    float my = h/2;
    float mz = d/2;
    
 
    
    switch (octant)
    {
      case 2: 
        mx *= -1;
      case 3:
        mx *= -1;
        my *= -1; 
      case 4:
        my *= -1;
      case 5:
        mz *= -1;
      case 6:
        mx *= -1;
        mz *= -1; 
      case 7: 
        mx *= -1;
        my *= -1;
        mz *= -1;  
      case 8:
        my *= -1;
        mz *= -1; 
    }
     
    x = par.x + mx;
    y = par.y + my;
    z = par.z + mz;
    
    level = par.level + 1;
    maxObjects = par.maxObjects;
    maxLevels = par.maxLevels;
    objects = new ArrayList<OctObject>();
    parent = par;
    child = new OctTree[8];
  }
  
  public void clear()
  {
    objects.clear();
    
   if (child[0] != null)
   {
    for (int i = 0; i < 8; i++)
    {
    child[i].clear();
    }
   }
  }
  
  public void split()
  {
    for (int i = 0; i < 8; i++)
    {
     child[i] = new OctTree(this, i+1); 
    }
  }
  
  public int getIndex(OctObject obj) 
  {
    float wd = w/2;
    float hd = h/2;
    float dd = d/2;
   boolean right = obj.x() + obj.width()/2 <= x + wd && obj.x() - obj.width() >= x;
   boolean left = obj.x() - obj.width()/2 >= x - wd && obj.x() + obj.width() <= x;
   boolean top  = obj.y() + obj.height()/2 <= y + hd && obj.y() - obj.height() >= y;
   boolean bottom  = obj.y() - obj.height()/2 >= y - hd && obj.y() + obj.height() <= y;
   boolean front  = obj.z() + obj.depth()/2 <= z + dd && obj.z() - obj.depth() >= z;
   boolean back = obj.z() - obj.depth()/2 >= z - dd && obj.z() + obj.depth() <= z;
   
   if (right)
   {
     if (top)
       {
        if (front)
         return 1;
        else if (back)
         return 5; 
       }
     else if (bottom)
     {
      if (front)
        return 4;
       else if (back)
         return 8;
     }
   }
   else if (left)
   {
    if (top)
       {
        if (front)
         return 2;
        else if (back)
         return 6; 
       }
     else if (bottom)
     {
      if (front)
        return 3;
       else if (back)
         return 7;
     } 
   }
   return -1;
   }
   
  public void insert(OctObject obj) 
  {
   if (child[0] != null) 
   {
     int index = getIndex(obj);
 
     if (index != -1) 
     {
       child[index - 1].insert(obj);
       return;
     }
   }
     else if (level != 0)
     {
      obj.setOctTree(this.parent);
       this.parent.objects.add(obj); 
     }
     else
     {
       obj.setOctTree(this);
       this.objects.add(obj);
     }
     {
       
     }

 
   obj.setOctTree(this);
   objects.add(obj);
 
   if (objects.size() > maxObjects && level < maxLevels) {
      if (child[0] == null) { 
         split(); 
      }
 
     int i = 0;
     while (i < objects.size()) 
     {
       int index = getIndex(objects.get(i));
       if (index != -1) 
       {
         child[index - 1].insert(objects.remove(i));
       }
       else {
         i++;
       }
     }
   }
 }
  
  public ArrayList<OctObject> retrieve()
  {
   ArrayList<OctObject> ret = new ArrayList<OctObject>(objects);
   if (level != 0)
    ret.addAll(parent.retrieve());
    return ret;
 }
  
  public void draw()
  {
    noFill();
    stroke(0, 0, 255);
    pushMatrix();
    translate(currX, currY, currZ);
    rotateX(currRotX);
    rotateY(currRotY);
    translate(x, y, z);
    box(w, h, d);
    popMatrix();
   if (child[0] != null)
  {
   for (int i = 0; i < 8; i++)
   {
    child[i].draw(); 
   }
  } 
  } 
}