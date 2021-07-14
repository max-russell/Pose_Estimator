private List<String> sourceList;
private int cameraCount;
private final int attemptsBeforeTimeout = 100;

final Set<String> videoFormats = new java.util.HashSet<String>();
final Set<String> imageFormats = new java.util.HashSet<String>();
enum Source {NONE, CAMERA, MOVIE, IMAGE};

void initialiseInputSources()
{
  videoFormats.add("mp4");
  imageFormats.add("bmp");
  imageFormats.add("png");
  imageFormats.add("jpg");
  
  sourceList = new ArrayList<String>();
  cameraCount = 0;
  int attempts = 0;
  String[] c = null;
  
  while ((c == null || c.length == 0) && attempts < attemptsBeforeTimeout) 
  { 
    c = Capture.list();
    attempts++;
  }
  
  if (c != null)
  {
    for(String s: c) {sourceList.add(s); cameraCount++;}
  }
  
  String[] filenames = new File(sketchPath() + "\\data").list();
  
  for(String s: filenames)
  {
    if (getMediaType(s) != Source.NONE) sourceList.add(s);
  }
  
  sourceList.add("-");
  
  //On start-up connect to a camera if one is available, other a blank source.
  if (cameraCount > 0)
    selectInputSource(0);
  else 
    selectInputSource(-1);
  
}

void selectInputSource(int n)
{
  if (inputSource != null) inputSource.finish();
  
  if (n >= 0 && n < sourceList.size()-1)
  {  
    String s = sourceList.get(n);
    
    if (n < cameraCount)
    {
      inputSource = new CamInputSource(s);
      mirrorSource = true;
      return;
    }
    else
    {
      switch(getMediaType(s))
      {
        case IMAGE:
          inputSource = new ImageInputSource(s);
          return;
        case MOVIE:
          inputSource = new VideoInputSource(s);
          mirrorSource = false;
          return;
      }
    }
  }
 inputSource = new BlankInputSource();
}

private Source getMediaType(String s)
{
  String ext = getExtension(s);
  
  if (imageFormats.contains(ext))
  {
    return Source.IMAGE;
  }
  else if (videoFormats.contains(ext))
  {
    return Source.MOVIE;
  }
  return Source.NONE;
}

public String getDefaultInputName()
{
  if (cameraCount == 0) return "-";
  else return sourceList.get(0);
}

abstract class InputSource
{
  protected String name;
  protected PImage image;  
  protected int width, height;
  
  public int getWidth() { return width;}
  public int getHeight() { return height;}
  public PImage get() {return image;}
  public boolean isReady() {return image != null && image.width > 0;}
  public String getName(){return name;}
  public void finish(){}
  
  public void draw()
  {
    if (!isReady())
    {
      fill(50,120,180);
      noStroke();
      rect(0,0,screenWidth, screenHeight);
    }
    else
    {
      image(image, 0, 0, screenWidth, screenHeight);      
    }
  }
}

class BlankInputSource extends InputSource
{
  public BlankInputSource(){name = "-";}
}

class ImageInputSource extends InputSource
{ 
  public ImageInputSource(String s)
  {
    name = s;
    image = loadImage(s); 
    width = image.width;
    height = image.height;
  }
}

class CamInputSource extends InputSource
{
  private Capture cam;
  
  public CamInputSource(String s)
  {
    name = s;
    cam = new Capture(app, screenWidth, screenHeight, s);
    cam.start();
    image = cam;
    width = cam.width;
    height = cam.height;
  }
  
  public void finish()
  {
    cam.stop();
  }
  
  public PImage get()
  {
    if (cam.available()) cam.read();
    return cam;
  }
  
}
