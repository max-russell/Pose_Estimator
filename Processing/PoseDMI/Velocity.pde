abstract class VelocityType
{
  protected Zone parent;
  
  float sourceRangeLower = 0;
  float sourceRangeUpper = 1.0;
  float targetRangeLower = 0;
  float targetRangeUpper = 1.0;
  
  public float get() {return 1.0;}
  abstract public String getName();
  public float getMin() {return 0;}
  public float getMax() {return 1.0;}
  public float getDefaultLower() {return 0;}
  public float getDefaultUpper() {return 1.0;}  
  
  public void setSourceLower(float v) {sourceRangeLower = max(v, getMin());}
  public void setSourceUpper(float v) {sourceRangeUpper = min(v, getMax());}
  public float getSourceLower() {return sourceRangeLower;}
  public float getSourceUpper() {return sourceRangeUpper;}
  
  public void setTargetLower(float v) {targetRangeLower = max(v, 0);}
  public void setTargetUpper(float v) {targetRangeUpper = min(v, 1);}
  public float getTargetLower() {return targetRangeLower;}
  public float getTargetUpper() {return targetRangeUpper;}
  
  
  public VelocityType(Zone parent)
  {
    this.parent = parent;
    setSourceLower(getDefaultLower());
    setSourceUpper(getDefaultUpper());
  }
}

VelocityType getNewVelocityByName(String name, Zone parent)
{
  switch(name)
  {
    case "Constant": return new ConstantVelocity(parent);
    case "Height": return new HeightVelocity(parent);
    case "Move Speed": return new MoveSpeedVelocity(parent);
    case "Eye Distance": return new EyeDistanceVelocity(parent);
  }
  return null;
}

class ConstantVelocity extends VelocityType
{
  public ConstantVelocity(Zone parent){super(parent);}
  
  public String getName() {return "Constant";}
  
  public float get()
  {
    return getTargetUpper();
  }
}

class HeightVelocity extends VelocityType
{
  public float getDefaultLower() {return 0.1;}
  public float getDefaultUpper() {return 0.9;}

  public HeightVelocity(Zone parent){super(parent);}
  
  public String getName() {return "Height";}
  
  public float get()
  {
    if (parent.triggerPoint == null) return 0;
    
    float v = constrain(parent.triggerPoint.y, getSourceLower(), getSourceUpper());
    return map(v, getSourceLower(), getSourceUpper(), getTargetLower(), getTargetUpper());
  }  
  
}

class MoveSpeedVelocity extends VelocityType
{
  public float getMin() {return 0.0;}
  public float getMax() {return 640.0;}
  public float getDefaultLower() {return 10;}
  public float getDefaultUpper() {return 200;}  
  
  public MoveSpeedVelocity(Zone parent){super(parent);}
  
  public String getName() {return "Move Speed";}
  
  public float get()
  {
    float d = parent.getMoveAmount();
    
    float v = constrain(d, getSourceLower(), getSourceUpper());
    return map(v, getSourceLower(), getSourceUpper(), getTargetLower(), getTargetUpper());    
  } 
}

class EyeDistanceVelocity extends VelocityType
{ 
  public float getMin() {return 1.0;}
  public float getMax() {return 300.0;}
  public float getDefaultLower() {return 10;}
  public float getDefaultUpper() {return 100;}
  
  public EyeDistanceVelocity(Zone parent){super(parent);}
  
  public String getName() {return "Eye Distance";}
  
  public float get()
  {
    PVector leftEye = new PVector(pose.getPoseDataX(15), pose.getPoseDataY(15));
    PVector rightEye = new PVector(pose.getPoseDataX(14), pose.getPoseDataY(14)); 
    
    float d = PVector.dist(leftEye, rightEye);
    
    float v = constrain(d, getSourceLower(), getSourceUpper());
    return map(v, getSourceLower(), getSourceUpper(), getTargetLower(), getTargetUpper());      
  }
}
  
