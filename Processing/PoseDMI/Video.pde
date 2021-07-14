class VideoInputSource extends InputSource
{
  private Movie movie;
  private int frameReadCount = 2; 
  double durationSeconds;
  int durationFrames;
  int currentFrame = 0;
  float currentTime = 0;
  float framerate;
  
  boolean paused = true;
  
  public VideoInputSource(String s)
  {
      name = s;
      movie = new Movie(app, s);
      movie.play();
      movie.jump(0);
      movie.pause();
      paused = true;
      framerate = movie.frameRate;
      if (framerate == 30.0) framerate= 29.97;
      durationSeconds = movie.duration();
      durationFrames = (int)(durationSeconds * framerate);
      currentTime=0;
      frameReadCount = 5;
     
      width = movie.width;
      height = movie.height;
      image = createImage(width, height, RGB);
  }
  
  public void finish()
  {
    movie.stop();
  }
  
  public boolean isPaused(){return paused;}
  
  public void seek(float n)
  {
    currentTime = n;
    frameReadCount = 2;
    
    if (!paused)
    {
      movie.jump(currentTime);
    }
  }
  
  public void play()
  {
    paused = false;
    movie.loop();
  }
  
  public void pause()
  {
    paused = true;
    movie.pause();
  }
  
  public void playCapture()
  {
    if (!paused)
    {
      movie.read();
      image = movie.copy();
    }
  }
  
  public PImage get()
  {
    if (paused)
    {
      movie.play();
      movie.jump(currentTime);
      movie.pause();
    
      if (movie.available()) 
      {
        movie.read();
        
        //The frameReadCounter makes sure the Movie is read several times. For some reason it does not seem to capture properly on a single attempt.
        frameReadCount--;
        if (frameReadCount==0)
        {
          image = movie.copy();
          
          //This has to be set because Movie objects initialise to a size of (0,0) when first loaded.
          width = image.width;
          height = image.height;
        }
      }
      return image;
    }
    
    else
    {
      currentTime = movie.time();
      controls.refreshGUIVideoSlider();
      return image;
    }
    
  }
  public void nextFrame(){currentTime = currentTime + 0.25; frameReadCount=2;}
  public void previousFrame(){currentTime -= 0.25; frameReadCount=2;}
  
}

//Movies don't seem to capture properly from the main draw loop like other input sources. This event captures the video image when it is available.
void movieEvent(Movie m) {
  if (inputSource instanceof VideoInputSource)
  {
    ((VideoInputSource)inputSource).playCapture();
  }
}
