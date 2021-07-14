abstract class Zone
{
  //Constants
  private final int minimumSize = 50;
  private final int resizeTriangleSize = 20;
  
  private String name;
  
  private int x = 200;
  private int y = 140;
  private float angle = radians(0);
  protected int width = 300;
  protected int height = 300;
  private boolean enabled = true;
  protected int triggerKeypoint = 0;
  
  private PMatrix2D zoneToScreenMatrix;
  private PMatrix2D screenToZoneMatrix;
  protected int key = 0;
  protected Chord chord;
  
  private PVector triggerPoint;
  private PVector lastTriggerPoint;
  private PVector triggerPointScr;
  private PVector lastTriggerPointScr;
  
  private boolean newPoseDataReady = false;
  
  public Zone()
  { 
    key = 2;
    chord = chordList[0];
    setPosition(200,140,300,300);
    setRotation(0);
  }
  
  public String getName() {return name;}
  public PVector getPosition() {return new PVector(x,y);}
  public PVector getSize() {return new PVector(width, height);}
  public float getRotation() { return angle;}
  public int getTriggerKeyPoint(){return triggerKeypoint;}
  public void setTriggerKeyPoint(int v){triggerKeypoint = v;}
  public boolean getEnabled(){return enabled;}
  public void setEnabled(boolean e){enabled = e;}
  public int getKey(){return key;}
  public Chord getChord() {return chord;}  
  
  public void setChordAndKey(int key, Chord chord)
  {
    this.key = key;
    this.chord = chord;
  }
  
  public void setPosition(int x, int y, int w, int h)
  {
    this.x = x;
    this.y = y;
    this.width = w;
    this.height = h;
    //updateSpacing();
    updateMatrices();
  }
  
  public void setPosition(int x, int y)
  {
    this.x = x;
    this.y = y;
    updateMatrices();
  }
  
  public void resizeToMouse(PVector m)
  {    
    PVector newsize = screenToZone(m);
    newsize.x = max(minimumSize, newsize.x * width);
    newsize.y = max(minimumSize, newsize.y * height);
    setPosition(x, y, int(newsize.x), int(newsize.y));
  }
  
  public float getMoveAmount()
  {
    if (triggerPointScr == null || lastTriggerPointScr==null) return 0;
    return PVector.dist(triggerPointScr, lastTriggerPointScr);
  }
  
  public PVector screenToZone(PVector v)
  {
    return screenToZoneMatrix.mult(v, null);
  }
  
  public boolean screenPointInside(PVector v)
  {
    PVector p = screenToZoneMatrix.mult(v, null);
    return p.x >= 0 && p.y >= 0 && p.x < 1.0 && p.y < 1.0;
  }
  public boolean screenPointOnResizeTriangle(PVector v)
  {
    PVector p = screenToZoneMatrix.mult(v, null);
    return p.x >= 1.0 - ((float)resizeTriangleSize / width) 
        && p.y >= 1.0 - ((float)resizeTriangleSize / height) 
        && p.x < 1.0 && p.y < 1.0;
  }  
  
  public void setRotation(float a)
  {
    this.angle = a;
    updateMatrices();
  }
  
  //Interact contains the code common to all zones, this in turns calls the 'trigger' method, which is overidden by both child classes in
  //order to implement their unique behaviour.
  
  public void interact(PoseEstimator p)
  {
    if (!getEnabled()) return;
    newPoseDataReady = true;
    
    int nx = p.getPoseDataX(triggerKeypoint);
    int ny = p.getPoseDataY(triggerKeypoint);
    
    float confidence = p.getConfidence(triggerKeypoint);
    
    lastTriggerPointScr = triggerPointScr;
    
    if (confidence > confidenceThreshold)
    {
      triggerPointScr = new PVector(nx, ny);
      triggerPoint = screenToZone(triggerPointScr);
    }
    else
    {
      if (lastTriggerPoint != null)
      {
        triggerPointScr = lastTriggerPointScr.copy();
        triggerPoint = lastTriggerPoint.copy();
      }
    }
    
    if (lastTriggerPoint != null) trigger(triggerPoint, lastTriggerPoint);
    
    lastTriggerPoint = triggerPoint;
  }
  
  abstract protected void trigger(PVector p1, PVector p2);
  
  private void updateMatrices()
  {
    //Apply this transformation when you want to draw the zone to the main screen.
    //Draw subscreen at 0,0 to subScreenWidth,subScreenHeight
    //We don't normalise it because we want strokeWeight to remain in screenPixels.
    zoneToScreenMatrix = new PMatrix2D();
    zoneToScreenMatrix.translate(x,y);
    zoneToScreenMatrix.rotate(angle);
    
    //Apply this transformation to a coordinate on the display screen to get its normalised position in the subscreen
    screenToZoneMatrix = new PMatrix2D();
    screenToZoneMatrix.scale(float(screenWidth) / width, float(screenHeight) / height);
    screenToZoneMatrix.scale(1.0 / screenWidth, 1.0 / screenHeight);
    screenToZoneMatrix.rotate(-angle);
    screenToZoneMatrix.translate(-x,-y);  
  }
  
  public final void draw()
  {
    pushMatrix();
    //Draw the zone
    applyMatrix(zoneToScreenMatrix);
    strokeWeight(3);
    stroke(255,selected == this ? 255: 0,0);
    noFill();
    
    //drawInternal is overridden by the concrete child classes to implement their unique behaviour.
    drawInternal();
    
    drawResizeRectangle();
    popMatrix();
    
    if (newPoseDataReady)
    {  
      if (showHeatMap && selected == this)
      {
        drawHeatMap();
        drawConfidenceBar();
        drawVelocityBar();
        drawKeypoint();
      }
    }
    newPoseDataReady = false;
  }
  
  void drawHeatMap()
  {  
    double maxval=0;
    int w = inputSource.getWidth() >> 3;
    int h = inputSource.getHeight() >> 3;
    
    for(int y = 0; y < h; y++)
    {
      for(int x = 0; x < w; x++)
      {
        float v = pose.getHeatmap(triggerKeypoint, x, y);
        if (v > maxval) maxval=v;
      }
    }
    
    noStroke();
    for(int y = 0; y < h; y++)
    {
      for(int x = 0; x < w; x++)
      {
        int xp = x << 3;
        int yp = y << 3;
        double v = pose.getHeatmap(triggerKeypoint, x, y) / maxval;
        
        fill(0,(float)(v * 255), 0, (float)(v * 200));
        rect(xp,yp,8,8);   
      }
    }
  }
  
  void drawKeypoint()
  {
      int nx = pose.getPoseDataX(triggerKeypoint);
      int ny = pose.getPoseDataY(triggerKeypoint);     
      strokeWeight(5);
      stroke(255,0,0);
      point(nx,ny); 
  }
  
  void drawConfidenceBar()
  {
      try{
    
        float c = pose.getConfidence(triggerKeypoint);
        
        int bh = (int)(c * screenHeight);
        if (c > confidenceThreshold) fill(0,255,255); else fill(0,0,255);
        rect(screenWidth - 5, screenHeight - bh, 5, bh);
        
      }
      catch (IndexOutOfBoundsException x)
      {}
  }
  
  void drawVelocityBar() {}
    
  abstract protected void drawInternal();
  
  private void drawResizeRectangle()
  {
    if (selected == this)
    {
      noStroke();
      fill(255,255,0);
      triangle(width, height - resizeTriangleSize,
               width, height, 
               width - resizeTriangleSize, height);
    }
  }
  
  public JSONObject getJSON()
  {  
    JSONObject z = new JSONObject();
    z.setInt("type", this instanceof StringZone ? 0 : 1);
    z.setString("name", name);
    z.setInt("x", x);
    z.setInt("y", y);
    z.setInt("width", width);
    z.setInt("height", height);
    z.setFloat("angle", angle);
    
    z.setInt("keypoint", triggerKeypoint);
    z.setInt("enabled", enabled ? 1 : 0);
    z.setString("chord", chord.name);
    z.setInt("key", key);
    return z;
  }
  
  public Zone(JSONObject z)
  {
    name = z.getString("name");
    angle = z.getFloat("angle");
    setPosition(z.getInt("x"), z.getInt("y"), z.getInt("width"), z.getInt("height"));
    triggerKeypoint = z.getInt("keypoint");
    enabled = z.getInt("enabled") == 1 ? true : false;
    
    String cname = z.getString("chord");
    setChordAndKey(z.getInt("key"), getChordByName(cname));
  }
  
  public String getUniqueZoneName(String m)
  {
    int n = 1;
    boolean freename = false;
    while(!freename)
    {
      freename = true;
      for(Zone z : zones)
      {
        if (z.name.equals(m + " " + n)) {freename = false; n++; break;}
      }   
    }
    return m + " " + n;
  }
  
}
