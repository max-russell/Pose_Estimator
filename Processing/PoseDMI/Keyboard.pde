//Before creating ControlZones I put in a means of changing chords in String Zones via pressing keyboard keys. This was useful while debugging and has been 
//retained as an 'Easter Egg'.

void keyPressed()
{
  mainKeyPressed(key, keyCode);
}

void mainKeyPressed(char key, int keyCode)
{ 
  for(Zone z: zones)
  {
    switch(key)
    { 
      case 'a': z.setChordAndKey(8, chordList[0]); break; //a flat
      case 's': z.setChordAndKey(3, chordList[0]); break; //e flat
      case 'd': z.setChordAndKey(10, chordList[0]); break; //b flat
      case 'f': z.setChordAndKey(5, chordList[0]); break; //f
      case 'g': z.setChordAndKey(0, chordList[0]); break; //c
      case 'h': z.setChordAndKey(7, chordList[0]); break; //g
      case 'j': z.setChordAndKey(2, chordList[0]); break; //d
      case 'k': z.setChordAndKey(9, chordList[0]); break; //a
      case 'l': z.setChordAndKey(4, chordList[0]); break; //e
      
      case 'q': z.setChordAndKey(8, chordList[1]); break;
      case 'w': z.setChordAndKey(3, chordList[1]); break;
      case 'e': z.setChordAndKey(10, chordList[1]); break;
      case 'r': z.setChordAndKey(5, chordList[1]); break;
      case 't': z.setChordAndKey(0, chordList[1]); break;
      case 'y': z.setChordAndKey(7, chordList[1]); break;
      case 'u': z.setChordAndKey(2, chordList[1]); break;
      case 'i': z.setChordAndKey(9, chordList[1]); break;
      case 'o': z.setChordAndKey(4, chordList[1]); break;
    }
    if (z == selected) controls.refreshGUIZone();
  }
  
  switch(key)
  {
    case '=': if (inputSource instanceof VideoInputSource) ((VideoInputSource)inputSource).nextFrame(); break;
    case '-': if (inputSource instanceof VideoInputSource) ((VideoInputSource)inputSource).previousFrame(); break;
    case '`': drawControls = !drawControls; break;
  }
  
  if (keyCode == ESC)
  {
    shutDown();
  } 
}
