//Each note on the String Zone has its own object.

class Note
{
  float position;
  StringZone parentZone;
  float timeRemaining = 0;
  int pitch;
  
  public Note(StringZone b, int pitch)
  {
    parentZone = b;
    this.pitch = pitch;
  }
  
  public void setPosition(float p)
  {
    position = p;
  }
  
  public void draw()
  {
    float i = (timeRemaining/parentZone.getSustain())*255;
    stroke(i);
    line(position, 0, position, parentZone.height);
    
    if (timeRemaining > 0)
    {
      timeRemaining = max(0,timeRemaining - millisecondsElapsed);
      
      if (timeRemaining == 0)
      {
        midi.playNote(parentZone.getMIDIChannel(), pitch, 0);
      }
    }
  }
  
  public void trigger(float velocity)
  {
      timeRemaining = parentZone.getSustain();
      midi.playNote(parentZone.getMIDIChannel(), pitch, (int)(velocity * 127));
  }
}
