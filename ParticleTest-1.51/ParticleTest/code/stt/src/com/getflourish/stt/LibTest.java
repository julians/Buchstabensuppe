/**
 * @author Florian Schulz
 */
package com.getflourish.stt;

import processing.core.PApplet;

public class LibTest extends PApplet {
	
	STT stt;
	
	public void setup () 
	{
		// Init STT automatically starts listening. Check getVolume() and use setThreshold() to fit your enviroment.
		stt = new STT(this);
		// stt.enableDebug();
		stt.setLanguage("de");
	}
	
	public void draw() 
	{
		background(0);
	}
	
	public void transcribe (String utterance, float confidence, int status) 
	{
		println(utterance);
		println(confidence);
		println(status);
	}
}

