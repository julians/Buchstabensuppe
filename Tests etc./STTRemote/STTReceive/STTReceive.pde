import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress myRemoteLocation;

String result;

boolean dome; 

void setup ()
{
    if (dome) {
        size(1920, 1920);
    } else {
        size(800, 400);
    }
    
    oscP5 = new OscP5(this,12000);
    
    // Some text to display the result
    textFont(createFont("Arial", 100));
    result = "?";
    textAlign(CENTER);
}

void draw ()
{
    background(0);
    text(result, width / 2, height / 2);
}

// Method is called if transcription was successfull 
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  result = theOscMessage.addrPattern() + " (" + theOscMessage.get(0).intValue() + ")";
}

