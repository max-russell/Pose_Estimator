//This class was created to encapsulate the MidiBus library.

class Midi
{
  private MidiBus midiBus; 
  private List<String> outputNames;
  private String currentOutput;
  
  public Midi(PApplet app)
  {
      midiBus = new MidiBus(app);
      makeOutputList();
      currentOutput = "-";
  }
  
  private void makeOutputList()
  {
      String[] d = null;
      d = MidiBus.availableOutputs();
        
      outputNames = new ArrayList<String>();
      if (d != null)
      {
        for(String s: d) outputNames.add(s);
      }
      outputNames.add("-");
  }
  
  public void sendControlChange(int channel, int bank, int patch)
  {
    midiBus.sendMessage(0xB0 + channel, 0, bank);
    midiBus.sendMessage(0xC0 + channel, patch);
  }
  
  public void playNote(int channel, int pitch, int velocity)
  {
      midiBus.sendNoteOff(channel, pitch, velocity);
      midiBus.sendNoteOn(channel, pitch, velocity);
  }
  
  public List<String> getDevices()
  {
    return outputNames;
  }
  public String getCurrentOutput() {return currentOutput;} 
  
  public void setOutputDevice(String s)
  {    
    if (currentOutput != s)
    {
      midiBus.clearOutputs();
      if (!s.equals("-") && midiBus.addOutput(s))
      {
        currentOutput = s;
        
        //Shortcut on the default windows midi synth to set to the GM Harp sound. 
        if (s.toUpperCase().equals("MICROSOFT GS WAVETABLE SYNTH")){
          sendControlChange(0, 0, 46);
        }
      }
      else disable();
    }
  }
  
  public void disable()
  {
    midiBus.clearOutputs();
    currentOutput = "";
  }
}

String midiNoteNumToString(int n)
{
  String[] names = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"};
  return names[n % 12] + (n/12-1);
}
String keyNumToString(int n)
{
  String[] names = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"};
  return names[n];
}
