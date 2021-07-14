class ControlZone extends Zone
{
  float timeRemaining = 0;
  float glowTime = 300;
  String displayText = "";
  
  public ControlZone()
  {
    super();
    super.name = getUniqueZoneName("Control Zone");
    updateDisplayName();
  }
  
  //OVERRIDE
  public void setChordAndKey(int key, Chord chord)
  {
    super.setChordAndKey(key, chord);
    updateDisplayName();
  }
  
  //OVERRRIDE
  protected void trigger(PVector p1, PVector p2)
  {
    if (PVector.dist(p1, new PVector(0.5,0.5)) < 0.5 && PVector.dist(p2, new PVector(0.5,0.5)) >= 0.5)
    {
        timeRemaining = glowTime;
      
        for(Zone z: zones)
        {
          if (z instanceof StringZone)
          {
            z.setChordAndKey(key, chord);
          }
        }
    }
  }
  
  //OVERRIDE
  public void drawInternal()
  {    
    fill(0,0,255,(timeRemaining / glowTime)*255);
    ellipse(0,0,width, height);
    
    if (timeRemaining > 0)
    {
      timeRemaining = max(0,timeRemaining - millisecondsElapsed);
    }
    
    //The text should not de drawn rotated, so transform back to screen orientation
    pushMatrix();
    translate(width/2, height/2);
    rotate(-getRotation());
    fill(255);
    textSize(50);
    textAlign(CENTER, CENTER);
    text(displayText, 0,0);
    popMatrix();
  }
  
  public void updateDisplayName()
  {
    displayText = keyNumToString(key) + chord.shortName;
  }
  
  public ControlZone(JSONObject z)
  {
    super(z);
    updateDisplayName();
  }
}
