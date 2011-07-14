// Wartet auf Arduino Eingabe und leitet den Spaß weiter

import oscP5.*;
import netP5.*;
import processing.serial.*;
  
OscP5 oscP5;
NetAddress myRemoteLocation;

Serial myPort;
int pusher = 0;
int lastState = 0;
boolean arduino = false;

void setup ()
{
    size(600, 200);

    oscP5 = new OscP5(this,12001);
    myRemoteLocation = new NetAddress("192.168.10.101",12000);
    
    String portName = Serial.list()[0];
    myPort = new Serial(this, portName, 9600);        
}

void draw ()
{
    background(255 * lastState);

    if (myPort.available() > 0) pusher = myPort.read();
    if (pusher != lastState) send();
}

void send () {
    OscMessage myMessage = new OscMessage("arduino");
    myMessage.add(pusher);
    oscP5.send(myMessage, myRemoteLocation);
}


