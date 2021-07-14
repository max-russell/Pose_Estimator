class ControlWindow extends PApplet
{
  int width, height;
  PApplet parent;
  ControlP5 cp5;
  
  controlP5.Textlabel initPoseLbl, ctlZoneKeypointLbl, ctlHeatMapDisplayLbl, ctlZoneVelocityLbl, ctlBasePitchName, ctlZoneKeyName;
  controlP5.ScrollableList ctlInputSources, ctlZoneList, ctlZoneKeypoint, ctlMidiDevices, ctlZoneVelocity, ctlZoneChord;
  controlP5.Button ctlMirrored, ctlMidiSend, ctlDeleteZone, ctlZoneEnabled, ctlShowImage, ctlHeatMapOn, ctlSave, ctlLoad, ctlPlayVideo, ctlPauseVideo, ctlStopVideo;
  controlP5.Group grpZones, grpMidi, grpVideo;
  controlP5.Range ctlZoneVelRange, ctlZoneVelTRange;
  controlP5.Numberbox ctlConfidence, ctlSelectChannel, ctlSelectBank, ctlSelectPatch, ctlZoneRotation, ctlZoneMidi, ctlZoneSustain, ctlZoneNotes, ctlZoneBasePitch, ctlZoneKey;
  controlP5.Slider ctlFrameSlider;
  
  List<controlP5.Controller> zoneControls = new ArrayList<controlP5.Controller>();
  List<controlP5.Controller> stringZoneControls = new ArrayList<controlP5.Controller>();
  int zoneVisibilityControls = 0;
  
  int requestGUIRefresh = 0;
  
  public ControlWindow(PApplet parent) {
    super();   
    this.parent = parent;
    width = 292;
    height = 605;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }  
  
  public void settings() {
    size(width, height);
  }  
  
  public void setup()
  {
    surface.setLocation(10, 10);
    cp5 = new ControlP5(this); 
    cp5.setAutoDraw(false);
    cp5.setBroadcast(false);
       
    initPoseLbl = cp5.addLabel("")
       .setPosition(10,20)
       .setFont(createFont("arial",15))
       .setColor(color(0));
       
    List<String> c = sourceList;
       
    ctlInputSources = makeListBox("setInputSource", "Input Source   ", 10, 60, 265, null).addItems(c);
    ctlInputSources.setLabel(inputSource.getName());
    ctlMirrored = makeCheckBox("setMirrored", "Mirror Image", 10,85,null);
    ctlShowImage = makeCheckBox("setShowImage", "Show Image", 100, 85, null);
    ctlHeatMapOn = makeCheckBox("setShowHeatMap", "Show Heat Map", 190,85, null);
    //ctlHeatMapDisplay = makeListBox("changeHeatMap", "Heat Map View  ", 10, 115, 145, null).addItems(keypointNames).setLabel(keypointNames[0]); 
    ctlConfidence = makeNumberBox("setConfidence", "Confidence", 250, 115, 30,0,1.0, null);
    
    grpMidi = makeGroup("MIDI", 155, 65);
    ctlMidiDevices = makeListBox("setMidiDevice", "Midi Out Device", 5, 10, 250, grpMidi).addItems(midi.getDevices()); 
    ctlSelectChannel = makeNumberBox("selectMIDIChannel", "Channel", 50, 35, 30, 0, 15, grpMidi);
    ctlSelectBank = makeNumberBox("selectMIDIBank", "Bank", 115,35, 30, 0, 127, grpMidi);
    ctlSelectPatch = makeNumberBox("selectMIDIPatch", "Patch", 185, 35, 30, 0, 127, grpMidi);
    ctlMidiSend = makeButton("midiSend", "Send", 225, 35, 35, 20, grpMidi);
    
    grpZones = makeGroup("Zones", 240, 250); 
    ctlZoneList = makeListBox("selectZone", null, 10, 10, 180, grpZones);   
    makeButton("addNewSZone", "New SZone", 130, 10, 60, 20, grpZones);
    makeButton("addNewCZone", "New CZone", 200, 10, 60, 20, grpZones);
    
    zoneVisibilityControls = 1; //This flag means subsequent controls are made invisible if no zone is currently selected.
    
    ctlZoneKeypoint = makeListBox("zoneChangeKeypoint", "Pose keypoint", 5, 40, 145, grpZones).addItems(keypointNames); 
    ctlZoneEnabled = makeCheckBox("setZoneEnabled", "Enable", 150,40, grpZones);     
    ctlDeleteZone = makeButton("deleteZone", "Delete", 210, 40, 50, 20, grpZones);

    ctlZoneChord = makeListBox("zoneChangeChord", "Chord Type  ", 5, 70, 160, grpZones).addItems(getChordNames());
    ctlZoneKey = makeNumberBox("zoneChangeKey", "Key", 210, 70, 25, 0, 11, grpZones);
    ctlZoneKeyName = cp5.addLabel("C").setPosition(235,75).setGroup(grpZones);
    zoneControls.add(ctlZoneKeyName);

    ctlZoneRotation = makeNumberBox("zoneChangeRotation", "Rotation", 230, 100, 30, -180, 180, grpZones);
    
    zoneVisibilityControls = 2; //Only show subsequent controls if a StringZone is selected, not a Control Zone
    ctlZoneMidi = makeNumberBox("zoneMIDIChannel", "MIDI channel", 65, 100, 30, 0, 15, grpZones);
    ctlZoneSustain = makeNumberBox("zoneSetSustain", "Sustain", 140, 100, 35, 0, 6000, grpZones).setMultiplier(10.0);

    ctlZoneNotes = makeNumberBox("zoneChangeNotes", "Note Qty.", 50, 130, 35, 1, 100, grpZones);
    ctlZoneBasePitch = makeNumberBox("zoneBasePitch", "Base Note", 145, 130, 35, 0, 127, grpZones);
    ctlBasePitchName = cp5.addLabel("C5").setPosition(180,135).setGroup(grpZones);
    stringZoneControls.add(ctlBasePitchName);

    ctlZoneVelocity = makeListBox("zoneChangeVelocity", "Velocity Type", 5, 160, 140, grpZones).addItems(new String[]{"Constant", "Height", "Move Speed", "Eye Distance"});
    ctlZoneVelRange = cp5.addRange("zoneSetVelRange")
      .setPosition(80,190)
      .setSize(180,20)
      .setBroadcast(false)
      .setRange(0,100)
      .setRangeValues(0,100)
      .setBroadcast(true)
      .setLabel("Source Range")
      .setGroup(grpZones);
    ctlZoneVelRange.getCaptionLabel().align(ControlP5.LEFT_OUTSIDE, ControlP5.CENTER).setPaddingX(10);
    stringZoneControls.add(ctlZoneVelRange);
    
    ctlZoneVelTRange = cp5.addRange("zoneSetVelTRange")
      .setPosition(80,220)
      .setSize(180,20)
      .setBroadcast(false)
      .setRange(0,1.0)
      .setRangeValues(0,100)
      .setBroadcast(true)
      .setLabel("Target Range")
      .setGroup(grpZones);
    ctlZoneVelTRange.getCaptionLabel().align(ControlP5.LEFT_OUTSIDE, ControlP5.CENTER).setPaddingX(10);
    stringZoneControls.add(ctlZoneVelTRange);    
    
    zoneVisibilityControls = 0;
      
    grpVideo = makeGroup("Video", 508, 60);
    ctlFrameSlider = cp5.addSlider("frameSlider").setPosition(5,5).setSize(260,20).setRange(0,1000).setGroup(grpVideo).setLabel("");
    ctlPlayVideo = makeButton("playVideo", "Play", 5, 30, 50,20,grpVideo); 
    ctlPauseVideo = makeButton("pauseVideo", "Pause", 60, 30, 50, 20, grpVideo);
    ctlStopVideo = makeButton("stopVideo", "Stop", 115, 30, 50, 20, grpVideo);
    
    ctlLoad = makeButton("selectLoad", "Load Configuration", 10, 575,100,20, null);
    ctlSave = makeButton("selectSave", "Save Configuration", 120, 575,100,20, null);
    
    //Make sure the drop down lists don't go behind any controls when open by bringing them to the front
    //in order from bottom to top of display
    ctlZoneVelocity.bringToFront();
    ctlZoneChord.bringToFront();
    ctlZoneKeypoint.bringToFront();
    ctlZoneList.bringToFront();
    ctlMidiDevices.bringToFront();
    ctlInputSources.bringToFront();
    
    updatePoseStatus(); 
    cp5.setBroadcast(true);
  }
  
  //Convenience functions to create ControlP5 widgets with most parameters automatically set as required for the app.
  
  public controlP5.Group makeGroup(String label, int y, int h)
  {
    controlP5.Group g = cp5.addGroup(label)
      .setPosition(10,y)
      .setSize(270,h)
      .setOpen(true)
      .disableCollapse()
      .setBackgroundColor(color(100));
    return g;
  }
  
  public controlP5.Numberbox makeNumberBox(String name, String label, int x, int y, int width, int min, int max, controlP5.Group group)
  {
    controlP5.Numberbox c = cp5.addNumberbox(name)
       .setPosition(x,y)
       .setSize(width,20)
       .setDirection(Controller.HORIZONTAL)
       .setRange(min,max)
       .setValue(0)
       .setLabel(label)
       //.setMultiplier(0.1)
       .setDecimalPrecision(0);
    if (group != null) c.setGroup(group);
    c.getCaptionLabel().align(ControlP5.LEFT_OUTSIDE, ControlP5.CENTER).setPaddingX(5);
    
    setVisGroup(c);
    return c;
  }
  public controlP5.Numberbox makeNumberBox(String name, String label, int x, int y, int width, float min, float max, controlP5.Group group)
  {
    controlP5.Numberbox c = cp5.addNumberbox(name)
       .setPosition(x,y)
       .setSize(width,20)
       .setDirection(Controller.HORIZONTAL)
       .setRange(min,max)
       .setValue(0)
       .setLabel(label)
       .setMultiplier(0.01)
       .setDecimalPrecision(2);
    if (group != null) c.setGroup(group);
    c.getCaptionLabel().align(ControlP5.LEFT_OUTSIDE, ControlP5.CENTER).setPaddingX(5);   
    setVisGroup(c);
    return c;
  }
  
  public controlP5.ScrollableList makeListBox(String name, String label, int x, int y, int w, controlP5.Group group)
  {
    controlP5.ScrollableList c = cp5.addScrollableList(name)
       .setPosition(label != null ? x+label.length() * 5 : x, y)
       .setSize(w-70,100)
       .setBarHeight(20)
       .setItemHeight(20)
       //.addItems(items)
       .setOpen(false)
       .setLabel("-")
       .setGroup(group);
    if (group != null) c.setGroup(group);
    if (label != null)
    {
      controlP5.Textlabel l = cp5.addLabel(label)
         .setSize(70,20)
         .setPosition(x,y+5);
      if (group != null) 
      {
        l.setGroup(group);
        l.setColor(color(255));
      }
      else l.setColor(0);
      setVisGroup(l);
    }
    setVisGroup(c);
    return c;
  }
  
  public controlP5.Button makeCheckBox(String name, String label, int x, int y, controlP5.Group group)
  {
    controlP5.Button c = cp5.addButton(name)
      .setPosition(x,y)
      .setSize(20,20)
      .setLabel(label)
      .setSwitch(true)
      .setOn()
      .setColorLabel(0);
    if (group != null) {c.setGroup(group);  c.setColorLabel(color(255));}
    c.getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(5); 
    setVisGroup(c);
    return c;
  }
  
  public controlP5.Button makeButton(String name, String label, int x, int y, int w, int h, controlP5.Group group)
  {
    controlP5.Button c = cp5.addButton(name)
       .setPosition(x,y)
       .setSize(w,h)
       .setLabel(label);
    if (group != null) c.setGroup(group);
    setVisGroup(c);
    return c;
  }
  
  private void setVisGroup(controlP5.Controller c)
  {
    if (zoneVisibilityControls==2) stringZoneControls.add(c);
    else if (zoneVisibilityControls==1) zoneControls.add(c);
  }
  
  public void updatePoseStatus()
  {
    if (!doNotLoadPose)
    {
      if (!poseStarted)
      {
        initPoseLbl.setText("Pose Estimator initialising, please wait...");
      }
      else
      {
        initPoseLbl.setText("Pose Estimator loaded.");
        initPoseLbl.setColor(color(0));        
      }
    }    
    else
    {
      initPoseLbl.setText("Pose Estimator disabled.");
    }
  }
  
  //These should only be called from the ControlWindow class thread.
  
  void updateAllControls()
  {
    cp5.setBroadcast(false);
    controls.updatePoseStatus();
    if (mirrorSource) ctlMirrored.setOn(); else ctlMirrored.setOff();
    if (showImage) ctlShowImage.setOn(); else ctlShowImage.setOff();
    if (showHeatMap) ctlHeatMapOn.setOn(); else ctlHeatMapOn.setOff();
    //ctlHeatMapDisplay.setLabel(keypointNames[heatMapKeypoint]);
    ctlConfidence.setValue(confidenceThreshold);
    
    ctlMidiDevices.setLabel(midi.getCurrentOutput());
    updateZoneControls(true);
   
    grpVideo.setVisible(inputSource instanceof VideoInputSource);
    
    if (inputSource instanceof VideoInputSource)
    {
      VideoInputSource video = (VideoInputSource)inputSource;
      ctlFrameSlider.setRange(0, (float)video.durationSeconds);
    }
   
    cp5.setBroadcast(true);
  }
  
  void updateZoneControls() {updateZoneControls(false);}
  void updateZoneControls(boolean forceZonelistRefresh)
  { 
    cp5.setBroadcast(false);
    
    if (forceZonelistRefresh || zones.size() != ctlZoneList.getItems().size())
    {
      ctlZoneList.clear();
      for(Zone z: zones)
      {
        ctlZoneList.addItem(z.getName(),0);
      }         
    }
    
    if (selected == null)
    {
      for(controlP5.Controller c: zoneControls) c.setVisible(false);
      for(controlP5.Controller c: stringZoneControls) c.setVisible(false);
      ctlZoneList.setLabel("<None selected>");
    }
    else
    {    
      for(controlP5.Controller c: zoneControls) c.setVisible(true);
      for(controlP5.Controller c: stringZoneControls) c.setVisible(selected instanceof StringZone);
      
      ctlZoneList.setLabel(selected.getName());
      
      if (selected.getEnabled()) ctlZoneEnabled.setOn(); else ctlZoneEnabled.setOff();
      ctlZoneRotation.setValue(degrees(selected.getRotation()));
      ctlZoneKeypoint.setLabel(keypointNames[selected.getTriggerKeyPoint()]);
      
      ctlZoneChord.setLabel(selected.getChord().name);
      ctlZoneKey.setValue(selected.getKey());
      ctlZoneKeyName.setText(keyNumToString(selected.getKey()));
      
      if (selected instanceof StringZone)
      {
        StringZone sz = (StringZone)selected;
        
        ctlZoneMidi.setValue(sz.getMIDIChannel());
        ctlZoneSustain.setValue(sz.getSustain());
        ctlZoneVelocity.setLabel(sz.velocityType.getName());
        
        ctlZoneVelRange.setRange(sz.velocityType.getMin(), sz.velocityType.getMax());
        ctlZoneVelRange.setRangeValues(sz.velocityType.getSourceLower(), sz.velocityType.getSourceUpper());
        
        ctlZoneVelTRange.setRangeValues(sz.velocityType.getTargetLower(), sz.velocityType.getTargetUpper());
        
        
        ctlZoneNotes.setValue(sz.getNotesQuantity());
        ctlZoneBasePitch.setValue(sz.getBasePitch());
        ctlBasePitchName.setText(midiNoteNumToString(sz.getBasePitch()));
      }
    }
    
    cp5.setBroadcast(true);
  }
  
  void setInputSource(int n)
  {
    //Do not attempt to change the source on the input thread, instead request it in the main thread. 
    makeRequest(new Request(null, n){
        public void service() 
        {   
            selectInputSource(newValue);
            refreshGUIFull();
            totalTime = 0;
            framesElapsed = 0;
        }}
      );
  }
  
  void setMirrored(boolean yes)
  {
    mirrorSource = yes;
  }
  
  void setShowHeatMap(boolean yes)
  {
    showHeatMap = yes;
  }
  
  void setShowImage(boolean yes)
  {
    showImage = yes;
  }
  
  void setConfidence(float n)
  {
    confidenceThreshold = n;
  }
  
  void setMidiDevice(int n)
  {
    String s = (String)cp5.get(ScrollableList.class, "setMidiDevice").getItem(n).get("name");
    
    if (s.equals("-"))
      midi.disable();
    else
      midi.setOutputDevice(s);
  }
  
  void midiSend(int n)
  {
    midi.sendControlChange((int)ctlSelectChannel.getValue(), (int)ctlSelectBank.getValue(), (int)ctlSelectPatch.getValue());
  }
  
  void selectZone(int n)
  {
    selected = zones.get(n);
    updateZoneControls();
  }
  
  void addNewSZone(int n)
  {
    makeRequest(new Request(){
      public void service() 
      {
        Zone z = new StringZone();
        zones.add(z);   
        selected = z;
        refreshGUIZone();
      }      
    });    
  }
  
  void addNewCZone(int n)
  {
    makeRequest(new Request(){
      public void service() 
      {
        Zone z = new ControlZone();
        zones.add(z);   
        selected = z;
        refreshGUIZone();
      }      
    });    
  }
  
  
  void deleteZone(int n)
  {
    makeRequest(new Request(){
      public void service() 
      {
        zones.remove(selected);
        selected = null;
        refreshGUIZone();
      }      
    });     
  }
  
  public void setZoneEnabled(boolean e)
  {
    if (selected != null)
    {
      selected.setEnabled(e);
    }
  }
  
  void zoneChangeKeypoint(int n)
  {
    selected.setTriggerKeyPoint(n);
  }
  
  void zoneChangeChord(int n)
  {
    makeRequest(new Request(selected, (int)n){
      public void service() 
      {
        zone.setChordAndKey(zone.getKey(), chordList[newValue]);
      }
    });      
 } 
 
  void zoneChangeKey(float n)
  {
    makeRequest(new Request(selected, (int)n){
      public void service() 
      {
        zone.setChordAndKey(newValue, zone.chord);
      }
    });   
    ctlZoneKeyName.setText(keyNumToString((int)n));
  }
 
  void zoneChangeRotation(float a)
  {
    if (selected != null)
    {
      selected.setRotation(radians(a));
    }
  }
  
  void zoneMIDIChannel(float n)
  {
    if (selected != null && selected instanceof StringZone)
    {
      ((StringZone)selected).setMIDIChannel((int)n);
    }    
  }
  
 void zoneSetSustain(float n)
 {
    if (selected != null && selected instanceof StringZone)
    {
      ((StringZone)selected).setSustain((int)n);
    }      
 }
 
 void zoneChangeVelocity(int n)
 {
   if (selected != null && selected instanceof StringZone)
   {
     VelocityType v;
     
     switch(n)
     {
       case 1: v = new HeightVelocity(selected); break;
       case 2: v = new MoveSpeedVelocity(selected); break;
       case 3: v = new EyeDistanceVelocity(selected); break;
       default: v = new ConstantVelocity(selected); break;
     }
     ((StringZone)selected).setVelocityType(v);
     updateZoneControls();
   }
 }
 
 void controlEvent(ControlEvent e) {
   if (selected != null && selected instanceof StringZone)
   {
     if (e.isFrom("zoneSetVelRange")) { 
        ((StringZone)selected).velocityType.setSourceLower(e.getController().getArrayValue(0));
        ((StringZone)selected).velocityType.setSourceUpper(e.getController().getArrayValue(1));
     }
     else if (e.isFrom("zoneSetVelTRange"))
     {
        ((StringZone)selected).velocityType.setTargetLower(e.getController().getArrayValue(0));
        ((StringZone)selected).velocityType.setTargetUpper(e.getController().getArrayValue(1));       
     }
   } 
    
  }

  void zoneChangeNotes(float n)
  {
    if (selected != null && selected instanceof StringZone)
    {
      makeRequest(new Request(selected, (int)n){
        public void service() 
        {
          ((StringZone)zone).setNoteQuantity(newValue);
        }
      });
    }
  }
   
  void zoneBasePitch(float n)
  {
    if (selected != null && selected instanceof StringZone)
    {
      makeRequest(new Request(selected, (int)n){
        public void service() 
        {
          ((StringZone)zone).setNoteBasePitch(newValue);
        }      
      });
      ctlBasePitchName.setText(midiNoteNumToString((int)n));
    }
  }
  
  void frameSlider(float n)
  {    
    ((VideoInputSource)inputSource).seek(n);
  }
  
  void updateVideoSlider()
  {
    ctlFrameSlider.setBroadcast(false);
    ctlFrameSlider.setValue(((VideoInputSource)inputSource).currentTime);
    ctlFrameSlider.setBroadcast(true);
  }
  
  void playVideo(int n)
  {
    VideoInputSource video = (VideoInputSource)inputSource;
    video.play();
    println("Play!");
  }
  
  void pauseVideo(int n)
  {
    VideoInputSource video = (VideoInputSource)inputSource;
    video.pause();
    println("Pause!");    
  }
  
  void stopVideo(int n)
  {
    VideoInputSource video = (VideoInputSource)inputSource;
    println("Stop!");  
    video.pause();
    video.seek(0);  
    updateVideoSlider();
  }
  
  
  void selectLoad(int n)
  {
    selectInput("Load Configuration", "doLoadFile", new File(parent.sketchPath("Saved Configurations\\config.json")), parent);
  }
  void selectSave(int n)
  { 
    selectOutput("Save Configuration", "doSaveFile", new File(parent.sketchPath("Saved Configurations\\config.json")), parent);
  }
  
  void refreshGUIVideoSlider() { if (requestGUIRefresh < 1) requestGUIRefresh = 1;}
  void refreshGUIZone() { if (requestGUIRefresh < 2) requestGUIRefresh = 2;}
  void refreshGUIFull() { if (requestGUIRefresh < 3) requestGUIRefresh = 3;}
  
  void draw() {
    background(190);
    
    if (requestGUIRefresh > 0)
    {
      if (requestGUIRefresh == 3) {requestGUIRefresh = 0; updateAllControls();}
      else if (requestGUIRefresh == 2) {requestGUIRefresh = 0; updateZoneControls();}
      else if (requestGUIRefresh == 1) {requestGUIRefresh = 0; updateVideoSlider();}
      
    }
    
    if (!poseStarted)
    {
      if (millis() % 1000 > 500)
      {
        initPoseLbl.setColor(color(255,0,0));
      }
      else
      {
        initPoseLbl.setColor(color(255,255,255));
      }
    }
    if (drawControls) cp5.draw();
  } 
  
  void keyPressed()
  {
    mainKeyPressed(key, keyCode);
  }
}
