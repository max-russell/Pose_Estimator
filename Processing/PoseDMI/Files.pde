final int CONFIG_FILE_VERSION = 2;

public void doSaveFile(File f)
{
  if (f == null) return; //Dialog was cancelled or failed
  
  makeRequest(new Request(f){
    public void service() 
    {
      JSONObject config = new JSONObject();
      
      config.setInt("version", CONFIG_FILE_VERSION);
      config.setInt("mirrorSource", mirrorSource ? 1 : 0);
      config.setInt("showImage", showImage ? 1 : 0);
      config.setInt("showHeatMap", showHeatMap ? 1 : 0);
      config.setFloat("confidenceThreshold", confidenceThreshold);
      //config.setInt("heatMapKeypoint", heatMapKeypoint);
      config.setString("setCurrentOutput", midi.getCurrentOutput());
      
      JSONArray za = new JSONArray();
      
      int n = 0;
      for(Zone z: zones)
      {
        JSONObject zj = z.getJSON();
        za.setJSONObject(n++, zj);
      }
      config.setJSONArray("zones", za);
      saveJSONObject(config, file.getAbsolutePath());
      println("Configuration saved to: " + file.getAbsolutePath());
    }  
  });
}

public void doLoadFile(File f)
{
  if (f == null) return; //Dialog was cancelled or failed
  
  if (!f.exists())
  {
    println("File could not be found.");
    return;
  }
  
  if (!getExtension(f.getAbsolutePath()).equals("json"))
  {
    println("Wrong file type");
    return;    
  }
 
  makeRequest(new Request(f){
    public void service() 
    {
      JSONObject config = loadJSONObject(file.getAbsolutePath());
      
      if (config.getInt("version") != CONFIG_FILE_VERSION)
      {
        println("Incompatible config file version.");
        return;
      }
      
      mirrorSource = config.getInt("mirrorSource") == 1 ? true : false;
      showImage = config.getInt("showImage") == 1 ? true : false;
      showHeatMap = config.getInt("showHeatMap") == 1 ? true : false;
      confidenceThreshold = config.getFloat("confidenceThreshold"); 
      midi.setOutputDevice(config.getString("setCurrentOutput"));
      
      selected = null;
      zones.clear();
      
      JSONArray za = config.getJSONArray("zones");
      
      for(int n = 0; n < za.size(); n++)
      {
        JSONObject zo = za.getJSONObject(n);
        Zone z;
        if (zo.getInt("type") == 1)
        {
          z = new ControlZone(zo);
        }
        else
        {
          z = new StringZone(zo);
        }
        zones.add(z);
      }
      
      controls.refreshGUIFull();
    }
  });
}
    

  
