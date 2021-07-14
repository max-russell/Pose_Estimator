List<Request> requests = new ArrayList<Request>();

abstract class Request
{
  Zone zone;
  File file;
  int newValue;
  
  public Request(){}
  public Request(File f) {file = f;}
  public Request(Zone b, int v) {zone = b; newValue = v;} 
  
  abstract public void service();
}

void makeRequest(Request r)
{
  requests.add(r);
}

void doRequests()
{
  for(Request r: requests)
  {
    r.service();
  }
  requests.clear();
}
