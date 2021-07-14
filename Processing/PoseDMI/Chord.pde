//Zones are lniked to a particular Chord object. 
//In StringZones this determines the pitches of the strings. 
//In ControlZones this determines which chord StringZones are set to when the ControlZone is triggered.

Chord[] chordList;

void initialiseChords()
{
  chordList = new Chord[6];
  chordList[0] = new Chord("Major", "", 4, 3, 5);
  chordList[1] = new Chord("Minor", "m", 3, 4, 5);
  chordList[2] = new Chord("Major 7th", "7", 4, 3, 3, 2);
  chordList[3] = new Chord("Minor 7th", "m7", 3, 4, 3, 2);
  chordList[4] = new Chord("Fifths", "5", 7, 5);
  chordList[5] = new Chord("Octaves", "o", 12);
}

List<String> getChordNames()
{
  List<String> l = new ArrayList<String>();
  for(Chord c: chordList)
  {
    l.add(c.name);
  }
  return l;
}

Chord getChordByName(String name)
{
  for(Chord c: chordList)
  {
    if (c.name.equals(name)) return c;
  }
  return null;
}

class Chord
{
  public String name;
  public String shortName;
  public int index;
  public int[] sequence;
  public int size;
  
  public Chord(String name, String shortName, int... sequence)
  {
    this.name = name;
    this.shortName = shortName;
    index = chordList.length;
    this.sequence = sequence;
    size = sequence.length;
  }
}
