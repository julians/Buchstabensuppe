package com.getflourish.stt;

import java.io.File;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

import processing.core.PApplet;

import ddf.minim.AudioInput;
import ddf.minim.AudioRecorder;
import ddf.minim.Minim;

import javaFlacEncoder.*;


/**
 * Converts speech to text using the x-webkit-speech technology found in Chrome.
 * @author Florian Schulz
 * 
 */
public class STT  {
	
	AudioInput in;
	AudioRecorder recorder;
	Minim minim;
	Timer timer;
	Timer timer2;
	Method transcriptionEvent;
	Method transcriptionEvent2;
	
	// volume threshold can be adjusted on runtime
	float threshold = 5f;
	float volume;
	boolean analyzing;
	ArrayList<Float> volumes;
	
	// timer interval
	int interval = 500;
	
	// path of recorded files
	String dataPath = "";
	String recordsPath = "";
	String path = "";
	
	boolean fired;
	boolean log = true;
	private boolean debug = false;
	private boolean autoThreshold = true;
	
	private TranscriptionThread transcription;
	
	private ArrayList<TranscriptionThread> threads;
	
	boolean recording = false;
	String fileName = "";
	String result = "";
	String status = "";
	String lastStatus = "";
	int fileCount = 0;
	
	private String language = "en";

	PApplet p;
	
	FLAC_FileEncoder encoder;
	
	public final static int RECORDING = 0;
	public final static int SUCCESS = 1;
	public final static int ERROR = 2;
	public final static int TRANSCRIBING = 3;
	
	/**
	 * @param _p instance of PApplet
	 * @param history indicates whether or not recordings are stored in the data folder	
	 */
	
	public STT (PApplet _p, boolean history) {
		this.p = _p;
		this.log = history;
		this.threads = new ArrayList<TranscriptionThread>();
		this.listen();
	}
	
	/**
	 * @param _p instance of PApplet
	 */
	
	public STT (PApplet _p) {
		this(_p, true);
	}
	
	private void listen() {
		
		status = "Waiting for your voice";
		
		transcription = new TranscriptionThread(language);
		transcription.debug = debug;
		transcription.start();
		threads.add(transcription);
		
		initFileSystem();
		
		// get a line in from Minim, default bit depth is 16
		minim = new Minim(p);
		in = minim.getLineIn(Minim.MONO);
		
		// listening repeats until something is heard
		recorder = minim.createRecorder(in, path + fileName + fileCount + ".wav", true);
		timer = new Timer(interval);
		timer.start();
		
		// FLAC
		encoder = new FLAC_FileEncoder();
		
		// Analyze Environment Volume
		if (autoThreshold) analyzeEnv();
		
		// setting up reflection method that is called in PApplet
		try {
			transcriptionEvent = p.getClass().getMethod("transcribe", 
					String.class, float.class);
		} catch (SecurityException e) {
		} catch (NoSuchMethodException e) {
		} catch (IllegalArgumentException e) {
		}
		
		// setting up reflection method that is called in PApplet
		try {
			transcriptionEvent2 = p.getClass().getMethod("transcribe", 
					String.class, float.class, int.class);
		} catch (SecurityException e) {
		} catch (NoSuchMethodException e) {
		} catch (IllegalArgumentException e) {
		}
		
		if (transcriptionEvent == null && transcriptionEvent2 == null) System.err.println("STT info: use transcribe(String word, float confidence, [int status]) in your main sketch to receive transcription events");
		
		// calls draw every frame
		this.p.registerDraw(this);
		this.p.registerDispose(this);
	
	}

