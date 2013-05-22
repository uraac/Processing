import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

import java.util.List;


Minim       minim;
AudioOutput out;
AudioRecorder recorder;


List< Rectangle > list;
int workoutTime = 30;
int restTime = 10;
int wholeTime = workoutTime + restTime;
int NUM_ROW = 10;


void setup() {
  frameRate( 1 );
  smooth( 4 );
  size( displayWidth, displayHeight, P2D );
  
  minim = new Minim( this );
  out = minim.getLineOut();
  //recorder = minim.createRecorder(out, "myrecording.wav", true);
  
  list = new ArrayList< Rectangle >();
  
  int columnMax = wholeTime / NUM_ROW;
  int rectPosition = 0;
  for ( int column = 0; column < columnMax; column++ ) {
    for ( int row = 0; row < NUM_ROW; row++, rectPosition++ ) {
      Rectangle rect = createTimeCell( row, column, rectPosition );
      list.add( rect );
    }
  }
  textFont(createFont("Arial", 12));
}

int currentON = 0;
void draw() {
  background( 0 );
  
  beep( currentON );
  int nextON = 0;
  for ( Rectangle rect: list ) {
    fill( rect.getBgColor() );
    rect.setON( currentON );
    rect( rect.getXY().x,
          rect.getXY().y,
          rect.getWidth(),
          rect.getHeight(),
          rect.getRadius() );
    nextON = rect.getNextOn( currentON );
  }
  currentON = nextON;
  /*
  if ( recorder.isRecording() )
  {
    text("Currently recording...", 5, 15);
  }
  else
  {
    text("Not recording.", 5, 15);
  }
  */
}

void stop() {
  out.close();
  minim.stop();
  super.stop();
}

Rectangle createTimeCell( int row, int column, int position ) {
  int rectWidth = width / ( wholeTime / NUM_ROW );
  int rectHeight = height / NUM_ROW;
  if ( position < workoutTime ) {
    return new WorkOutRectangle( rectWidth, rectHeight, column, row, position );
  } else {
    return new RestRectangle( rectWidth, rectHeight, column, row, position );
  }
}

class Rectangle {
  protected int row;
  protected int col;
  protected int _width;
  protected int _height;
  protected PVector _xy;
  protected color bgColor;
  protected int radius;
  protected int position;
  
  public Rectangle( int rectWidth, int rectHeight, int column, int row, int position ) {
    this.row = row;
    this.col = column;
    this._width = rectWidth;
    this._height = rectHeight;
    this.position = position;
    this._xy = new PVector( rectWidth * column, rectHeight * row );
    if ( this._width > this._height ) {
      this.radius = this._height / 8;
    } else {
      this.radius = this._width / 8;
    }
  }
  
  public int getWidth() {
    return this._width;
  }
  
  public int getHeight() {
    return this._height;
  }
  
  public PVector getXY() {
    return this._xy;
  }
  
  public color getBgColor() {
    return this.bgColor;
  }
  
  public int getRadius() {
    return this.radius;
  }
  
  public int getNextOn( int _currentON ) {
    if ( _currentON + 1 == workoutTime + restTime ) {
      return 0;
    }
    if ( _currentON <= this.position ) {
      return _currentON + 1;
    }
    
    return _currentON;
  }
  
  public void setON( int _currentON ) {
    if ( _currentON < this.position ) {
      noFill();
    }
  }
  
  public int getPosition() {
    return this.position;
  }
}

class WorkOutRectangle extends Rectangle {
  public WorkOutRectangle( int rectWidth, int rectHeight, int column, int row, int position ) {
    super( rectWidth, rectHeight, column, row, position );
    
    this.bgColor = #FFAD15;
  }
}

class RestRectangle extends Rectangle {
  public RestRectangle( int rectWidth, int rectHeight, int column, int row, int position ) {
    super( rectWidth, rectHeight, column, row, position );
    this.bgColor = #5AB3FF;
  }
}

void beep( int _currentON ) {
  if ( _currentON < workoutTime ) {
    out.playNote( 0, 0.2, "A5" );
  } else {
    out.playNote( 0, 0.5, "A4" );
  }
}

boolean sketchFullScreen() {
  return true;
}

/*
void keyReleased()
{
  if ( key == 'r' ) 
  {
    // to indicate that you want to start or stop capturing audio data, you must call
    // beginRecord() and endRecord() on the AudioRecorder object. You can start and stop
    // as many times as you like, the audio data will be appended to the end of the buffer 
    // (in the case of buffered recording) or to the end of the file (in the case of streamed recording). 
    if ( recorder.isRecording() ) 
    {
      recorder.endRecord();
    }
    else 
    {
      recorder.beginRecord();
    }
  }
  if ( key == 's' )
  {
    // we've filled the file out buffer, 
    // now write it to the file we specified in createRecorder
    // in the case of buffered recording, if the buffer is large, 
    // this will appear to freeze the sketch for sometime
    // in the case of streamed recording, 
    // it will not freeze as the data is already in the file and all that is being done
    // is closing the file.
    // the method returns the recorded audio as an AudioRecording, 
    // see the example  AudioRecorder >> RecordAndPlayback for more about that
    recorder.save();
    println("Done saving.");
  }
}
*/
