class StringZone extends Zone
{ 
  private ArrayList<Note> notes;
  private float spacing = 0;
  private float spacingN = 0; //Spacing normalised;
  
  private int midiChannel = 0;
  private int sustain = 1000;
  private int basePitch;
  private VelocityType velocityType;
  
  public StringZone()
  {
    super();
    super.name = getUniqueZoneName("String Zone");
    notes = new ArrayList<Note>();
    setNotes(20, 31);
    velocityType = new ConstantVelocity(this);
  }
  
  public int getNotesQuantity() {return notes.size();}
  public int getBasePitch() { return basePitch;}
  public void setNoteQuantity(int count) { setNotes(count, basePitch);}
  public void setNoteBasePitch(int pitch) { setNotes(notes.size(), pitch);}
  public void setVelocityType(VelocityType v){velocityType = v;}
  public int getMIDIChannel(){return midiChannel;}
  public void setMIDIChannel(int v){midiChannel = v;}
  public void setSustain(int v){sustain = v;}
  public int getSustain(){return sustain;}
  
  public void setChordAndKey(int key, Chord chord)
  {
    super.setChordAndKey(key, chord);
    if (notes != null) setNotes(notes.size(), basePitch);
  }
  
  private void setNotes(int count, int basePitch)
  { 
    this.basePitch = basePitch;
    notes.clear();

    int pitch = (basePitch / 12) * 12 + key;
    int b=0;
    for (b = 0; b < chord.size; b++)
    {
      if (basePitch <= pitch) break; 
      pitch += chord.sequence[b];
    }
    int offset = b % chord.size;
    
    for(int n = 0; n < count; n++)
    { 
      notes.add(new Note(this, pitch));
      pitch += chord.sequence[(n+offset) % chord.size]; 
    }
    updateSpacing();
  }
  
  //OVERRRIDE
  protected void trigger(PVector p1, PVector p2)
  {
    PVector pstart, pend; 
    //Switch the direction so we always go left to right.
    if (p1.x < p2.x) {pstart = p1; pend = p2;} else {pstart = p2; pend = p1;}
    
    //Trivial situations where no notes will be triggered.
    if (pend.x < 0 || pstart.x > 1.0 || (pstart.y < 0 && pend.y < 0) || (pstart.y > 1.0 && pend.y > 1.0)) return;
    
    PVector v = PVector.sub(pend, pstart);
    PVector vnorm = PVector.div(v, v.x);
    
    PVector vn = PVector.mult(vnorm, spacingN); //Vector that is a note distance in x
    PVector vm = PVector.mult(vnorm, spacingN - (pstart.x - floor(pstart.x / spacingN) * spacingN)); //Vector to the intersection with the next string.
    
    PVector p = pstart.copy();

    while(p.x < pend.x)
    {
      //Move this point along until we intersect with the next string
      PVector ps = PVector.add(p, vm);
      if (ps.x >= pend.x) break;
      
      int note_index1 = floor(p.x / spacingN);
      p.add(vn); //Move along so we're exactly one note across
      int note_index2 = floor(p.x / spacingN);
      
      if (note_index1 < note_index2 && note_index2 >= 0 && note_index2 < notes.size())
      {
        //Is the intersection point on the zone?
        if (ps.y >= 0 || ps.y < 1.0)
        {
          notes.get(note_index2).trigger(velocityType.get());
        }
      }
    }
  }
  
  //OVERRIDE
  public void setPosition(int x, int y, int w, int h)
  {
    super.setPosition(x,y,w,h);
    updateSpacing();
  }
  
  private void updateSpacing()
  {
    if (notes == null) return;
    
    if (notes.size() > 1)
    {
      spacing = (float)width / (notes.size() - 1);
      spacingN = 1.0 / (notes.size() - 1);
    }
    else spacing = 0;
    
    for(int n=0; n < notes.size(); n++)
    {
      notes.get(n).setPosition(n * spacing);
    }
  }
  
  //OVERRIDE
  public void drawInternal()
  {    
    rect(0,0,width,height);
    strokeWeight(1);
    
    for(Note note: notes)
    {
      note.draw();
    }
  }
  
  public void drawVelocityBar()
  {
      int bh = (int)(velocityType.get() * screenHeight);
      fill(255,0,255);
      rect(0, screenHeight - bh, 5, bh);  
  }
  
  //OVERRIDE
  public JSONObject getJSON()
  {  
    JSONObject z = super.getJSON();
    z.setInt("midiChannel", midiChannel);
    z.setInt("sustain", sustain);
    z.setInt("noteCount", notes.size());
    z.setInt("rootPitch", basePitch);
    z.setString("velocity", velocityType.getName());
    z.setFloat("velocitySourceLower", velocityType.getSourceLower());
    z.setFloat("velocitySourceUpper", velocityType.getSourceUpper());
    z.setFloat("velocityTargetLower", velocityType.getSourceLower());
    z.setFloat("velocityTargetUpper", velocityType.getSourceUpper());
    return z;
  }
  
  public StringZone(JSONObject z)
  {
    super(z);
    notes = new ArrayList<Note>();
    midiChannel = z.getInt("midiChannel");
    sustain = z.getInt("sustain");    
    setNotes(z.getInt("noteCount"), z.getInt("rootPitch"));
    velocityType = getNewVelocityByName(z.getString("velocity"), this);
    velocityType.setSourceLower(z.getFloat("velocitySourceLower"));
    velocityType.setSourceUpper(z.getFloat("velocitySourceUpper")); 
    velocityType.setTargetLower(z.getFloat("velocityTargetLower"));
    velocityType.setTargetUpper(z.getFloat("velocityTargetUpper"));   
  }
  
}