	public void draw() {
		
		if (analyzing) {
			analyzeEnv();	
		}
		
		volume = in.mix.level() * 1000;
		
		// start recording when someone says something louder than specified
		// threshold
		if (volume > threshold) {
			onSpeech();
		} 

		// the magix begins. save it. transcribe it.
		if (timer.isFinished() && volume < threshold && recorder.isRecording() && recording) {
			onSpeechFinish();
		} else if (timer.isFinished() && volume < threshold && !recorder.isRecording()){
			startListening();
		}
		
		for (int i = 0; i < threads.size(); i++) {
			transcription = threads.get(i); 
			transcription.debug = debug;
			//todo: use array for multiple transcription
			if (transcription.isAvailable()) {
				if (transcriptionEvent != null) {
					try {
						transcriptionEvent.invoke(p, new Object[] { transcription.getUtterance(), transcription.getConfidence()});
					} catch (IllegalArgumentException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (IllegalAccessException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (InvocationTargetException e) {

					}
				} else if (transcriptionEvent2 != null) {
					try {
						transcriptionEvent2.invoke(p, new Object[] { transcription.getUtterance(), transcription.getConfidence(), transcription.getStatus()});
					} catch (IllegalArgumentException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (IllegalAccessException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (InvocationTargetException e) {

					}
				}
				threads.remove(i);
			}
			
			if (debug && status != lastStatus) {
				System.out.println(getTime() + " " + status);
				lastStatus = status;
			}
		}
	}
	
	private void analyzeEnv() {
		if (!analyzing) {
			timer2 = new Timer(2000);
			timer2.start();
			analyzing = true;
			volumes = new ArrayList<Float>();
		}

		if (!timer2.isFinished()) {
			float volume = in.mix.level() * 1000;
			volumes.add(volume);
		} else {
			float avg = 0.0f;
			float max = 0.0f;
			for (int i = 0; i < volumes.size(); i++) {
				avg += volumes.get(i);
				if (volumes.get(i) > max) max = volumes.get(i);
			}
			avg /= volumes.size();
			threshold = (float) Math.ceil(max);
			System.out.println(getTime() + " Volume threshold automatically set to " + threshold);
			analyzing = false;
		}
		
	}

	private void stop() {
		// always close Minim audio classes when you are done with them
		in.close();
		minim.stop();
		p.stop();
	}
	
	private void onSpeech()
	{
		// resets the timer each time something is heard
		status = "Recording";
		timer.start();
		recording = true;
		if (transcriptionEvent2 != null && status != lastStatus) {
			lastStatus = "Recording";
			try {
				transcriptionEvent2.invoke(p, new Object[] { transcription.getUtterance(), transcription.getConfidence(), STT.RECORDING});
			} catch (IllegalArgumentException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IllegalAccessException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (InvocationTargetException e) {

			}
		}
	}
	
	private void onSpeechFinish()
	{
		status = "Transcribing";
		fired = false;
		recorder.endRecord();
		recorder.save();
		recording = false;
		
		if (transcriptionEvent2 != null && status != lastStatus) {
			lastStatus = "Transcribing";
			try {
				transcriptionEvent2.invoke(p, new Object[] { transcription.getUtterance(), transcription.getConfidence(), STT.TRANSCRIBING});
			} catch (IllegalArgumentException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IllegalAccessException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (InvocationTargetException e) {

			}
		}
		
		String flac = path + fileName + fileCount + ".flac";
		
		encoder.encode(new File(path + fileName + fileCount + ".wav"), new File(flac));
		
		// encode using commandline
		/*
		try {
			Process p = Runtime.getRuntime().exec("/usr/local/bin/flac --sample-rate=44000 " + path + fileName + fileCount + ".wav");
		} catch (IOException e) {
			System.out.println(e);
		}
		*/
		boolean exists = (new File(flac)).exists();
		while(exists == false)
		{	
			exists = (new File(flac)).exists();		
		}
	
		if (exists) {
			// save the output string to do some impressive things with it later
			 this.transcribe(flac);
		} else {
		    System.err.println("Could not transcribe. File was not encoded in time.");
		}
		
		// new file for new speech
		if (log) fileCount++;
	}
	
	private void transcribe(String _path) {
		// only interrupt if available
		// transcription.interrupt();
		transcription = new TranscriptionThread(language);
		transcription.debug = debug;
		transcription.start();
		transcription.startTranscription(_path);
		threads.add(transcription);
	}

	private void startListening () 
	{
		// status = "Waiting for your voice";
		recorder.endRecord();
		recorder.save();
		recorder = minim.createRecorder(in, path + fileName + fileCount + ".wav", true);
		recorder.beginRecord();
		timer.start();
	}
	
	private void initFileSystem ()
	{
		dataPath = p.dataPath("");
		recordsPath = getDateTime() + "/";
		if (log) {
			path = dataPath + recordsPath;
		} else {
			path = dataPath;
		}
				
		try {
			// create datafolder if it does not exist yet
			File datadir = new File(dataPath + "/");
			datadir.mkdir();
			
			File recordsdir = new File(path);
			recordsdir.mkdir();

		} catch (NullPointerException e) {
			System.err.println("Could not read files in directory: " + path);
		}
	}
	
	/**
	 * Enables logging of events like recording, transcribing, success, error.
	 */
	public void enableDebug() {
		this.debug = true;
		for (int i = 0; i < threads.size(); i++) {
			threads.get(i).debug = this.debug;
		}
	}
	public void disableDebug() {
		this.debug = false;
	}
	
	private String getDateTime() {
	        DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd-HH-mm-ss");
	        Date date = new Date();
	        return dateFormat.format(date);
	}
	
	private String getTime() {
        DateFormat dateFormat = new SimpleDateFormat("HH:mm:ss");
        Date date = new Date();
        return dateFormat.format(date);
	}

	public float getThreshold() {
		return threshold;
	}

	/**
	 * Sets the volume threshold that is used to recognize speech and to filter background noise.
	 */
	public void setThreshold(float threshold) {
		this.threshold = threshold;
	}

	public float getVolume() {
		return volume;
	}
	
	public void enableHistory() {
		this.log = true;
	}
	public void disableHistory() {
		this.log = false;
	}
	public void enableAutoThreshold() {
		this.autoThreshold = true;
	}
	
	/**
	 * Disables the analysis of the environmental volume after STT initialized.
	 */
	public void disableAutoThreshold() {
		this.autoThreshold = false;
	}

	public String getLanguage() {
		return language;
	}
	
	/**
	 * @param language en, de, fr, etc. If the language is not supported it will automatically fall back to English.
	 */
	public void setLanguage(String language) {
		this.language = language;
	}
	public void dispose() {	   
	}
}
