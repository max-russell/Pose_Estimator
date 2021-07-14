//Handles all the mouse interactions on the main source display. This allows zones to be selected with the
//mouse, moved around and resized.

void mousePressed()
{
  if (mouseButton == LEFT)
  {
    PVector m = getMouse();
    
    if (selected != null)
    {
      if (selected.screenPointInside(m))
      {
        startDragging(m);
      }
      else
      {
        selected = null;
        controls.refreshGUIZone();
      } 
    }
    
    if (selected == null)
    {
      for (Zone z: zones)
      {
        if (z.screenPointInside(m))
        {
          selected = z;
          controls.refreshGUIZone();
          startDragging(m);
        }
      }
    }
  }
}

void startDragging(PVector m)
{
  dragging = true;

  if (selected.screenPointOnResizeTriangle(m))
  {
    dragMode = DragMode.RESIZING;
    dragMouseToZone = selected.screenToZone(selected.getSize());
  }
  else
  {
    dragMode = DragMode.MOVING;
    dragMouseToZone = PVector.sub(selected.getPosition(), m);
  }
}

void mouseDragged()
{
  if (mouseButton == LEFT && dragging == true)
  {
    PVector m = getMouse();

    if (dragMode == DragMode.MOVING)
    {
      PVector newpos = PVector.add(m, dragMouseToZone);
      selected.setPosition((int)newpos.x, (int)newpos.y);
    }
    else if (dragMode == DragMode.RESIZING)
    {
      selected.resizeToMouse(m);
    }
  }
}

void mouseReleased()
{
  if (mouseButton == LEFT)
  {
    dragging = false;
  }
}

PVector getMouse()
{
    return new PVector(mouseX, mouseY);
}
