/*
// This is a basic example to demonstrate how the Speech-To-Text Library 
// can be used. See www.getflourish.com/sst/ for more information on
// available settings.
//
// Florian Schulz 2011, www.getflourish.com
*/

import com.getflourish.stt.*;

import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress myRemoteLocation;

ThreadedNGramGetter nGramGetter;

STT stt;
String result;

void setup ()
{
    size(600, 200);
    // Init STT automatically starts listening, files are stored as history
    stt = new STT(this, false);
    stt.enableDebug();
    stt.setLanguage("de"); 
    
    nGramGetter = new ThreadedNGramGetter(this);
    
    oscP5 = new OscP5(this,12001);
    myRemoteLocation = new NetAddress("192.168.10.101",12000);

    // Some text to display the result
    textFont(createFont("Arial", 24));
    result = "Say something!";
}

void draw ()
{
    background(0);
    text(result, mouseX, mouseY);
}

void nGramFound (NGram ngram)
{
    if (ngram != null) {
        println("huhu, ngram!");
        //println(ngram.word);
    
        OscMessage myMessage = new OscMessage(ngram.word);
        myMessage.add(ngram.getFirstOccurance()); /* add an int to the osc message */
        oscP5.send(myMessage, myRemoteLocation);
    }
}

// Method is called if transcription was successfull 
void transcribe (String word, float confidence) 
{
    println(word);
    nGramGetter.getNGram(word);
}
