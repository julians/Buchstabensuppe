// Wartet auf Arduino Eingabe und leitet den Spaß weiter

import oscP5.*;
import netP5.*;
import processing.serial.*;
import com.getflourish.stt.*;
  
OscP5 oscP5;
NetAddress myRemoteLocation;

Serial myPort;
int pusher = 0;
int lastState = 0;
boolean arduino = false;
STT stt;

void setup ()
{
    size(600, 200);

    oscP5 = new OscP5(this,12001);
    myRemoteLocation = new NetAddress("192.168.10.101",12000);
    // myRemoteLocation = new NetAddress("192.168.0.106", 12000);
    // myRemoteLocation = new NetAddress("192.168.10.226", 12000);
    
    stt = new STT(this);
    stt.setLanguage("de");
    stt.disableAutoRecord();
    stt.enableDebug();
    String portName = Serial.list()[0];
    myPort = new Serial(this, portName, 9600);        
}

void draw ()
{
    background(255 * lastState);

    if (myPort.available() > 0) pusher = myPort.read();
    if (pusher != lastState) {
        lastState = pusher;
        send();
    }
}

void send () {
    println("send");
    // OscMessage myMessage = new OscMessage("arduino");
    // myMessage.add(pusher);
    // oscP5.send(myMessage, myRemoteLocation);
    if (pusher == 1) {
        stt.begin();
    } else {
        stt.end();
    }
}
void transcribe(String word, float utterance, int status) {
    OscMessage myMessage = new OscMessage("status");
    if (word!=null) myMessage.add(word); else myMessage.add("");
    myMessage.add(utterance);

    myMessage.add(status);
    oscP5.send(myMessage, myRemoteLocation);
}


